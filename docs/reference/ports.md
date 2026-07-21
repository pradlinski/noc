
# NOC Platform Port Registry

## Purpose

This document records all network ports used by the NOC platform.

The objectives are to:

* Prevent host port conflicts.
* Reserve ports for future services.
* Document container-to-host port mappings.
* Maintain consistent port assignments across environments.

---

# Port Assignment Principles

1. Containers should use their **default application ports** whenever practical.
2. Host ports may differ to avoid conflicts with the operating system or other services.
3. Services are published only on the management interface unless explicitly required.
4. Inter-container communication uses the internal `noc` Podman network.
5. All port assignments must be documented here before deployment.

---

# Host Services

| Service | Host IP      | Host Port | Notes                     |
| ------- | ------------ | --------: | ------------------------- |
| Cockpit | 192.168.3.12 |  **9090** | RHEL management interface |
| SSH     | 192.168.3.12 |        22 | Host administration       |

---

# Container Services

| Service                  |     Host Port | Container Port | Status           | Notes                            |
| ------------------------ | ------------: | -------------: | ---------------- | -------------------------------- |
| Grafana                  |      **3001** |           3000 | Implemented      | Visualization platform           |
| Prometheus               |      **9091** |           9090 | Reserved (Lab 4) | Metrics collection               |
| Loki                     |      **3100** |           3100 | Reserved         | Log aggregation                  |
| Alertmanager             |      **9093** |           9093 | Reserved         | Alert routing                    |
| gNMIc API *(optional)*   |      **7890** |           7890 | Reserved         | REST API and management endpoint |
| Tempo *(future)*         |      **3200** |           3200 | Reserved         | Distributed tracing              |
| Node Exporter *(future)* | Not published |           9100 | Reserved         | Internal Prometheus target       |

---

# Internal Container Network

Network Name

```text
noc
```

Subnet

```text
10.19.84.0/24
```

The internal network is used for communication between containers.

Example:

```text
Grafana  -------->  Prometheus
3000              9090

Prometheus -----> gNMIc

gNMIc ----------> FortiGate
```

The internal network is **not** intended to be reachable directly from the management LAN.

---

# Current Published Endpoints

| URL                      | Purpose                    |
| ------------------------ | -------------------------- |
| http://192.168.3.12:3001 | Grafana                    |
| http://192.168.3.12:9090 | Cockpit                    |
| http://192.168.3.12:9091 | Prometheus *(after Lab 4)* |

---

# Reserved Future Services

| Service                |                      Planned Host Port |
| ---------------------- | -------------------------------------: |
| Prometheus Pushgateway |                                   9092 |
| Blackbox Exporter      |                                   9115 |
| SNMP Exporter          |                                   9116 |
| cAdvisor               | 8080 *(internal only unless required)* |

---

# Validation

Verify published ports:

```bash
podman ps

podman port grafana
podman port prometheus
```

Verify listening sockets on the host:

```bash
ss -ltn
```

Verify container connectivity:

```bash
podman network inspect noc
```

Verify Prometheus health:

```bash
curl http://192.168.3.12:9091/-/healthy
```

Verify Grafana health:

```bash
curl http://192.168.3.12:3001/api/health
```

---

# Change Control

Before assigning a new port:

1. Verify it does not conflict with an existing host service.
2. Add the assignment to this document.
3. Update the appropriate Quadlet.
4. Validate connectivity after deployment.
5. Commit the documentation update with the deployment changes.

---

# Revision History

| Lab   | Changes                                                                                     |
| ----- | ------------------------------------------------------------------------------------------- |
| Lab 3 | Added Grafana (3001 → 3000), documented Cockpit (9090), established port assignment policy. |
| Lab 4 | Reserved Prometheus (9091 → 9090) and future monitoring service ports.                      |

