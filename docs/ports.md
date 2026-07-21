# NOC Platform Port Registry

This document is the authoritative registry of TCP and UDP ports used by the
NOC monitoring platform on `hype1`.

## Design rules

1. User-facing services are published only on the management address
   `192.168.3.12`.
2. Services used only by other containers are not published on the host.
3. Container services communicate over the private Podman network `noc`
   (`10.19.84.0/24`).
4. Host port assignments must be recorded here before deployment.
5. Existing host services retain their established ports whenever practical.
6. A published host port does not need to match the service's container port.

## Published host ports

| Component | Protocol | Host address | Host port | Container port | Purpose |
|---|---|---:|---:|---:|---|
| Cockpit | TCP | 192.168.3.12 | 9090 | N/A | RHEL server administration |
| Grafana | TCP | 192.168.3.12 | 3001 | 3000 | Monitoring dashboards |

## Internal-only services

These services are expected to be reachable only through the `noc` container
network unless a documented operational requirement changes that decision.

| Component | Protocol | Container port | Intended consumers |
|---|---|---:|---|
| Prometheus | TCP | 9090 | Grafana and monitoring components |
| Loki | TCP | 3100 | Grafana and log collectors |
| InfluxDB | TCP | 8086 | Grafana and telemetry collectors |
| Telegraf | Varies | Not published | Internal collection and forwarding |
| gNMI collector | Varies | Not published | Internal telemetry collection |

## Reserved decisions

| Host port | Status | Notes |
|---:|---|---|
| 3000 | Unassigned | Not used for Grafana host publishing |
| 3001 | Assigned | Grafana |
| 9090 | Assigned | RHEL Cockpit; do not reuse |

