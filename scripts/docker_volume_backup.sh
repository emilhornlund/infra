#!/usr/bin/env bash
#
# backup_docker_volumes.sh
#
# Backs up a list of Docker volumes into /mnt/nas/backup/docker,
# naming each file <volume>_<YYYY-MM-DD>.tar.gz

set -euo pipefail

# 1) List all the Docker volumes you want to back up here:
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

# 2) Destination directory on the NAS (make sure it's mounted):
BACKUP_DIR="/mnt/nas/backup/docker"

# Abort if the NAS is not mounted.
if ! mountpoint -q /mnt/nas; then
  echo "ERROR: /mnt/nas is not mounted. Aborting backup." >&2
  exit 1
fi

# Create destination if it doesn't exist.
mkdir -p "$BACKUP_DIR"

# 3) Date stamp in YYYY-MM-DD
DATESTAMP=$(date +%F)

# 4) Loop over volumes
for VOL in "${VOLUMES[@]}"; do
  if ! docker volume inspect "$VOL" >/dev/null 2>&1; then
    echo "ERROR: Docker volume '$VOL' does not exist. Aborting backup." >&2
    exit 1
  fi

  FILENAME="${VOL}_${DATESTAMP}.tar.gz"
  echo "Backing up volume '$VOL' → $BACKUP_DIR/$FILENAME"

  # Run an Alpine container to tar the volume
  docker run --rm \
    -v "${VOL}:/volume:ro" \
    -v "${BACKUP_DIR}:/backup" \
    alpine \
    sh -c "cd /volume && tar czf /backup/${FILENAME} ."
done

# 5) (Optional) Purge backups older than, say, 14 days:
RETENTION_DAYS=14
echo "Removing backups older than $RETENTION_DAYS days..."
find "$BACKUP_DIR" -type f -name "*.tar.gz" -mtime +$RETENTION_DAYS -exec rm {} \;

echo "All done."
