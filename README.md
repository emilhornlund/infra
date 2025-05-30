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
