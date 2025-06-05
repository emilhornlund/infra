# 📺 Plex Stack

This stack deploys [Plex Media Server](https://www.plex.tv/), a self-hosted platform to stream movies, shows, music, and personal media collections to various devices.

## 🐳 Service Overview

- **Image**: `lscr.io/linuxserver/plex:1.41.7`
- **Web UI**: Exposed via `nginx-proxy` and secured with Let's Encrypt (port 80 internally)
- **Volumes**:
  - `/mnt/media/TV` → `/tv` — TV show library
  - `/mnt/media/Movies` → `/movies` — Movie library
  - `plex-config-volume` → `/config` — Plex configuration and metadata
- **Devices**: GPU passthrough via `/dev/dri`
- **Group Access**: Adds user to `render` group for GPU access
- **Environment Variables**:
  - `PLEX_CLAIM` — Optional token for initial Plex server registration
  - `VIRTUAL_HOST`, `VIRTUAL_PORT`, `LETSENCRYPT_HOST` — For reverse proxying
  - `TZ`, `PUID`, `PGID` — Local timezone and permissions
- **Network**: Connected to `core-network`

## 🔐 Optional Secret

```env
PLEX_CLAIM=<YOUR_OPTIONAL_PLEX_CLAIM>
```

> You can obtain a claim token at [https://www.plex.tv/claim](https://www.plex.tv/claim) to register the server with your account.

## 🛠 Portainer GitOps Configuration

- **Git Repository**: This repository’s URL
- **Path**: `stacks/plex`
- **Auto Update**: Enable (interval or webhook)

## 🖥 Hardware Acceleration

To enable hardware transcoding, ensure:

- `/dev/dri` exists on the host (for Intel Quick Sync or similar)
- The container has `render` group access
- Your Plex settings enable hardware transcoding

---

> Plex turns your server into a powerful personal streaming platform accessible from any device.
