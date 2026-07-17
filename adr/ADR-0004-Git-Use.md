# ADR-0004 – Git as the Source of Truth

**Status:** Accepted

## Context

The project includes documentation, configuration files, scripts, dashboards, and container definitions that will evolve over time. Changes must be tracked, reproducible, and recoverable.

## Decision

Use the Git repository as the authoritative source for all project artifacts.

## Rationale

Configuration files and documentation will be developed and maintained within the Git repository before deployment to the operating system. Version control provides change history, collaboration, rollback capability, and reproducible deployments.

## Consequences

Configuration files will not be edited directly on the running system except during troubleshooting. Permanent changes will always be made in the Git repository, committed with descriptive messages, reviewed, and then deployed to the target system.

