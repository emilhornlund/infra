# 🧱 Redis Stack

This stack deploys a [Redis 8](https://hub.docker.com/_/redis) instance along with [Redis Commander](https://github.com/joeferner/redis-commander) web interface using Docker Compose and Portainer GitOps, configured with password protection and persistent storage.

## 🐳 Service Overview

### Redis

- **Image**: `redis:8.0.1`
- **Port**: `6379:6379` (host:container)
- **Volume**:
  - `redis-data-volume` → `/data` — persists Redis key-value data
- **Network**: Connected to the shared `core-network`
- **Command Override**: Starts Redis with `--requirepass` using a password defined via environment secret
- **Health Check**: Uses `redis-cli ping` to verify availability

### Redis Commander

- **Image**: `ghcr.io/joeferner/redis-commander:0.9.1`
- **Port**: `15428:80` (host:container)
- **Network**: Connected to `core-network` for Redis access
- **Health Check**: HTTP check on port 80 to ensure web interface is responsive
- **Dependencies**: Depends on the `redis` service
- **Databases**: Provides browsing access to all 16 Redis databases (db0–db15)

## 🔐 Required Secrets

This stack requires the following environment secret:

```env
REDIS_PASSWORD=<YOUR_REDIS_PASSWORD>
```

> Set this as an environment secret in Portainer before deployment.

## 📁 Files

- `docker-compose.yaml`: Defines the Redis and Redis Commander containers, volumes, and network

## 🛠 Portainer GitOps Configuration

- **Git Repository**: This repository's URL
- **Path**: `stacks/redis`
- **Auto Update**: Enable (interval or webhook)
- **Environment Secret**: `REDIS_PASSWORD`

> Ensure the `core-network` exists before deploying.

## 🔗 Access

- **Redis**: Connect via `localhost:6379` or from other containers via `redis:6379`
- **Redis Commander**: Access the web interface at `http://localhost:15428`

---

> Redis is used for fast in-memory key-value storage and supports features like pub/sub, expiration, and persistence — ideal for caching and real-time applications. Redis Commander provides a convenient web UI for browsing and managing all Redis databases.
