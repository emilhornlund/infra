# 🧠 Quiz Service Stack

This stack defines two deployment variants (`beta` and `prod`) for the backend API of the quiz game platform, built with NestJS. It supports real-time updates via Server-Sent Events (SSE), integrates with Redis and MongoDB, and fetches media from Pexels.

## 🐳 Service Overview

- **Image**: `emils-nuc-server:5000/quiz-service:<tag>`
- **Port**: Internally runs on port `8080`
- **Environment**:
  - Uses `NODE_ENV` to distinguish environments (`beta` or `production`)
  - Uses `SERVER_ALLOW_ORIGIN` to set allowed CORS domains
  - Connects to Redis and MongoDB using environment config
  - Stores uploaded files in separate named volumes per environment
- **Networks**: Both services connect to the shared `core-network`

## 🧪 Beta Deployment

- **Compose file**: `docker-compose.beta.yaml`
- **Allowed Origin**: `https://beta.klurigo.com`
- **Redis DB**: `1`
- **MongoDB DB**: `klurigo_beta`
- **Uploads Volume**: `beta-quiz-service-uploads-volume`

## 🚀 Production Deployment

- **Compose file**: `docker-compose.prod.yaml`
- **Allowed Origins**: `https://quiz.emilhornlund.com`, `https://klurigo.com`
- **Redis DB**: `0`
- **MongoDB DB**: `klurigo_prod`
- **Uploads Volume**: `prod-quiz-service-uploads-volume`

## 🔐 Required Secrets

Set these in Portainer or your environment before deploying:

```env
REDIS_PASSWORD=<YOUR_REDIS_PASSWORD>
MONGODB_USERNAME=<YOUR_MONGODB_USERNAME>
MONGODB_PASSWORD=<YOUR_MONGODB_PASSWORD>
JWT_SECRET=<YOUR_JWT_SECRET>
PEXELS_API_KEY=<YOUR_PEXELS_API_KEY>
```

> Define these as secrets in Portainer before deploying.

## 📁 Files

- `docker-compose.beta.yaml`: For beta deployments
- `docker-compose.prod.yaml`: For production deployments
- `stack.env`: Common environment variables shared between variants

## 🛠 Portainer GitOps Configuration

To deploy this stack with Portainer:

- **Git Repository**: This repository's URL
- **Path**: `stacks/quiz-service`
- **Auto Update**: Enable (interval or webhook)
- **Environment Secrets**: Set all required secrets listed above

> Make sure `core-network`, MongoDB, and Redis services are up and accessible by their hostnames (`mongodb`, `redis`).

---

> This service handles game logic, player interactions, and real-time event delivery for the full-stack quiz platform.
