# 🌐 Nginx Proxy Stack

This stack deploys an automated reverse proxy setup using [nginx-proxy](https://github.com/nginx-proxy/nginx-proxy) and [acme-companion](https://github.com/nginx-proxy/acme-companion) for automatic HTTPS with Let's Encrypt via DNS-01 challenges (Cloudflare).

## 🐳 Service Overview

- **Images**:
  - `nginxproxy/nginx-proxy:1.7` – reverse proxy engine
  - `nginxproxy/acme-companion:2.6` – manages automatic Let's Encrypt SSL certificates
- **Exposed Ports**:
  - `80` for HTTP
  - `443` for HTTPS
- **Volumes**:
  - `/var/run/docker.sock` – for detecting running containers
  - `nginx-proxy-certs-volume` – stores SSL certificates
  - `nginx-proxy-html-volume` – custom HTML content
  - `nginx-proxy-vhost-volume` – per-virtualhost config
  - `acme-volume` – stores ACME state and certificate metadata
- **Network**: Uses external `core-network` to connect with other containers

## 🔐 Required Secrets

To issue certificates with Cloudflare DNS, the following environment secrets are required:

```env
CLOUDFLARE_EMAIL=you@example.com
CLOUDFLARE_KEY=your_cloudflare_global_api_key
```

> These must be defined in Portainer as environment secrets.

## 📁 Files

- `docker-compose.yaml`: Defines the proxy and companion services, named volumes, and external network
- No `.env` file is needed — secrets are passed via Portainer

## 🛠 Portainer GitOps Configuration

- **Git Repository**: This repository's URL
- **Path**: `stacks/nginx-proxy`
- **Auto Update**: Enable (interval or webhook)
- **Environment Secrets**:
  - `CLOUDFLARE_EMAIL`
  - `CLOUDFLARE_KEY`

## 📝 Usage

To automatically proxy another container:

- Attach it to the `core-network`
- Set these environment variables in the target container:

  ```env
  VIRTUAL_HOST=subdomain.example.com
  LETSENCRYPT_HOST=subdomain.example.com
  ```

Certificates will be automatically issued and renewed using Cloudflare DNS-01 validation.

> Make sure the `core-network` exists before deploying the stack.

---

> This setup provides a robust, automated reverse proxy with HTTPS for your self-hosted services using only Docker and GitOps.
