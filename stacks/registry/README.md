# 📦 Private Docker Registry Stack

This stack deploys a private Docker registry with HTTPS and basic authentication using Docker Compose and Portainer GitOps.

## 🐳 Service Overview

- **Image**: `registry:2`
- **Port**: Exposes `5000` for pushing/pulling Docker images
- **Authentication**: Uses `htpasswd`-based basic auth
- **TLS**: Requires self-signed certificate and trusted CA
- **Volumes**:
  - `registry-auth-volume` → `/auth` – stores `htpasswd` credentials
  - `registry-certs-volume` → `/certs` – stores TLS cert and key
  - `registry-data-volume` → `/var/lib/registry` – stores image layers and metadata
- **Network**: Connected to `core-network` for integration with other services

## 🔐 Configuration

### 1. Create Registry Credentials

Generate a basic authentication file:

```bash
htpasswd -Bbn myuser "<YOUR_PASSWORD>" > htpasswd
```

Place the resulting `htpasswd` file inside the `registry-auth-volume`.

### 2. Set Up Self-Signed TLS

#### a. Create a Certificate Authority

```bash
mkdir -p ~/registry-tls && cd ~/registry-tls

openssl genrsa -out registry-ca.key 4096

openssl req -x509 -new -nodes \
  -key registry-ca.key \
  -sha256 -days 3650 \
  -subj "/CN=Registry Local CA" \
  -out registry-ca.crt
```

#### b. Issue a TLS Certificate for the Hostname

Replace `emils-nuc-server` with your registry's hostname.

```bash
cat > registry.cnf <<'EOF'
[ req ]
default_bits       = 4096
prompt             = no
default_md         = sha256
distinguished_name = dn
req_extensions     = req_ext

[ dn ]
CN = emils-nuc-server

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = emils-nuc-server
EOF
```

```bash
openssl genrsa -out emils-nuc-server.key 4096

openssl req -new -key emils-nuc-server.key -out emils-nuc-server.csr -config registry.cnf

openssl x509 -req -in emils-nuc-server.csr \
  -CA registry-ca.crt -CAkey registry-ca.key -CAcreateserial \
  -out emils-nuc-server.crt -days 825 -sha256 -extensions req_ext -extfile registry.cnf
```

Place the resulting `emils-nuc-server.crt` and `emils-nuc-server.key` files into the `registry-certs-volume`.

### 3. Trust the CA on All Docker Hosts

On every Docker host or GitHub runner:

```bash
sudo mkdir -p /etc/docker/certs.d/emils-nuc-server:5000
sudo cp registry-ca.crt /etc/docker/certs.d/emils-nuc-server:5000/ca.crt
sudo systemctl restart docker
```

> The hostname used in `docker push` must match the certificate (e.g. `emils-nuc-server`).

## 🛠 Portainer GitOps Configuration

- **Git Repository**: This repository's URL
- **Path**: `stacks/registry`
- **Auto Update**: Enable (interval or webhook)

---

> This setup provides a secure and private Docker image registry for internal development, CI/CD, and GitOps workflows.
