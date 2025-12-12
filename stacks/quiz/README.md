# 🧠 Quiz Stack

This stack deploys the frontend web application for the quiz game platform, built with React, Vite, and Storybook. It now supports both beta and production deployments with distinct environment configurations.

## 🐳 Service Overview

- **Image**: `emils-nuc-server:5000/quiz:<tag>`
- **Port**: Exposes port `80` internally (proxied via nginx-proxy)
- **Environment Variables**:
  - `NODE_ENV`: Defines the deployment environment (`beta` or `production`)
  - `QUIZ_SERVICE_PROXY`: Internal API base URL pointing to the appropriate `quiz-service`
  - `QUIZ_SERVICE_IMAGES_PROXY`: Proxy path for image uploads
  - `VIRTUAL_HOST` and `LETSENCRYPT_HOST`: Used by `nginx-proxy` and `acme-companion` for HTTPS routing
- **Network**: Connected to `core-network` for internal service discovery

## 🔐 Required Secrets

No secrets required for this stack.

## 📁 Files

- `docker-compose.beta.yaml`: Beta deployment configuration
- `docker-compose.prod.yaml`: Production deployment configuration
- `stacks.beta.env`: Beta environment variables
- `stacks.env`: Common environment variables
- `stacks.prod.env`: Production environment variables

## 🛠 Portainer GitOps Configuration

- **Git Repository**: This repository's URL
- **Path**: `stacks/quiz`
- **Auto Update**: Enable (interval or webhook)

## 📝 Deployment Configurations

### Beta Deployment
- **Compose file**: `docker-compose.beta.yaml`
- **Virtual Host**: `beta.klurigo.com`
- **API Proxy**: `http://beta-quiz-service:8080/api`

### Production Deployment
- **Compose file**: `docker-compose.prod.yaml`
- **Virtual Host**: `quiz.emilhornlund.com`, `klurigo.com`
- **API Proxy**: `http://prod-quiz-service:8080/api`

> Ensure `core-network` and the corresponding `quiz-service` backend are deployed and reachable.

---

> The quiz frontend delivers a responsive, interactive game experience for players and hosts through a modern single-page application.
