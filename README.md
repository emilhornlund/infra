# 🚀 Infrastructure GitOps Repository

This repository defines the declarative infrastructure for self-hosted stacks using Docker Compose and Portainer GitOps automation.

## 📦 Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Portainer](https://www.portainer.io/) with GitOps support enabled

## 📁 Folder Structure

```
infra/
├── stacks/
│   ├── myapp/
│   │   └── docker-compose.yaml
└── shared/
```

Each stack folder contains its own `docker-compose.yaml` and optional `.env` file. These stacks are deployed and updated via Portainer using GitOps.

## 🌐 Shared Network: `core-network`

Almost all services in this GitOps repository are connected via a common Docker bridge network called `core-network`. This allows containers to communicate with each other across stacks and is required for reverse proxying, database access, and service discovery.

> ⚠️ **Important:** You must create the `core-network` **before deploying any stacks** that depend on it.

### 🔧 Creating the `core-network`

If you don’t already have the network, or want to reset it:

```bash
# Remove any existing copy (only do this while all related stacks are stopped)
docker network rm core-network

# Create it again with a custom subnet and gateway
docker network create \
  --driver bridge \
  --subnet 172.20.0.0/16 \
  --gateway 172.20.0.1 \
  core-network
```

This ensures all services can join the same virtual network and communicate by container name (e.g. `mongodb`, `nginx-proxy`, etc.).

> You only need to do this once per host.

## 🚦 GitOps with Portainer

Each stack is configured in Portainer as follows:
- **Git Repository**: This repository's URL
- **Repository Reference**: `refs/heads/main`
- **Path**: e.g. `stacks/myapp`
- **Auto Update**: Enabled (interval or webhook)

Changes to Compose files in this repository will automatically trigger stack updates in Portainer.

## ✅ Best Practices

- Keep each stack self-contained with its own `.env` file if needed
- Avoid committing sensitive data or secrets
- Use meaningful commit messages to track configuration changes
- Test changes locally using `docker-compose` before pushing

## 📦 Managed Services

This GitOps repository manages the following self-hosted services using Docker Compose and Portainer.

### 📡 [Fing Agent](./stacks/fing)
A containerized Fing Agent for local network scanning and device monitoring.

- Uses `fing/fing-agent` image
- Runs with `NET_ADMIN` capability and `host` network mode for low-level access
- Exposes port `44444`
- Persists data in a named volume (`fing-data-volume`)
- Ideal for discovering and tracking devices on your LAN

### 🏃‍♂️ [GitHub Runner](./stacks/github-runner)
A self-hosted GitHub Actions runner container for automating CI/CD workflows.

- Uses `myoung34/github-runner`
- Executes jobs for the `quiz` repository
- Requires a GitHub PAT as an environment secret

### 🍃 [MongoDB](./stacks/mongodb)
A containerized MongoDB 8.0 instance for development and local service usage.

- Uses the official `mongo` image
- Exposes port `27017`
- Root credentials loaded via environment secrets
- Persistent data stored in a named volume (`mongodb-data-volume`)
- Connected to external network `core-network`

### 🌐 [Nginx Proxy](./stacks/nginx-proxy)
An automated reverse proxy with HTTPS support using Let's Encrypt DNS-01 challenges via Cloudflare.

- Uses `nginxproxy/nginx-proxy` and `nginxproxy/acme-companion` images
- Exposes ports 80 and 443
- Automatically issues and renews SSL certificates
- Certificates and ACME data stored in named volumes `nginx-proxy-certs-volume` and `acme-volume`
- Proxies any container using `VIRTUAL_HOST` and `LETSENCRYPT_HOST` environment variables

### 🧿 [Pi-hole](./stacks/pihole)
A local DNS-level ad blocker for network-wide ad and tracker filtering.

- Uses `pihole/pihole` image
- Exposes DNS ports `53/tcp` and `53/udp`
- Joins `core-network` with static IP `172.20.0.8`
- Web interface proxied via `nginx-proxy` using `VIRTUAL_HOST` and `LETSENCRYPT_HOST`
- Admin password set using the `PIHOLE_PASSWORD` environment secret

### 🧭 [Portainer](./stacks/portainer)
A web-based management UI for Docker environments.

- Uses `portainer/portainer-ce` image
- Web interface is proxied via `nginx-proxy` using `VIRTUAL_HOST` and `LETSENCRYPT_HOST`
- Stores configuration in the `portainer-data-volume` named volume
- Connected to `core-network` for integrated reverse proxy access

### 🧠 [Quiz Service](./stacks/quiz-service)
The backend API for a full-stack real-time quiz game platform.

- Uses `emilhornlund/quiz-service` image
- Connects to Redis and MongoDB
- Stores user uploads in `quiz-service-uploads-volume`
- Requires secrets for Redis, MongoDB, JWT auth, and Pexels integration
- Connected to `core-network` for service discovery

### 🧠 [Quiz](./stacks/quiz)
The frontend web interface for the quiz game platform, built with React and Vite.

- Uses `emilhornlund/quiz` image
- Communicates with the `quiz-service` backend over internal API
- Web interface exposed via `nginx-proxy` using `VIRTUAL_HOST` and `LETSENCRYPT_HOST`
- Connected to `core-network` for service integration

### 🧱 [Redis](./stacks/redis)
An in-memory key-value data store used by services like `quiz-service` for caching and pub/sub messaging.

- Uses `redis` image
- Exposes port `6379` for Redis clients
- Requires `REDIS_PASSWORD` environment secret
- Persists data in `redis-data-volume`
- Connected to `core-network` for service-to-service communication

### 📦 [Private Docker Registry](./stacks/registry)
A secure private registry for hosting Docker images with HTTPS and basic auth.

- Uses `registry` image
- Exposes port `5000` for Docker push/pull
- Requires custom TLS cert and CA trust
- Stores credentials in `registry-auth-volume`
- Persists images in `registry-data-volume`
- Connected to `core-network` for internal accessibility

### 🔐 [Vaultwarden](./stacks/vaultwarden)
A lightweight self-hosted password manager compatible with Bitwarden clients.

- Uses `vaultwarden/server` image
- Web interface exposed via `nginx-proxy` with HTTPS using Let's Encrypt
- Persists data in `vaultwarden-data-volume`
- Configured with domain `vault.emilhornlund.com`
- Connected to `core-network` for proxy and service integration
