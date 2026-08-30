#!/bin/sh
set -eu

BACKUP_CRON="${BACKUP_CRON:-0 2 * * *}"
MAINTENANCE_CRON="${MAINTENANCE_CRON:-0 3 * * *}"

echo "Starting maintenance scheduler"
echo "Backup schedule: ${BACKUP_CRON}"
echo "Maintenance schedule: ${MAINTENANCE_CRON}"
echo "Timezone: ${TZ:-UTC}"
echo

{
  printf '%s /usr/local/bin/docker-volume-backup >> /proc/1/fd/1 2>> /proc/1/fd/2\n' \
    "$BACKUP_CRON"

  printf '%s /usr/local/bin/maintenance >> /proc/1/fd/1 2>> /proc/1/fd/2\n' \
    "$MAINTENANCE_CRON"
} > /etc/crontabs/root

exec crond -f -l 2
