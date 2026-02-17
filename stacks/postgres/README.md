# 🐘 PostgreSQL Stack

This stack deploys a [PostgreSQL 14](https://hub.docker.com/_/postgres) database instance along with [pgAdmin 4](https://hub.docker.com/r/dpage/pgadmin4) web interface using Docker Compose and Portainer GitOps.

## 🐳 Service Overview

### PostgreSQL Database

- **Image**: `postgres:14.21-trixie`
- **Port**: `15432:5432` (host:container)
- **Volume**:
  - `postgres-data-volume` → `/var/lib/postgresql/data/` – persistent PostgreSQL database files
- **Network**: Joins the external `core-network` to connect with other services
- **Health Check**: Uses `pg_isready` to verify database availability

### pgAdmin 4

- **Image**: `dpage/pgadmin4`
- **Port**: `15433:80` (host:container)
- **Volume**:
  - `pgadmin-data-volume` → `/var/lib/pgadmin/` – persistent pgAdmin configuration and settings
- **Network**: Connected to `core-network` for database access
- **Health Check**: HTTP check on port 80 to ensure web interface is responsive
- **Dependencies**: Depends on the `postgres` service

## 🔐 Required Secrets

To initialize PostgreSQL and pgAdmin, the following environment secrets are required:

```env
POSTGRES_USER=<YOUR_POSTGRES_USER>
POSTGRES_PASSWORD=<YOUR_POSTGRES_PASSWORD>
POSTGRES_DB=<YOUR_POSTGRES_DATABASE>
PGADMIN_DEFAULT_EMAIL=<YOUR_PGADMIN_EMAIL>
PGADMIN_DEFAULT_PASSWORD=<YOUR_PGADMIN_PASSWORD>
```

> These must be added in Portainer as environment secrets for the stack to deploy properly.

## 📁 Files

- `docker-compose.yaml`: Defines both PostgreSQL and pgAdmin services, volumes, and external network
- `stack.env`: Template file that references environment secrets from Portainer

## 🛠 Portainer GitOps Configuration

- **Git Repository**: This repository's URL
- **Path**: `stacks/postgres`
- **Auto Update**: Enable (interval or webhook)
- **Environment Secrets**: Add `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`, `PGADMIN_DEFAULT_EMAIL`, and `PGADMIN_DEFAULT_PASSWORD`

> Ensure the `core-network` exists in Docker or is created manually before deployment.

## 🔗 Access

- **PostgreSQL**: Connect via `localhost:15432` or from other containers via `postgres:5432`
- **pgAdmin**: Access the web interface at `http://localhost:15433`

To connect to PostgreSQL from pgAdmin:
1. Log in to pgAdmin using `PGADMIN_DEFAULT_EMAIL` and `PGADMIN_DEFAULT_PASSWORD`
2. Add a new server connection:
   - **Host name/address**: `postgres`
   - **Port**: `5432`
   - **Username**: Value of `POSTGRES_USER`
   - **Password**: Value of `POSTGRES_PASSWORD`

---

> PostgreSQL is a powerful, open-source relational database system with strong ACID compliance and extensibility. This setup provides both the database and a web-based management interface for development and production use.

