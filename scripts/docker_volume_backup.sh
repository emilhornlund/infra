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
  "beszel-socket-volume"
  "beta-klurigo-service-uploads-volume"
  "klurigo-gh-runner-data-volume"
  "klurigo-gh-runner-tmp-volume"
  "mongodb-data-volume"
  "nginx-proxy-certs-volume"
  "nginx-proxy-html-volume"
  "nginx-proxy-vhost-volume"
  "pihole-dnsmasq-volume"
  "pihole-etc-volume"
  "portainer-data-volume"
  "prod-klurigo-service-uploads-volume"
  "redis-data-volume"
  "registry-auth-volume"
  "registry-certs-volume"
  "registry-data-volume"
  "vaultwarden-data-volume"
)

# 2) Destination directory on the NAS (make sure it's mounted):
BACKUP_DIR="/mnt/nas/backup/docker"

# Create destination if it doesn't exist
mkdir -p "$BACKUP_DIR"

# 3) Date stamp in YYYY-MM-DD
DATESTAMP=$(date +%F)

# 4) Loop over volumes
for VOL in "${VOLUMES[@]}"; do
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
