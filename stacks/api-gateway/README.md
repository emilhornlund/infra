# 🚪 API Gateway Stack

This stack provides a minimal NGINX-based API gateway to securely route traffic to internal backend services.

## 🐳 Service Overview

- **Image**: `nginx:1.28.0-alpine`
- **Purpose**: Acts as a reverse proxy with optional API key protection
- **Exposed At**: `api.emilhornlund.com` via `nginx-proxy` and Let's Encrypt
- **Dynamic Config**: Uses `envsubst` to inject `API_KEY` into NGINX template
- **Routes**:
  - `/api/quiz-service/` → forwards to internal `quiz-service:8080`, requires valid API key in `X-API-Key` header
  - `/api_docs/quiz-service/` → public access to Swagger or API documentation

## 🔐 Required Secrets

Make sure to configure the following in Portainer or your environment:

```env
API_KEY=<YOUR_SECRET_API_KEY>
```

## 📁 Files

- `docker-compose.yaml`: Defines the API gateway service
- `nginx.conf.template`: NGINX configuration template with API key protection

## 🛠 Portainer GitOps Configuration

- **Git Repository**: This repository's URL
- **Path**: `stacks/api-gateway`
- **Auto Update**: Enabled via interval or webhook
- **Note**: Requires `core-network` to route traffic to backend services

## 📝 Usage Example

```
GET /api/quiz-service/ HTTP/1.1
Host: api.emilhornlund.com
X-API-Key: <YOUR_SECRET_API_KEY>
```

> Requests without a valid API key to protected paths will receive a `403 Forbidden` response.

---

> This API gateway provides secure, centralized access control for your backend services.
