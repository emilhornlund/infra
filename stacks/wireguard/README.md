# 🔒 WireGuard VPN Stack

This stack deploys a self-hosted WireGuard VPN server using Docker Compose and Portainer GitOps. It allows secure access to your home or private network via encrypted tunnels.

## 🐳 Service Overview

- **Image**: `lscr.io/linuxserver/wireguard:1.0.20210914-r4-ls76`
- **Port**: `51820/udp` exposed for VPN clients
- **Capabilities**: Requires `NET_ADMIN` and `SYS_MODULE` for networking
- **Volumes**:
  - `/lib/modules` – required for kernel module access
  - `wireguard-config-volume` → `/config` – stores server and peer keys/configs
- **Environment Variables**:
  - `SERVERURL`: Public domain name used by VPN clients
  - `SERVERPORT`: UDP port to expose (default: 51820)
  - `PEERS`: Number of peers to preconfigure
  - `PEERDNS`: DNS to use inside VPN (e.g., Pi-hole)
  - `INTERNAL_SUBNET`: VPN address range (e.g., `10.13.13.0`)
- **Network**: Connected to `core-network` for service discovery (e.g., Pi-hole)

## 🔐 Required Secrets

No secrets required for this stack.

## 📁 Files

- `docker-compose.yaml`: Defines the WireGuard VPN server with proper capabilities and networking

## 🛠 Portainer GitOps Configuration

- **Git Repository**: This repository's URL
- **Path**: `stacks/wireguard`
- **Auto Update**: Enable (interval or webhook)

## 📝 Client Configuration

Once the container is running, retrieve the peer config:

```bash
cat ./config/peer1/peer1.conf
```

Or scan the QR code for mobile setup:

```bash
docker exec -it wireguard cat /config/peer1/peer1.png
```

> Import the `.conf` file into the WireGuard desktop client or scan the QR code with the mobile app.

> Ensure `core-network` is created before deployment.

---

> This stack gives you secure access to internal services and enables encrypted traffic through your private infrastructure.
