#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_DIR="${REPO_ROOT}/quadlets"
TARGET_DIR="/etc/containers/systemd"

if [[ ${EUID} -ne 0 ]]; then
    echo "Error: run this script with sudo." >&2
    exit 1
fi

if [[ ! -d "${SOURCE_DIR}" ]]; then
    echo "Error: Quadlet source directory not found: ${SOURCE_DIR}" >&2
    exit 1
fi

mapfile -d '' quadlet_files < <(
    find "${SOURCE_DIR}" \
        -maxdepth 1 \
        -type f \
        \( \
            -name '*.container' -o \
            -name '*.network' -o \
            -name '*.volume' -o \
            -name '*.pod' -o \
            -name '*.kube' \
        \) \
        -print0 |
    sort -z
)

if [[ ${#quadlet_files[@]} -eq 0 ]]; then
    echo "Error: no Quadlet files found in ${SOURCE_DIR}" >&2
    exit 1
fi

install -d -o root -g root -m 0755 "${TARGET_DIR}"

echo "Deploying Quadlet files:"

for source_file in "${quadlet_files[@]}"; do
    target_file="${TARGET_DIR}/$(basename "${source_file}")"

    install \
        -v \
        -o root \
        -g root \
        -m 0644 \
        "${source_file}" \
        "${target_file}"
done

restorecon -RFv "${TARGET_DIR}"
systemctl daemon-reload

echo
echo "Quadlet deployment complete."
echo "Source: ${SOURCE_DIR}"
echo "Target: ${TARGET_DIR}"
