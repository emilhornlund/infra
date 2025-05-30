# 🏃‍♂️ GitHub Self-Hosted Runner Stack

This stack deploys a [GitHub Actions self-hosted runner](https://github.com/myoung34/docker-github-runner) using Docker Compose and Portainer GitOps.

## 🐳 Service Overview

- **Image**: `myoung34/github-runner:2.324.0`
- **Network Mode**: `host`
- **Volume Mounts**:
  - `/var/run/docker.sock` – allows Docker-in-Docker (for container jobs)
  - `gh-runner-data-volume` → `/runner/data` – stores runner config and state
  - `gh-tmp-runner-volume` → `/tmp/runner` – working directory for job execution
- **Environment File**: Uses `stack.env` to define required runner settings

## 🔐 Required Secret

To register with GitHub, this stack requires a **GitHub Personal Access Token (PAT)**:

```env
ACCESS_TOKEN=<YOUR_GITHUB_PAT>
````

> This token must be added in Portainer as an **environment secret** for the stack to deploy properly.

## 📁 Files

* `docker-compose.yaml`: Defines the GitHub Actions runner container.
* `stack.env`: Contains environment variables like repo URL, runner name, and working directory.

## ⚙️ Key Configuration (`stack.env`)

```env
REPO_URL=https://github.com/emilhornlund/quiz
RUNNER_NAME=quiz-docker-runner-1
RUNNER_WORKDIR=/tmp/runner/work
CONFIGURED_ACTIONS_RUNNER_FILES_DIR=/runner/data
DISABLE_AUTOMATIC_DEREGISTRATION=true
RUNNER_SCOPE=repo
LABELS=self-hosted
```

## 🛠 Portainer GitOps Configuration

To deploy this stack with Portainer:

* **Git Repository**: This repository's URL
* **Path**: `stacks/github-runner`
* **Auto Update**: Enable (interval or webhook)
* **Environment Secret**: Add `ACCESS_TOKEN` with your GitHub PAT

---

> This runner can execute GitHub Actions workflows directly on your own infrastructure, giving you full control and zero-cost compute.
