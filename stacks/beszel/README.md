# 📊 Beszel Stack

This stack deploys [Beszel](https://www.beszel.dev) for lightweight server monitoring with Docker stats, historical data, and alerts, using Docker Compose and Portainer GitOps.

## 🐳 Service Overview

### Beszel Hub
- **Image**: `henrygd/beszel:0.17.0`
- **Ports**: Not exposed directly; proxied through nginx-proxy
- **Volume Mounts**:
  - `beszel-data-volume` → `/beszel_data` – persists hub configuration and user data
  - `beszel-socket-volume` → `/beszel_socket` – shared socket for agent communication
- **Health Check**: Monitors service availability every 120s
- **Proxy Support**: Accessible via `VIRTUAL_HOST` and `LETSENCRYPT_HOST`
- **Network**: Connected to external `core-network`

### Beszel Agent
- **Image**: `henrygd/beszel-agent:0.17.0`
- **Network Mode**: Host (required for system monitoring)
- **Volume Mounts**:
  - `beszel-agent-data-volume` → `/var/lib/beszel-agent` – persists metrics and historical data
  - `beszel-socket-volume` → `/beszel_socket` – shared socket for hub communication
  - `/var/run/docker.sock` → `/var/run/docker.sock:ro` – read-only Docker socket access
- **Health Check**: Monitors agent availability every 120s

## 🔐 Required Secrets

To enable agent authentication, define the following environment secrets:

```env
TOKEN=your_agent_token
PUBLIC_KEY=your_public_key
```

> Generate these from the Beszel hub interface after initial deployment and add them as environment secrets in Portainer.

## 📁 Files

- `docker-compose.yaml`: Defines both Beszel hub and agent services with volumes and networking
- `beszel.stack.env`: Hub environment variables for nginx-proxy integration
- `beszel-agent.stack.env`: Agent environment variables for hub communication

## 🛠 Portainer GitOps Configuration

- **Git Repository**: This repository's URL
- **Path**: `stacks/beszel`
- **Auto Update**: Enable (interval or webhook)
- **Environment Secrets**: `TOKEN`, `PUBLIC_KEY`

> Ensure that the `core-network` exists before deploying this stack so that nginx-proxy can correctly route traffic to the Beszel hub interface.

---

> Beszel provides simple, lightweight server monitoring with a hub-agent architecture for tracking system and container metrics.
