# NOC

Network Operations Center Lab

## Purpose

This repository contains the source code, documentation, configuration, dashboards, and deployment artifacts for building a modern network observability platform using:

- RHEL 9.8 - An enterprise Linux operating system developed by Red Hat. Provides the stable and secure platform on which the monitoring system runs.
- Podman - A daemonless container engine compatible with OCI container standards. Runs applications in isolated containers without requiring a central daemon.
- Container -	A lightweight, isolated runtime environment that packages an application and its dependencies.	Simplifies deployment and ensures applications run consistently across systems.
- OCI (Open Container Initiative)	An industry standard for container images and runtimes.	Ensures containers are portable between compatible platforms.
- systemd	- The Linux service manager and initialization system.	Starts, stops, monitors, and manages services during system operation and boot.
- Quadlet	- A systemd configuration file that defines and manages Podman containers as native systemd services.	Allows containers to be deployed and managed like any other Linux service.
- SELinux (Security-Enhanced Linux) -	A mandatory access control framework built into Linux.	Restricts processes and containers to only the resources they are explicitly permitted to access.
- Git -	A distributed version control system.	Tracks changes to files, allowing history, collaboration, and rollback of configurations and documentation.
- GitHub -	A cloud-hosted platform for Git repositories.	Stores the project's source code and documentation while enabling collaboration and backup.
- Markdown- A lightweight plain-text formatting language.	Makes documentation easy to write, read, and version with Git.
- Grafana - A dashboard and visualization platform. Displays collected telemetry and monitoring data in graphs and dashboards.
- InfluxDB	- A time-series database optimized for timestamped data.	Stores metrics such as temperatures, interface counters, and power measurements.
- Prometheus	- A monitoring system and metrics database.	Collects and stores metrics from applications and infrastructure using a pull model.
- Loki -	A log aggregation system developed by Grafana Labs.	Collects and indexes system and application logs for centralized viewing.
- Promtail -	A log collection agent for Loki.	Reads local log files and forwards them to Loki.
- Telegraf	- A plugin-based telemetry collection agent.	Collects metrics from network devices, sensors, and servers and forwards them to databases.
- gNMI - gRPC Network Management Interface, a modern telemetry protocol.	Streams configuration and operational data from network devices.
- OpenConfig -	A vendor-neutral data model for network devices.	Provides a consistent way to monitor and configure equipment from different vendors.
- SNMP - Simple Network Management Protocol.	Polls network devices for operational statistics and status information, or receives info in the form of "traps".
- Modbus/TCP - An industrial communication protocol carried over TCP/IP.	Retrieves operational data from devices such as power systems and controllers.
- Telemetry - The automated collection and transmission of operational data.	Provides visibility into the health and performance of systems and devices.

The project is developed as a series of documented labs with reproducible configurations.
