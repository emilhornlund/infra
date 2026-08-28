# 🏃‍♂️ GitHub Self-Hosted Runner Stack

This stack deploys two [GitHub Actions self-hosted runners](https://github.com/myoung34/docker-github-runner) using Docker Compose and Portainer GitOps. Both runners are repo-scoped and use the same runner image.

## 🐳 Service Overview

### Klurigo Runner

- **Repository**: `https://github.com/emilhornlund/klurigo`
- **Runner name**: `klurigo-docker-runner-1`
- **Scope**: `repo`
- **Labels**: `self-hosted`

### Infra Runner

- **Repository**: `https://github.com/emilhornlund/infra`
- **Runner name**: `infra-docker-runner-1`
- **Scope**: `repo`
- **Labels**: `self-hosted,infra`
- **Purpose**: Runs the manually triggered workflow that builds and pushes Agent Orchestrator images.

### Shared Runner Configuration

- **Image**: `myoung34/github-runner:2.328.0`
- **Network**: Both runners use the external `core-network`.
- **Docker access**: Both runners mount `/var/run/docker.sock` for Docker-backed jobs. SELinux labeling is disabled for the containers.
- **Persistent storage**: Each runner has dedicated volumes for `/runner/data` and `/tmp/runner`.
- **Environment file**: `stack.env` defines shared runner settings; service-level settings define each repository, runner name, and label set.

## 🔐 Required Secrets

To register with GitHub, this stack requires a **GitHub Personal Access Token (PAT)**. Add it in Portainer as an environment secret named `ACCESS_TOKEN`; do not commit the token to this repository.

## 📁 Files

- `docker-compose.yaml`: Defines the GitHub Actions runner container
- `stack.env`: Contains environment variables like repo URL, runner name, and working directory

## 🛠 Portainer GitOps Configuration

- **Git Repository**: This repository's URL
- **Path**: `stacks/github-runner`
- **Auto Update**: Enable (interval or webhook)
- **Environment Secret**: Add `ACCESS_TOKEN` with a PAT that can manage both repository-scoped runners

## 📝 Key Configuration (`stack.env`)

The shared `stack.env` sets the runner work directory, persistent configuration directory, automatic deregistration behavior, repo scope, and default `self-hosted` label. The Compose services override `REPO_URL` and `RUNNER_NAME` for each repository; the infra service additionally sets the `infra` label.

---

> This runner can execute GitHub Actions workflows directly on your own infrastructure, giving you full control and zero-cost compute.
