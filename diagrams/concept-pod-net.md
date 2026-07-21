Management/logging network
192.168.3.0/24
        |
        |  hype1 physical/bridge interface
        |  Example: 192.168.3.x
        |
+-------+----------------------------------+
| RHEL host: hype1                         |
|                                          |
|  Published service ports                 |
|  192.168.3.x:3000  -> Grafana:3000       |
|  192.168.3.x:9090  -> Prometheus:9090    |
|                                          |
|  Podman bridge: noc                      |
|  10.19.84.0/24                           |
|      |                                   |
|      +-- Grafana                         |
|      +-- Prometheus                      |
|      +-- Loki                            |
|      +-- Telegraf                        |
|      +-- gnmic                           |
|      +-- InfluxDB                        |
+------------------------------------------+

Podman’s bridge driver creates a software bridge and a private container subnet on the host. It is analogous to an internal virtual switch—not an extension of your physical management VLAN.
