# 🧠 Quiz Stack

This stack deploys the frontend web application for the quiz game platform, built with React, Vite, and Storybook.

## 🐳 Service Overview

- **Image**: `192.168.0.65:9500/emilhornlund/quiz:<tag>`
- **Port**: Exposes port `80` internally (proxied via nginx-proxy)
- **Environment Variables**:
  - `QUIZ_SERVICE_PROXY`: Internal API base URL pointing to `quiz-service`
  - `QUIZ_SERVICE_IMAGES_PROXY`: Proxy path for uploaded image assets
  - `VIRTUAL_HOST` and `LETSENCRYPT_HOST`: Used by `nginx-proxy` and `acme-companion` to expose the site over HTTPS
- **Network**: Connected to `core-network` to communicate with backend and proxy

## 🛠 Portainer GitOps Configuration

To deploy this stack with Portainer:

- **Git Repository**: This repository's URL
- **Path**: `stacks/quiz`
- **Auto Update**: Enable (interval or webhook)

> Ensure the `core-network` and the `quiz-service` backend are up and accessible before deploying this stack.

---

> The quiz frontend delivers a responsive, interactive game experience to players and hosts through a modern single-page application.
