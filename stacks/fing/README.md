# 📡 Fing Agent Stack

This stack deploys the [Fing Agent](https://www.fing.com/fing-agent) for local network monitoring using Docker Compose and Portainer GitOps.

## 🐳 Service Overview

- **Image**: `fing/fing-agent:1.1.1`
- **Port**: `44444` (used for device communication and management)
- **Volume**: Persists Fing data under `fing-data-volume`
- **Network Mode**: `host` (required for low-level network visibility)
- **Capabilities**: Adds `NET_ADMIN` for enhanced network scanning

## 📁 Files

- `docker-compose.yaml`: Docker Compose definition for the Fing Agent service.
- No .env file is needed — secrets are passed via Portainer.

## 🔒 Permissions

This container requires elevated privileges:
- `host` network mode
- `NET_ADMIN` capability

Make sure you understand the security implications before deploying in untrusted environments.

## 🛠 Portainer GitOps Configuration

To deploy this stack with Portainer:
- **Git Repository**: Use the URL of this repository
- **Path**: `stacks/fing`
- **Auto Update**: Enable (interval or webhook)

---

> Fing Agent provides powerful network scanning and monitoring. Use it to keep track of devices and detect new ones joining your network.
