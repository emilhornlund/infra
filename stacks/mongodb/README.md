# 🍃 MongoDB Stack

This stack deploys a standalone [MongoDB 8](https://hub.docker.com/_/mongo) instance using Docker Compose and Portainer GitOps.

## 🐳 Service Overview

- **Image**: `mongo:8.0.9`
- **Port**: `27017` (default MongoDB port)
- **Volume**:
  - `mongodb-data-volume` → `/data/db` – persistent MongoDB database files
- **Network**: Joins the external `core-network` to connect with other services

## 🔐 Required Secrets

To initialize the MongoDB root user, the following environment secrets are required:

```env
MONGO_INITDB_ROOT_USERNAME=root
MONGO_INITDB_ROOT_PASSWORD=password
```

> These must be added in Portainer as environment secrets for the stack to deploy properly.

## 📁 Files

- `docker-compose.yaml`: Defines the MongoDB service, volume, and external network
- No `stack.env` file is needed — secrets are passed via Portainer

## 🛠 Portainer GitOps Configuration

- **Git Repository**: This repository's URL
- **Path**: `stacks/mongodb`
- **Auto Update**: Enable (interval or webhook)
- **Environment Secrets**: Add `MONGO_INITDB_ROOT_USERNAME` and `MONGO_INITDB_ROOT_PASSWORD`

> Ensure the `core-network` exists in Docker or is created manually before deployment.

---

> MongoDB provides a flexible and scalable document database. This setup gives you persistent storage and root-level access suitable for development and internal services.
