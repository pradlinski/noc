Lab4: prometheus
multiple Exec= lines in this Quadlet did not accumulate; only the final value was used. Prometheus arguments must therefore be placed on one Exec= line.

Current deployment process:
Git repository
      │
      ▼
install
      │
      ▼
/etc/noc/prometheus/prometheus.yml
      │
      ▼
Quadlet bind mount
      │
      ▼
Container

The install command replaces the destination file, which changes its inode. A running container with a bind mount to a single file continues using the old inode until the container is recreated.

For configuration file changes, the deployment sequence should be:
sudo install ...
sudo systemctl restart <service>


