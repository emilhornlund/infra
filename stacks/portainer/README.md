# 🧭 Portainer Stack

This stack deploys the [Portainer Community Edition](https://www.portainer.io/) for managing Docker environments through a web-based UI, using Docker Compose and Portainer GitOps.

## 🐳 Service Overview

- **Image**: `portainer/portainer-ce:2.30.1-alpine`
- **Ports**: Not exposed directly; proxied through nginx-proxy
- **Volume Mounts**:
  - `/var/run/docker.sock` – enables control of Docker on the host
  - `portainer-data-volume` → `/data` – persists Portainer settings and state
- **Proxy Support**: Accessible via `VIRTUAL_HOST` and `LETSENCRYPT_HOST`
- **Network**: Connected to external `core-network`

## 🛠 Portainer GitOps Configuration

To deploy this stack with Portainer:

- **Git Repository**: This repository's URL
- **Path**: `stacks/portainer`
- **Auto Update**: Enable (interval or webhook)

> Ensure that the `core-network` exists before deploying this stack so that nginx-proxy can correctly route traffic to the Portainer interface.

---

> Portainer provides a lightweight and intuitive UI to manage containers, images, volumes, networks, and more.
