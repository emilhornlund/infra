# 🌐 Cloudflare DDNS Stack

This stack deploys [favonia/cloudflare-ddns](https://github.com/favonia/cloudflare-ddns), a minimal and reliable dynamic DNS updater that syncs your IP with Cloudflare.

## 🐳 Service Overview

- **Image**: `favonia/cloudflare-ddns:1.15.1`
- **Purpose**: Automatically updates DNS A/AAAA records for your domains at Cloudflare
- **Environment Variables**:
  - `CLOUDFLARE_API_TOKEN` — Personal access token with DNS edit permissions
  - `DOMAINS` — Comma-separated list of domains/subdomains to update (e.g., `example.com,www.example.com`)

## 🔐 Required Secrets

Make sure to provide the following securely in Portainer:

```env
CLOUDFLARE_API_TOKEN=<YOUR_CLOUDFLARE_API_TOKEN>
```

## 📁 Files

- `docker-compose.yaml`: Defines the Cloudflare DDNS service

## 🛠 Portainer GitOps Configuration

- **Git Repository**: This repository's URL
- **Path**: `stacks/cloudflare-ddns`
- **Auto Update**: Enable (interval or webhook)

## 📝 Domain Configuration

- Add the desired A/AAAA records for your domains in Cloudflare DNS
- Ensure the token has Zone DNS Edit permissions
- The container automatically detects IP changes and updates records

---

> This service ensures your domains always point to your current public IP address.
