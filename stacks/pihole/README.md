# 🧿 Pi-hole Stack

This stack deploys [Pi-hole](https://pi-hole.net/) as a local DNS-level ad blocker using Docker Compose and Portainer GitOps.

## 🐳 Service Overview

- **Image**: `pihole/pihole:2025.05.1`
- **Ports**:
  - `53/tcp` and `53/udp` for DNS
- **Volume Mounts**:
  - `pihole-etc-volume` → `/etc/pihole`
  - `pihole-dnsmasq-volume` → `/etc/dnsmasq.d`
- **Network**: Joins `core-network` with static IP `172.20.0.8`
- **Proxy Support**: Exposes HTTP interface via `VIRTUAL_HOST` and `LETSENCRYPT_HOST` for use with nginx-proxy

## 🔐 Required Secret

To set the Pi-hole web interface password, define the following environment secret:

```env
PIHOLE_PASSWORD=your_admin_password
```

This must be added as an environment secret in Portainer.

## 🛠 Portainer GitOps Configuration

To deploy this stack with Portainer:

- **Git Repository**: This repository's URL
- **Path**: `stacks/pihole`
- **Auto Update**: Enable (interval or webhook)
- **Environment Secret**: `PIHOLE_PASSWORD`

> Make sure the `core-network` exists and has the correct subnet to allow Pi-hole to use static IP `172.20.0.8`.

---

> Pi-hole helps block ads and trackers across your entire network by acting as a DNS sinkhole.
