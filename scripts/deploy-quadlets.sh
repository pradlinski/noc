#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_DIR="${REPO_ROOT}/quadlets"
TARGET_DIR="/etc/containers/systemd"
STATE_DIR="/var/lib/noc-deploy"
MANIFEST="${STATE_DIR}/quadlets.manifest"

SUPPORTED_EXPR=(
    -name '*.container' -o
    -name '*.network' -o
    -name '*.volume' -o
    -name '*.pod' -o
    -name '*.kube'
)

declare -A restart_units=()
declare -A stop_only_units=()
declare -A changed_files=()
declare -A removed_files=()
declare -A current_files=()

log() {
    printf '%s\n' "$*"
}

warn() {
    printf 'WARNING: %s\n' "$*" >&2
}

fail() {
    printf 'ERROR: %s\n' "$*" >&2
    exit 1
}

unit_for_file() {
    local filename="$1"
    local base

    case "${filename}" in
        *.container)
            base="${filename%.container}"
            printf '%s.service\n' "${base}"
            ;;
        *.network)
            base="${filename%.network}"
            printf '%s-network.service\n' "${base}"
            ;;
        *.volume)
            base="${filename%.volume}"
            printf '%s-volume.service\n' "${base}"
            ;;
        *.pod)
            base="${filename%.pod}"
            printf '%s-pod.service\n' "${base}"
            ;;
        *.kube)
            base="${filename%.kube}"
            printf '%s.service\n' "${base}"
            ;;
        *)
            return 1
            ;;
    esac
}

is_application_quadlet() {
    case "$1" in
        *.container|*.kube|*.pod)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

is_infrastructure_quadlet() {
    case "$1" in
        *.network|*.volume)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

collect_reverse_dependencies() {
    local unit="$1"
    local dependent

    systemctl list-dependencies \
        --reverse \
        --plain \
        --no-legend \
        "${unit}" 2>/dev/null |
    awk '{print $1}' |
    grep -E '\.service$' |
    while IFS= read -r dependent; do
        [[ -n "${dependent}" ]] || continue
        [[ "${dependent}" == "${unit}" ]] && continue

        case "${dependent}" in
            systemd-*|multi-user.target|basic.target)
                continue
                ;;
        esac

        printf '%s\n' "${dependent}"
    done
}

if [[ ${EUID} -ne 0 ]]; then
    fail "Run this script with sudo."
fi

[[ -d "${SOURCE_DIR}" ]] ||
    fail "Quadlet source directory does not exist: ${SOURCE_DIR}"

install -d -o root -g root -m 0755 "${TARGET_DIR}"
install -d -o root -g root -m 0755 "${STATE_DIR}"

mapfile -d '' source_paths < <(
    find "${SOURCE_DIR}" \
        -maxdepth 1 \
        -type f \
        \( "${SUPPORTED_EXPR[@]}" \) \
        -print0 |
    sort -z
)

[[ ${#source_paths[@]} -gt 0 ]] ||
    fail "No supported Quadlet files found in ${SOURCE_DIR}"

for source_path in "${source_paths[@]}"; do
    filename="$(basename "${source_path}")"
    current_files["${filename}"]=1
done

previous_files=()

if [[ -f "${MANIFEST}" ]]; then
    mapfile -t previous_files < "${MANIFEST}"
fi

# Find files that were previously managed but have been removed from Git.
for filename in "${previous_files[@]}"; do
    [[ -n "${filename}" ]] || continue

    if [[ -z "${current_files[${filename}]+x}" ]]; then
        removed_files["${filename}"]=1

        unit="$(unit_for_file "${filename}")"

        if is_application_quadlet "${filename}"; then
            stop_only_units["${unit}"]=1
        fi

        if is_infrastructure_quadlet "${filename}"; then
            while IFS= read -r dependent; do
                [[ -n "${dependent}" ]] &&
                    stop_only_units["${dependent}"]=1
            done < <(collect_reverse_dependencies "${unit}")
        fi
    fi
done

# Identify new or changed definitions.
for source_path in "${source_paths[@]}"; do
    filename="$(basename "${source_path}")"
    target_path="${TARGET_DIR}/${filename}"

    if [[ ! -f "${target_path}" ]] ||
       ! cmp -s "${source_path}" "${target_path}"; then
        changed_files["${filename}"]=1

        unit="$(unit_for_file "${filename}")"

        if is_application_quadlet "${filename}"; then
            restart_units["${unit}"]=1
        fi

        # Capture current dependents before daemon-reload.
        if is_infrastructure_quadlet "${filename}"; then
            while IFS= read -r dependent; do
                [[ -n "${dependent}" ]] &&
                    restart_units["${dependent}"]=1
            done < <(collect_reverse_dependencies "${unit}")
        fi
    fi
done

if [[ ${#changed_files[@]} -eq 0 &&
      ${#removed_files[@]} -eq 0 ]]; then
    log "No Quadlet changes detected."
    log "Source and deployed definitions are already synchronized."
    exit 0
fi

log
log "Quadlet deployment plan"
log "======================="

if [[ ${#changed_files[@]} -gt 0 ]]; then
    log "New or changed files:"

    while IFS= read -r filename; do
        log "  ${filename}"
    done < <(printf '%s\n' "${!changed_files[@]}" | sort)
fi

if [[ ${#removed_files[@]} -gt 0 ]]; then
    log "Removed files:"

    while IFS= read -r filename; do
        log "  ${filename}"
    done < <(printf '%s\n' "${!removed_files[@]}" | sort)
fi

# Stop services whose definitions or required infrastructure were removed.
if [[ ${#stop_only_units[@]} -gt 0 ]]; then
    log
    log "Stopping services affected by removed definitions:"

    while IFS= read -r unit; do
        [[ -n "${unit}" ]] || continue

        if systemctl is-active --quiet "${unit}"; then
            log "  Stopping ${unit}"
            systemctl stop "${unit}"
        else
            log "  ${unit} is already inactive"
        fi
    done < <(printf '%s\n' "${!stop_only_units[@]}" | sort)
fi

# Remove stale files previously deployed by this script.
if [[ ${#removed_files[@]} -gt 0 ]]; then
    log
    log "Removing stale deployed Quadlets:"

    while IFS= read -r filename; do
        target_path="${TARGET_DIR}/${filename}"

        if [[ -e "${target_path}" ]]; then
            log "  Removing ${target_path}"
            rm -f "${target_path}"
        fi
    done < <(printf '%s\n' "${!removed_files[@]}" | sort)
fi

# Install only new or changed definitions.
if [[ ${#changed_files[@]} -gt 0 ]]; then
    log
    log "Installing changed Quadlets:"

    while IFS= read -r filename; do
        source_path="${SOURCE_DIR}/${filename}"
        target_path="${TARGET_DIR}/${filename}"

        install \
            -v \
            -o root \
            -g root \
            -m 0644 \
            "${source_path}" \
            "${target_path}"
    done < <(printf '%s\n' "${!changed_files[@]}" | sort)
fi

restorecon -RF "${TARGET_DIR}"
systemctl daemon-reload

# Capture dependencies generated by newly installed infrastructure definitions.
for filename in "${!changed_files[@]}"; do
    if is_infrastructure_quadlet "${filename}"; then
        unit="$(unit_for_file "${filename}")"

        while IFS= read -r dependent; do
            [[ -n "${dependent}" ]] &&
                restart_units["${dependent}"]=1
        done < <(collect_reverse_dependencies "${unit}")
    fi
done

# Do not restart anything intentionally stopped because its dependency was removed.
for unit in "${!stop_only_units[@]}"; do
    unset 'restart_units[$unit]'
done

# Start or restart changed application services and affected dependents.
if [[ ${#restart_units[@]} -gt 0 ]]; then
    log
    log "Starting or restarting affected services:"

    while IFS= read -r unit; do
        [[ -n "${unit}" ]] || continue

        if ! systemctl cat "${unit}" >/dev/null 2>&1; then
            warn "Generated service not found: ${unit}"
            continue
        fi

        log "  Restarting ${unit}"

        if ! systemctl restart "${unit}"; then
            warn "Failed to restart ${unit}"
        fi
    done < <(printf '%s\n' "${!restart_units[@]}" | sort)
fi

# Write the authoritative list of files managed by this deployer.
printf '%s\n' "${!current_files[@]}" |
    sort > "${MANIFEST}"

chown root:root "${MANIFEST}"
chmod 0644 "${MANIFEST}"
restorecon "${MANIFEST}" 2>/dev/null || true

log
log "Deployment status"
log "================="

deployment_failed=0

if [[ ${#restart_units[@]} -gt 0 ]]; then
    while IFS= read -r unit; do
        [[ -n "${unit}" ]] || continue

        if systemctl is-active --quiet "${unit}"; then
            printf '  %-35s %s\n' "${unit}" "active"
        else
            printf '  %-35s %s\n' "${unit}" "NOT ACTIVE"
            deployment_failed=1
        fi
    done < <(printf '%s\n' "${!restart_units[@]}" | sort)
fi

log
log "Managed definitions: ${MANIFEST}"
log "Deployment complete."

if [[ ${deployment_failed} -ne 0 ]]; then
    exit 1
fi
