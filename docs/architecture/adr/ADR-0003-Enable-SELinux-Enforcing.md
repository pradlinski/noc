# ADR-0003 – Enable SELinux Enforcing

**Status:** Accepted

## Context

The monitoring platform will host multiple containerized applications that access network resources, persistent storage, and system services. Security should be incorporated into the platform from the beginning rather than added later.

## Decision

Operate the server with **SELinux in Enforcing mode**.

## Rationale

SELinux provides mandatory access control that limits applications and containers to only the resources explicitly permitted by policy. Enabling SELinux from the start avoids insecure workarounds and promotes secure deployment practices.

## Consequences

All services, container volumes, and file permissions must be configured to comply with SELinux policies. Configuration changes will favor proper labeling and policy management rather than disabling security features.


