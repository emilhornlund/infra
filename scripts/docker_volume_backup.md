# Docker Volume Backup

Backs up selected persistent Docker volumes to the NAS under `/mnt/nas/backup/docker`.

Backups run automatically from the existing `infra-maintenance` container. The backup script is built into that image
and does not need to be installed directly on the NUC host.

## Backup Strategy

Each configured Docker volume is archived as a timestamped `.tar.gz` file:

```text
<volume>_<YYYY-MM-DD>.tar.gz
```

For example:

```text
vaultwarden-data-volume_2026-08-30.tar.gz
```

Backups are stored under:

```text
/mnt/nas/backup/docker
```

The current retention period is 14 days.

## NAS Configuration

The NAS must be mounted on the NUC at:

```text
/mnt/nas
```

The mount should use CIFS/Samba.

Example `/etc/fstab` configuration:

```text
//192.168.0.65/NUC   /mnt/nas   cifs   credentials=/etc/smbcredentials-nas,uid=1000,gid=1000,vers=3.1.1,iocharset=utf8,file_mode=0660,dir_mode=0770,x-systemd.automount,_netdev,nofail,serverino   0 0
```

Verify the mount on the host with:

```bash
mount | grep /mnt/nas
findmnt /mnt/nas
```

## Container Integration

The backup script lives in the repository at:

```text
scripts/docker_volume_backup.sh
```

The `infra-maintenance` image copies it to:

```text
/usr/local/bin/docker-volume-backup
```

The maintenance container requires these host mounts:

```yaml
volumes:
  - /var/run/docker.sock:/var/run/docker.sock
  - /mnt/nas:/mnt/nas
```

`/var/run/docker.sock` allows the backup process to inspect and mount Docker volumes.

`/mnt/nas` exposes the NAS backup destination to the maintenance container.

## Volumes

The backup set is configured directly in `scripts/docker_volume_backup.sh`.

Current volumes:

```bash
VOLUMES=(
  "acme-volume"
  "beszel-agent-data-volume"
  "beszel-data-volume"
  "beta-klurigo-service-uploads-volume"
  "home-assistant-config-volume"
  "memos-volume"
  "mongodb-data-volume"
  "nginx-proxy-certs-volume"
  "nginx-proxy-vhost-volume"
  "openwebui-data-volume"
  "pgadmin-data-volume"
  "pihole-dnsmasq-volume"
  "pihole-etc-volume"
  "portainer-data-volume"
  "postgres-data-volume"
  "prod-klurigo-service-uploads-volume"
  "redis-data-volume"
  "registry-auth-volume"
  "registry-certs-volume"
  "vaultwarden-data-volume"
)
```

Each configured name must correspond to an existing Docker volume.

To inspect the volumes currently present on the NUC:

```bash
docker volume ls --format '{{.Name}}' | sort
```

## Safety Checks

Before writing anything, the backup script verifies that `/mnt/nas` is backed by the expected CIFS filesystem.

If the NAS is unavailable or `/mnt/nas` resolves to local storage instead, the backup aborts. This prevents a failed NAS
mount from causing backups to consume the NUC's local NVMe storage.

Before archiving each configured volume, the script verifies that the Docker volume exists.

If a configured volume is missing, the backup aborts rather than allowing Docker to silently create a new empty volume.

## Scheduling

Scheduling is handled inside the existing `maintenance` container.

The configured schedules are:

```text
02:00 - Docker volume backup
03:00 - Docker registry and host maintenance
```

They are configured in `stacks/maintenance/docker-compose.yaml`:

```yaml
environment:
  TZ: Europe/Stockholm
  BACKUP_CRON: "0 2 * * *"
  MAINTENANCE_CRON: "0 4 * * *"
```

The backup runs before registry cleanup and Docker pruning so persistent data is backed up first.

The container entrypoint installs both schedules into its internal cron daemon when the container starts.

## Manual Test

After building and deploying the updated `infra-maintenance` image and stack, run:

```bash
docker exec maintenance /usr/local/bin/docker-volume-backup
```

A successful run should finish with:

```text
All done.
```

Verify the generated archives on the host with:

```bash
ls -lh /mnt/nas/backup/docker
```

## Logs

Scheduled backup output is written to the `maintenance` container's standard output and error streams.

Inspect recent output with:

```bash
docker logs maintenance
```

Follow the logs live with:

```bash
docker logs -f maintenance
```

## Retention

The retention period is configured in:

```text
scripts/docker_volume_backup.sh
```

The current value is:

```bash
RETENTION_DAYS=14
```

After each successful backup run, `.tar.gz` files older than the configured retention period are removed from:

```text
/mnt/nas/backup/docker
```

To change the retention period, update `RETENTION_DAYS` in the repository, rebuild the `infra-maintenance` image, and
redeploy the maintenance stack.

## Restoring a Volume

Create an empty Docker volume if necessary:

```bash
docker volume create my-restored-volume
```

Restore an archive using an ephemeral Alpine container:

```bash
docker run --rm \
  -v my-restored-volume:/volume \
  -v /mnt/nas/backup/docker:/backup:ro \
  alpine \
  sh -c "cd /volume && tar xzf /backup/<backup-file>.tar.gz"
```

For example:

```bash
docker run --rm \
  -v mongodb-data-volume:/volume \
  -v /mnt/nas/backup/docker:/backup:ro \
  alpine \
  sh -c "cd /volume && tar xzf /backup/mongodb-data-volume_2026-08-30.tar.gz"
```

Verify the restored files:

```bash
docker run --rm \
  -v my-restored-volume:/volume \
  alpine \
  ls -la /volume
```

## Database Volumes

`mongodb-data-volume` and `postgres-data-volume` are currently backed up as raw Docker volumes like the other configured
volumes.

This is intentionally the current backup strategy until database-native dumps are implemented.

Because the databases may be running while their volumes are archived, these backups do not provide the same consistency
guarantees as `mongodump`, `pg_dump`, or similar database-native backup mechanisms.

A future improvement can add database-native backups without removing the current volume backups until the replacement
has been verified.

## Troubleshooting

If the backup reports that `/mnt/nas` is not CIFS, verify the NAS mount on the host:

```bash
findmnt /mnt/nas
```

If a configured Docker volume is reported missing, check the runtime volume list:

```bash
docker volume ls --format '{{.Name}}' | sort
```

If writing to the NAS fails, verify that the host can create files under the backup directory:

```bash
touch /mnt/nas/backup/docker/.write-test
rm /mnt/nas/backup/docker/.write-test
```

If the scheduled backup does not run, inspect the maintenance container:

```bash
docker logs maintenance
```

and verify the installed cron configuration:

```bash
docker exec maintenance cat /etc/crontabs/root
```

## Recommendations

Periodically test restoring important backups into temporary Docker volumes.

Database-native backups should eventually be added for MongoDB and PostgreSQL, but the current raw-volume backups should
remain in place until those replacements have been implemented and restore-tested.

Large recreatable data such as Ollama model storage, CI runner state, logs, worktrees, registry image data, and
temporary/socket volumes are intentionally excluded from the backup set.
