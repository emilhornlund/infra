# 🧱 Redis Stack

This stack deploys a Redis 8 instance using Docker Compose and Portainer GitOps, configured with password protection and persistent storage.

## 🐳 Service Overview

- **Image**: `redis:8.0.1`
- **Port**: Exposes `6379` for Redis clients
- **Volume**:
  - `redis-data-volume` → `/data` — persists Redis key-value data
- **Network**: Connected to the shared `core-network`
- **Command Override**:
  - Starts Redis with `--requirepass` using a password defined via environment secret

## 🔐 Required Secrets

This stack requires the following environment secret:

```env
REDIS_PASSWORD=<YOUR_REDIS_PASSWORD>
```

> Set this as an environment secret in Portainer before deployment.

## 📁 Files

- `docker-compose.yaml`: Defines the Redis container, volumes, and network

## 🛠 Portainer GitOps Configuration

- **Git Repository**: This repository's URL
- **Path**: `stacks/redis`
- **Auto Update**: Enable (interval or webhook)
- **Environment Secret**: `REDIS_PASSWORD`

> Ensure the `core-network` exists before deploying.

---

> Redis is used for fast in-memory key-value storage and supports features like pub/sub, expiration, and persistence — ideal for caching and real-time applications.
