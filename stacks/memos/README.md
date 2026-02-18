# 📝 Memos Stack

This stack deploys [Memos](https://www.usememos.com/), a lightweight, self-hosted memo hub for capturing and sharing thoughts, with PostgreSQL backend support using Docker Compose and Portainer GitOps.

## 🐳 Service Overview

- **Image**: `neosmemo/memos:0.25.3`
- **Port**: `15330:80` (host:container)
- **Volume**:
  - `memos-volume` → `/var/opt/memos` – persists Memos data and configuration
- **Network**: Connected to the external `core-network`
- **Health Check**: HTTP check on port 80 to ensure service availability
- **Proxy Support**: Accessible via `VIRTUAL_HOST` for nginx-proxy integration

## 🔐 Required Secrets

This stack requires the following environment secret:

```env
MEMOS_DSN=<YOUR_POSTGRES_CONNECTION_STRING>
```

> Example: `postgres://username:password@postgres:5432/memos?sslmode=disable`
> Set this as an environment secret in Portainer before deployment.

## 📁 Files

- `docker-compose.yaml`: Defines the Memos service, volume, and network configuration
- `stack.env`: Template file that references environment secrets and configuration from Portainer

## 🛠 Portainer GitOps Configuration

- **Git Repository**: This repository's URL
- **Path**: `stacks/memos`
- **Auto Update**: Enable (interval or webhook)
- **Environment Secret**: `MEMOS_DSN`

> Ensure the `core-network` exists before deploying this stack so that nginx-proxy can correctly route traffic to the Memos interface.

## 🔗 Access

- **Web Interface**: Access Memos at `https://memos.emilhornlund.com` (via nginx-proxy)
- **Local Access**: Available at `http://localhost:15330`

## 🗄️ Database Setup

Before deploying this stack, ensure you have:
1. A PostgreSQL database instance running (see [postgres stack](../postgres))
2. Created a dedicated database for Memos (e.g., `memos`)
3. Configured the `MEMOS_DSN` environment secret with proper connection credentials

---

> Memos is a privacy-first, lightweight note-taking service that supports markdown, tagging, and quick note capture. Perfect for personal knowledge management and daily journaling.

