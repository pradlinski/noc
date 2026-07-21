Client
   │
192.168.3.12:3001
   │
Host port mapping
   │
Grafana container
10.19.84.x:3000



             Management LAN
           192.168.3.0/24
                  │
                  │
          192.168.3.12:3001
                  │
          Host Port Mapping
                  │
         ┌──────────────────┐
         │    hype1 Host    │
         │                  │
         │  podman1 bridge  │
         │   10.19.84.1     │
         └────────┬─────────┘
                  │
      ┌───────────┴───────────┐
      │                       │
 Grafana               Future Prometheus
10.19.84.5:3000       10.19.84.6:9090


Internal Network Validation

sudo podman inspect grafana \
  --format '{{with index .NetworkSettings.Networks "noc"}}{{.IPAddress}}{{end}}'

sudo podman exec grafana ss -ltn

curl http://<container-ip>:3000/api/health

ip addr show podman1

ip route | grep 10.19.84

sudo podman network inspect noc

