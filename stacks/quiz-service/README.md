# 🧠 Quiz Service Stack

This stack deploys the backend API for the quiz game platform, built with NestJS. It supports real-time game updates via Server-Sent Events (SSE) and integrates with Redis, MongoDB, and Pexels for media content.

## 🐳 Service Overview

- **Image**: `192.168.0.65:9500/emilhornlund/quiz-service:<tag>`
- **Port**: Runs internally on port `8080` (proxied externally via reverse proxy if needed)
- **Environment**:
  - Uses `production` mode (`NODE_ENV`)
  - Depends on Redis and MongoDB (defined by host/port)
  - Stores image uploads in `quiz-service-uploads-volume`
- **Network**: Connected to `core-network` for inter-service communication

## 🔐 Required Secrets

This stack requires the following environment secrets:

```env
REDIS_PASSWORD=<YOUR_REDIS_PASSWORD>
MONGODB_USERNAME=<YOUR_MONGODB_USERNAME>
MONGODB_PASSWORD=<YOUR_MONGODB_PASSWORD>
JWT_SECRET=<YOUR_JWT_SECRET>
PEXELS_API_KEY=<YOUR_PEXELS_API_KEY>
```

> Define these as secrets in Portainer before deploying.

## 📁 Files

- `docker-compose.yaml`: Defines the quiz service container, volume for uploads, and network settings.

## 🛠 Portainer GitOps Configuration

To deploy this stack with Portainer:

- **Git Repository**: This repository's URL
- **Path**: `stacks/quiz-service`
- **Auto Update**: Enable (interval or webhook)
- **Environment Secrets**: Set all required secrets listed above

> Make sure `core-network`, MongoDB, and Redis services are up and accessible by their hostnames (`mongodb`, `redis`).

---

> This service handles game logic, player interactions, and real-time event delivery for the full-stack quiz platform.
