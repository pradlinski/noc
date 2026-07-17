Use an accessible container solution that is rootless, flexible and allows for modular building blocks in the overall project.

# ADR-0001 – Use Podman

**Status:** Accepted

## Context

The monitoring platform requires a reliable method of deploying and managing multiple services, including Grafana, InfluxDB, Prometheus, Loki, Telegraf, and gNMI collectors. The solution should integrate well with Red Hat Enterprise Linux (RHEL), follow enterprise best practices, and minimize operational complexity.

## Decision

Use **Podman** as the container runtime for all services.

## Rationale

Podman is the native container platform for RHEL and fully supports OCI-compliant container images. It operates without a central daemon, integrates directly with systemd, supports rootless containers where appropriate, and works seamlessly with SELinux.

## Consequences

The monitoring platform will use Podman for all containerized services. Container definitions will be version controlled, managed through systemd Quadlets, and deployed consistently across systems.

