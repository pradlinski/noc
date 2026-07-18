# ADR-0002 – Use Quadlets

**Status:** Accepted

## Context

Containerized services must start automatically, recover from failures, integrate with the operating system, and be easy to manage using standard Linux administration tools.

## Decision

Manage all Podman containers using **systemd Quadlets**.

## Rationale

Quadlets allow containers to be defined as simple configuration files that systemd converts into native services. This approach provides automatic startup, dependency management, logging through journald, and familiar service management using `systemctl`.

## Consequences

Each application will have a corresponding Quadlet file stored in the Git repository and deployed to the system during installation. Containers will be administered like any other system service.

