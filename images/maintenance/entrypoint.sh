#!/bin/sh
set -eu

MAINTENANCE_CRON="${MAINTENANCE_CRON:-0 3 * * *}"

echo "Starting maintenance scheduler"
echo "Schedule: ${MAINTENANCE_CRON}"
echo "Timezone: ${TZ:-UTC}"
echo

printf '%s /usr/local/bin/maintenance >> /proc/1/fd/1 2>> /proc/1/fd/2\n' \
  "$MAINTENANCE_CRON" \
  > /etc/crontabs/root

exec crond -f -l 2
