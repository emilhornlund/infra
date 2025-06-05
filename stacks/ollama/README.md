# 🧠 Ollama + Open WebUI Stack

This stack deploys a fully self-hosted LLM inference backend (`Ollama`) paired with a sleek frontend (`Open WebUI`) using Docker Compose.

## 🐳 Service Overview

### Ollama (LLM backend)
- **Image**: `intelanalytics/ipex-llm-inference-cpp-xpu:latest`
- **Purpose**: Serves local LLMs with Intel GPU acceleration
- **Devices**: Exposes `/dev/dri`, runs with `privileged` and `render` group
- **Environment**:
  - `OLLAMA_NUM_GPU=999`: Use all available GPUs
  - `SYCL_CACHE_PERSISTENT=1`: Enable persistent GPU caching
  - Other Intel oneAPI + SYCL tunings pre-set
- **Command**: Launches Ollama via Intel oneAPI shell script
- **Data**: Persisted in `ollama-data-volume`

### Open WebUI (frontend)
- **Image**: `ghcr.io/open-webui/open-webui:main`
- **Port**: Exposed as `8080` internally, proxied via HTTPS on `ollama.emilhornlund.com`
- **Environment**:
  - `OLLAMA_BASE_URL=http://ollama:11434`: Connects to backend
  - Proxy configuration using `VIRTUAL_HOST`, `VIRTUAL_PORT`, `LETSENCRYPT_HOST`
- **Data**: User interface state stored in `openwebui-data-volume`

## 🔐 Domain & Proxy
Make sure to have `ollama.emilhornlund.com` configured and reachable through your reverse proxy setup. HTTPS is automatically handled via Let's Encrypt.

## 🛠 Portainer GitOps Configuration
- **Git Repository**: This repository’s URL
- **Path**: `stacks/ollama`
- **Auto Update**: Enabled via interval or webhook
- **Note**: Requires `core-network` to be created beforehand

## 📦 Volumes
- `ollama-data-volume`: Model weights and cache
- `openwebui-data-volume`: Web UI user data

## ⚙️ Hardware Requirements
- Intel GPU with Level Zero support
- `/dev/dri` exposed and configured correctly
- Host must support Intel oneAPI stack

---

> This stack transforms your machine into a personal AI assistant with a local inference engine and privacy-first web UI.
