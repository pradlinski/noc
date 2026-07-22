# Administration Quick Reference

This section provides the primary operational checks for each completed lab. These commands are intended for routine health verification and troubleshooting.
Note: Platform containers are deployed as system (root-owned) Quadlets. Use sudo podman ps and sudo podman inspect when managing platform services. Running podman ps as a non-root user will not display system-managed containers.
---

# Lab 1 – RHEL Base Platform

## Purpose

Verify the host operating system and foundational services.

## System Health

```bash
hostnamectl

uptime

cat /etc/redhat-release

uname -r
```

## SELinux

```bash
getenforce

sestatus

sudo ausearch -m AVC,USER_AVC -ts recent -i
```

Expected:

* Enforcing
* No recent AVC denials

## Podman

```bash
podman info

podman version
```

Verify:

* cgroups v2
* netavark networking
* overlay storage

---

# Lab 2 – Container Platform

## Purpose

Verify the shared container infrastructure.

## Quadlet Definitions

```bash
ls -l /etc/containers/systemd
```

## Container Network

```bash
sudo podman network ls

sudo podman network inspect noc
```

Verify:

* network exists
* bridge driver
* correct subnet
* gateway

## Deployment Script

Run:

```bash
sudo scripts/deploy-quadlets.sh
```

Expected:

* No changes detected, or
* Only modified Quadlets deployed

The deployment script is safe to execute repeatedly.

---

# Lab 3 – Grafana

## Purpose

Verify Grafana service availability and operation.

## Service Status

```bash
systemctl status grafana.service

systemctl is-active grafana.service

systemctl is-enabled grafana.service
```

Expected:

* active
* generated

## Container Status

```bash
podman ps

podman inspect grafana
```

Verify:

* container running
* attached to the `noc` network

## Internal Network

Determine the container IP:

```bash
sudo podman inspect grafana \
  --format '{{with index .NetworkSettings.Networks "noc"}}{{.IPAddress}}{{end}}'
```

Verify Grafana is listening:

```bash
sudo podman exec grafana ss -ltn
```

Test the service over the internal container network:

```bash
curl http://<container-ip>:3000/api/health
```

## Published Service

Verify the management interface:

```bash
curl http://192.168.3.12:3001/api/health
```

## Logs

```bash
journalctl -u grafana.service --since "30 minutes ago"

journalctl -u grafana.service -f
```

## SELinux

```bash
sudo ausearch -m AVC,USER_AVC -ts recent -i
```

Expected:

```text
<no matches>
```

## Deployment

After modifying any Quadlet:

```bash
git status

git commit

sudo scripts/deploy-quadlets.sh
```

Do not edit files under:

```text
/etc/containers/systemd
```

All configuration changes originate in the Git repository.

---

# Routine Platform Health Check

The following commands provide a quick operational overview of the current platform.

```bash
systemctl status grafana.service

podman ps

sudo podman network inspect noc

curl http://192.168.3.12:3001/api/health

sudo ausearch -m AVC,USER_AVC -ts recent -i
```

A healthy platform should report:

* Grafana service active
* Grafana container running
* `noc` network present
* Health endpoint responding
* No SELinux AVC denials

######################3
LAB 4
Prometheus Service - 
#################
Starting

sudo systemctl start prometheus.service

Stopping

sudo systemctl stop prometheus.service

Restarting

sudo systemctl restart prometheus.service

Viewing logs

journalctl -u prometheus.service -f

Checking configuration

curl http://192.168.3.12:9091/-/ready

Checking targets

curl http://192.168.3.12:9091/api/v1/targets


##########
Lab 6 or so
########

Deploying dashboards:

sudo install -d -m 0755 \
  /etc/noc/grafana/dashboards

sudo install -m 0644 \
  dashboards/node-exporter-full.json \
  /etc/noc/grafana/dashboards/node-exporter-full.json

sudo install -m 0644 \
  quadlets/grafana.container \
  /etc/containers/systemd/grafana.container

sudo systemctl daemon-reload
sudo systemctl restart grafana.service
#############

 
