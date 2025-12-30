# Docker Volume Backup

Usage example (run manually):
```bash
sudo /usr/local/bin/docker_volume_backup.sh
```

Backs up named Docker volumes to a NAS-mounted directory by spinning up a temporary container for each volume, archiving its contents into a timestamped `.tar.gz` file under `/mnt/nas/backup/docker`, and then (optionally) cleaning up older archives beyond a set retention window. The goal is to automate reliable, consistent snapshots of your container data—ideal for scheduled nightly backups and straightforward restores.

## Prerequisites

1. **Ubuntu Server 24.04** running on your NUC.  
2. **Docker** installed and running (the volumes you want to back up must already exist).  
3. A **NAS** accessible via CIFS/Samba (e.g., Synology, QNAP, TrueNAS, etc.).  
4. The server’s network can reach the NAS (e.g., both on the same LAN).  
5. Basic familiarity with editing files (`nano`, `vim`, etc.) and using `root`/`sudo`.  

## NAS Mount Configuration

We assume your NAS share is available at `//192.168.0.65/NUC` and you want to mount it at `/mnt/nas`. Adjust IP, share name, mount point, UID/GID, and SMB version as needed for your environment.

### 1. Create Mount Point

```bash
sudo mkdir -p /mnt/nas
```

This directory will serve as the mount point for your NAS backup share.

### 2. Create Credentials File

It’s best practice to store your CIFS/Samba credentials in a restricted file so that your password isn’t world-readable.

1. Create (or open) a credentials file:

   ```bash
   sudo nano /etc/smbcredentials-nas
   ```

2. Add the following lines, replacing `<YOUR_USERNAME>` and `<YOUR_PASSWORD>`:

   ```
   username=<YOUR_USERNAME>
   password=<YOUR_PASSWORD>
   ```

3. Save and exit (`Ctrl+O`, `Enter`, `Ctrl+X` in nano).

4. Restrict permissions so that only root can read it:

   ```bash
   sudo chmod 600 /etc/smbcredentials-nas
   ```

### 3. Edit `/etc/fstab`

Add a new line to `/etc/fstab` so that the NAS share auto-mounts at boot (or on demand). Open `/etc/fstab` with your editor:

```bash
sudo nano /etc/fstab
```

Append the following line (all on one line), adjusting IP, share name, and options as needed:

```text
//192.168.0.65/NUC   /mnt/nas   cifs   credentials=/etc/smbcredentials-nas,uid=1000,gid=1000,vers=3.1.1,iocharset=utf8,file_mode=0660,dir_mode=0770,x-systemd.automount,_netdev,nofail,serverino   0 0
```

* `uid=1000,gid=1000` makes files on the NAS appear owned by your primary user (UID 1000). Change these if your primary user is different.
* `vers=3.1.1` forces SMB v3.1.1—adjust if your NAS only supports an older version (e.g., `vers=3.0` or `vers=2.1`).
* `iocharset=utf8,file_mode=0660,dir_mode=0770` ensure proper permissions.
* `_netdev` delays the mount until network is up.
* `nofail` means the boot will continue even if the NAS is unreachable.
* `x-systemd.automount` lets systemd handle the automatic on-access mounting (so the share is only mounted when you first access `/mnt/nas`).

Save and exit (`Ctrl+O`, `Enter`, `Ctrl+X`).

### 4. Mount the Share

Test the new `/etc/fstab` entry:

```bash
sudo mount -a
```

Verify that it’s mounted:

```bash
mount | grep /mnt/nas
ls -ld /mnt/nas
```

If everything succeeded, you should see your NAS share at `/mnt/nas` with correct ownership/permissions.

## Script Installation & Configuration

The backup script is located at `scripts/docker_volume_backup.sh`. It loops through a hardcoded array of volume names, tars each one inside an Alpine container, and writes the `.tar.gz` into `/mnt/nas/backup/docker`.

### 1. Place the Script

1. Copy `docker_volume_backup.sh` into `/usr/local/bin/` (or a directory of your choosing, e.g., `/opt/scripts/`):

   ```bash
   sudo cp scripts/docker_volume_backup.sh /usr/local/bin/docker_volume_backup.sh
   ```

2. If you prefer a different path, just be sure to update any references (e.g., in your cron job) accordingly.

### 2. Make It Executable

```bash
sudo chmod +x /usr/local/bin/docker_volume_backup.sh
```

Confirm that it’s executable:

```bash
ls -l /usr/local/bin/docker_volume_backup.sh
# Expected output should show -rwxr-xr-x or similar
```

### 3. Configure the Volume List

Open the script in your editor:

```bash
sudo nano /usr/local/bin/docker_volume_backup.sh
```

Near the top, you will see a `VOLUMES=( ... )` array. Replace the placeholder names with the exact names of your Docker volumes (as shown by `docker volume ls`). For example:

```bash
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
```

* Make sure each name exactly matches what appears under `docker volume ls`.
* If you only want to back up a subset, remove any volumes from the list that you don’t need.

Save and exit when done.

### 4. Verify the NAS Backup Directory

The script expects a target directory of `/mnt/nas/backup/docker`. Create it now (the script will also do this at runtime, but it’s good to ensure correct ownership/permissions ahead of time):

```bash
sudo mkdir -p /mnt/nas/backup/docker
sudo chown youruser:youruser /mnt/nas/backup/docker
# Replace "youruser:youruser" with the UID/GID matching your Docker host user if needed.
```

## Manual Test Run

Before scheduling with cron, run the script once manually to make sure it works:

```bash
sudo /usr/local/bin/docker_volume_backup.sh
```

You should see output similar to:

```
Backing up volume 'acme-volume' → /mnt/nas/backup/docker/acme-volume_2025-06-05.tar.gz
...
Removing backups older than 14 days...
All done.
```

Then verify the resulting `.tar.gz` files:

```bash
ls -lh /mnt/nas/backup/docker
```

If you see one `.tar.gz` per volume and today’s date in each filename, the script is working correctly.

## Scheduling via Cron

To automate nightly backups, add a cron entry under the `root` user (so Docker permissions and NAS mount access are guaranteed).

### 1. Edit Root’s Crontab

```bash
sudo crontab -e
```

Add the following line to run the script every day at 03:00 (3 AM):

```cron
0 3 * * * /usr/local/bin/docker_volume_backup.sh >> /var/log/docker_volume_backup.log 2>&1
```

* `0 3 * * *` → at 03:00 every day.
* `>> /var/log/docker_volume_backup.log 2>&1` → append both stdout and stderr to a log file for troubleshooting.

Save and exit your editor.

### 2. Verify Cron Is Running

Check that the cron daemon is active:

```bash
sudo systemctl status cron
```

Look for entries in `/var/log/syslog` to confirm that cron is triggering your job:

```bash
sudo tail -n 20 /var/log/syslog | grep CRON
```

You should see something like:

```
Jun  5 03:00:01 nuc-server CRON[12345]: (root) CMD (/usr/local/bin/docker_volume_backup.sh >> /var/log/docker_volume_backup.log 2>&1)
```

## Retention Policy

By default, this script keeps 14 days’ worth of backups. To change that:

1. Open `/usr/local/bin/docker_volume_backup.sh` in your editor.
2. Locate the line:

   ```bash
   RETENTION_DAYS=14
   ```
3. Change `14` to however many days you want to keep backups. For instance, for a 30-day retention:

   ```bash
   RETENTION_DAYS=30
   ```
4. Save and exit.

At each run, any `*.tar.gz` file under `/mnt/nas/backup/docker` older than `RETENTION_DAYS` will be removed automatically.

## Restoring a Volume

If you ever need to restore a specific Docker volume from a backup:

1. **Create a new (empty) volume** (if you want to overwrite an existing one, remove it with `docker volume rm <VOLUME_NAME>` first):

   ```bash
   docker volume create my_restored_volume
   ```

2. **Use an ephemeral container** to extract the backup archive into the new volume. For example, to restore `mongodb-data-volume` from `2025-06-05`:

   ```bash
   docker run --rm \
     -v mongodb-data-volume:/volume \
     -v /mnt/nas/backup/docker:/backup \
     alpine \
     sh -c "cd /volume && tar xzf /backup/mongodb-data-volume_2025-06-05.tar.gz"
   ```

3. **Verify** the data is in place by inspecting or running a container that uses that volume. For example:

   ```bash
   docker run --rm -v mongodb-data-volume:/volume alpine ls -l /volume
   ```

---

## Troubleshooting

* **Permission denied writing to `/mnt/nas/backup/docker`**:

  * Ensure the CIFS mount in `/etc/fstab` uses `uid=1000,gid=1000` (or your Docker host user’s actual UID/GID) so that Docker can write to the directory. If files still appear as `root:root`, verify that those numbers match the user who runs the backup script.
  * Alternatively, temporarily test by running `sudo chown -R root:root /mnt/nas/backup/docker` and see if the script works as root.

* **`docker: command not found` inside cron**:

  * Cron jobs for `root` typically have `/usr/bin` and `/usr/local/bin` in PATH, but if not, you can specify the full path to `docker` (e.g., `/usr/bin/docker run ...`) inside the script, or add at top of the script:

    ```bash
    export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
    ```

* **NAS is not mounted at boot**:

  * Confirm the `//192.168.0.65/NUC` share is reachable.
  * Check `dmesg | grep CIFS` or `journalctl -u systemd-fstab@mnt-nas.mount` for errors.
  * Ensure network is up before mounting (`_netdev` option helps, but if the NIC is managed by NetworkManager, you may need `noauto,x-systemd.automount` or a `systemd` service ordering tweak).

* **Backups appear empty or incomplete**:

  * Ensure Docker volumes are not in active use or being written to while tarring. For very active databases, consider using a database dump (`mysqldump`, `pg_dump`, etc.) instead of raw file tar.
  * Check the size of the resulting `.tar.gz`—if it’s unusually small, the volume might be empty or permissions may prevent reading.

---

## Notes & Best Practices

1. **Test Restores Periodically**
   Schedule a monthly test where you restore one of the volumes to a throwaway volume, spin up a container, and verify data integrity.

2. **Handle Active Databases Gracefully**

   * For MySQL/MariaDB:

     ```bash
     docker exec <mysql_container> sh -c 'exec mysqldump --all-databases --single-transaction --quick --lock-tables=false' > /mnt/nas/backup/docker/mysql_dump_$(date +%F).sql
     ```

     Then back up the SQL file instead of raw `/var/lib/mysql` files.
   * For PostgreSQL:

     ```bash
     docker exec <postgres_container> sh -c 'exec pg_dumpall --clean --if-exists' > /mnt/nas/backup/docker/pg_dump_$(date +%F).sql
     ```

3. **Consider Incremental or De-duplicating Backups**
   If your volumes are very large and change only slightly day-to-day, tools like Restic or Borg can save space and speed by only storing the diff. You can still mount `/mnt/nas` and use it as your backup repository.

4. **Security**

   * Store credentials in a file with `chmod 600`.
   * Do not hardcode passwords in `/etc/fstab` or scripts.
   * Consider using a dedicated “backup” user on your NAS with write-only access to the backup share.

5. **Monitoring & Alerts**

   * Periodically check `/var/log/docker_volume_backup.log` for errors.
   * Consider setting up an alert (e.g., via email or Slack webhook) if the cron job exits nonzero.
