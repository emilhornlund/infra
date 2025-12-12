# 🔐 Vaultwarden Stack

This stack deploys [Vaultwarden](https://github.com/dani-garcia/vaultwarden), a lightweight and self-hosted password manager compatible with the Bitwarden clients.

## 🐳 Service Overview

- **Image**: `vaultwarden/server:1.33.2-alpine`
- **Web UI**: Exposed on port 80 via `nginx-proxy` with automatic HTTPS via Let's Encrypt
- **Volumes**:
  - `vaultwarden-data-volume` → `/data` — persists vault data and configuration
- **Environment Variables**:
  - `TZ` — Sets timezone
  - `DOMAIN` — External URL of the instance (used for web vault, email links, etc.)
  - `VIRTUAL_HOST` / `LETSENCRYPT_HOST` / `VIRTUAL_PORT` — Used for reverse proxying with TLS
- **Network**: Connected to `core-network` for integration with proxy and other services

## 🔐 Required Secrets

No secrets required for this stack.

## 📁 Files

- `docker-compose.yaml`: Defines the Vaultwarden service with reverse proxy integration

## 🛠 Portainer GitOps Configuration

- **Git Repository**: This repository's URL
- **Path**: `stacks/vaultwarden`
- **Auto Update**: Enable (interval or webhook)

## 📝 Security Notes

- It's highly recommended to enable environment variables for SMTP, WebSocket support, and backup strategy depending on your usage
- Use HTTPS with a domain name (already configured with `LETSENCRYPT_HOST`) for secure access

> Ensure `core-network` and your reverse proxy (e.g. `nginx-proxy` and `acme-companion`) are set up before deploying this stack.

---

> Vaultwarden gives you secure, self-hosted access to your passwords, notes, and credentials using a trusted Bitwarden-compatible interface.
