# Agent Orchestrator — agent-orchestrator

This stack runs Agent Orchestrator for the `emilhornlund/agent-orchestrator` repository using the Node.js Agent Orchestrator image.

It is designed to run as a dedicated Portainer-managed container with isolated project configuration and persistent state.

## Image

The stack uses:

```text
emils-nuc-server:5000/agent-orchestrator-node:latest
```

This image contains the runtime and tooling required to run Agent Orchestrator against the `agent-orchestrator` Node.js repository, including:

* Ubuntu
* Node.js 24
* Yarn Classic
* Git
* GitHub CLI
* OpenCode
* The compiled Agent Orchestrator application

## Project

The stack manages:

```text
emilhornlund/agent-orchestrator
```

The repository is cloned automatically by Agent Orchestrator if the configured repository path does not already contain a valid Git repository.

The persistent repository path inside the container is:

```text
/opt/repositories/agent-orchestrator
```

Agent worktrees are stored under:

```text
/opt/.agent-worktrees/agent-orchestrator
```

## Repository Commands

Dependencies are installed with:

```bash
yarn install --frozen-lockfile
```

Task changes are validated with:

```bash
yarn build && yarn format:check && yarn validate
```

This verifies:

* the production TypeScript build
* Prettier formatting
* ESLint
* TypeScript type checking
* the Vitest test suite

## Portainer GitOps

Configure the stack in Portainer with:

* Git repository: this infrastructure repository
* Repository reference: `refs/heads/main`
* Compose path: `stacks/agent-orchestrator-agent-orchestrator/docker-compose.yaml`
* Automatic updates: optional
* Required environment secrets: configured in Portainer

The stack does not depend on relative bind mounts for its Agent Orchestrator configuration.

The project configuration is embedded in the Compose file using a Compose config object and is mounted at:

```text
/opt/agent-orchestrator/config.yaml
```

## Required Environment Secrets

The following values must be configured in Portainer and must not be committed to Git:

```text
TRELLO_API_KEY
TRELLO_TOKEN
GH_TOKEN
```

### Trello

`TRELLO_API_KEY` and `TRELLO_TOKEN` are used by Agent Orchestrator to read and update the configured Trello board.

### GitHub

`GH_TOKEN` is inherited by the GitHub CLI inside the container.

It is used for operations such as:

```bash
gh repo clone emilhornlund/agent-orchestrator /opt/repositories/agent-orchestrator
```

and other GitHub CLI operations performed by Agent Orchestrator.

The token must have sufficient access to the repository for the workflow Agent Orchestrator performs, including creating and updating branches and pull requests.

Do not embed GitHub credentials in repository URLs or configuration files.

## Persistent State

The stack uses named Docker volumes for state that must survive container recreation and image updates.

### Repository

```text
agent-orchestrator-agent-orchestrator-repository-volume
```

Mounted at:

```text
/opt/repositories
```

The repository itself is stored inside that volume at:

```text
/opt/repositories/agent-orchestrator
```

It contains the persistent Git checkout of `emilhornlund/agent-orchestrator`.

On first startup, Agent Orchestrator clones the repository into this volume if the configured repository path does not already contain a valid Git repository.

If the configured repository path already contains a valid Git repository, Agent Orchestrator leaves it untouched.

If the configured repository path exists but is not a valid Git repository, Agent Orchestrator fails startup instead of overwriting it.

### Worktrees

```text
agent-orchestrator-agent-orchestrator-worktrees-volume
```

Mounted at:

```text
/opt/.agent-worktrees/agent-orchestrator
```

Contains Git worktrees created for Agent Orchestrator tasks.

New task branches are based on the latest fetched remote default branch.

Agent Orchestrator fetches:

```text
origin/main
```

before creating a new task worktree and creates the new agent branch from:

```text
origin/main
```

Existing task worktrees are reused so retry and remediation state is preserved.

### OpenCode Configuration

```text
agent-orchestrator-agent-orchestrator-opencode-config-volume
```

Mounted at:

```text
/root/.config/opencode
```

Contains persistent OpenCode configuration.

### OpenCode Data and Authentication

```text
agent-orchestrator-agent-orchestrator-opencode-data-volume
```

Mounted at:

```text
/root/.local/share/opencode
```

Contains OpenCode authentication and persistent runtime data.

The OpenCode authentication file is expected at:

```text
/root/.local/share/opencode/auth.json
```

### Agent Orchestrator Logs

```text
agent-orchestrator-agent-orchestrator-logs-volume
```

Mounted at:

```text
/opt/agent-orchestrator/logs
```

Contains Agent Orchestrator log files.

This volume ensures logs survive container recreation and image updates.

## Git Commit Signing

The host signing key is mounted read-only into the container from:

```text
/home/emilhornlund/.config/agent-orchestrator/signing/id_ed25519
```

and is available inside the container at:

```text
/run/secrets/agent-orchestrator-signing-key
```

The configured Git identity is:

```text
Emil Hörnlund
10013373+emilhornlund@users.noreply.github.com
```

The signing key must exist on the Docker host before the stack is deployed.

## OpenCode Authentication Bootstrap

OpenCode authentication and configuration are not stored in Git and are not baked into the image.

This stack initializes its dedicated OpenCode volumes by copying the already-working OpenCode state from the existing `agent-orchestrator-klurigo` stack.

The source volumes are mounted read-only during the copy.

### 1. Create the persistent volumes

Before deploying the stack for the first time, create the persistent Docker volumes:

```bash
docker volume create agent-orchestrator-agent-orchestrator-repository-volume
docker volume create agent-orchestrator-agent-orchestrator-worktrees-volume
docker volume create agent-orchestrator-agent-orchestrator-opencode-config-volume
docker volume create agent-orchestrator-agent-orchestrator-opencode-data-volume
docker volume create agent-orchestrator-agent-orchestrator-logs-volume
```

Verify them with:

```bash
docker volume ls | grep agent-orchestrator-agent-orchestrator
```

### 2. Copy the existing OpenCode data

Copy the OpenCode data and authentication state from the existing Klurigo orchestrator volume:

```bash
docker run --rm \
  -v agent-orchestrator-klurigo-opencode-data-volume:/source:ro \
  -v agent-orchestrator-agent-orchestrator-opencode-data-volume:/target \
  alpine \
  sh -c 'cp -a /source/. /target/'
```

Verify the new volume:

```bash
docker run --rm \
  -v agent-orchestrator-agent-orchestrator-opencode-data-volume:/target \
  alpine \
  ls -lah /target
```

The copied state should include:

```text
auth.json
```

The resulting authentication file inside the Agent Orchestrator container will be:

```text
/root/.local/share/opencode/auth.json
```

### 3. Copy the existing OpenCode configuration

Copy the OpenCode configuration from the existing Klurigo orchestrator volume:

```bash
docker run --rm \
  -v agent-orchestrator-klurigo-opencode-config-volume:/source:ro \
  -v agent-orchestrator-agent-orchestrator-opencode-config-volume:/target \
  alpine \
  sh -c 'cp -a /source/. /target/'
```

Verify the new volume:

```bash
docker run --rm \
  -v agent-orchestrator-agent-orchestrator-opencode-config-volume:/target \
  alpine \
  ls -lah /target
```

This gives the new stack an independent copy of the already-working OpenCode configuration while keeping subsequent state isolated between orchestrator stacks.

Do not copy the existing repository, worktree, or log volumes. Those volumes are intentionally unique to this stack.

### 4. Deploy the Portainer stack

Deploy the stack using:

```text
stacks/agent-orchestrator-agent-orchestrator/docker-compose.yaml
```

Configure these environment variables in Portainer before deployment:

```text
TRELLO_API_KEY
TRELLO_TOKEN
GH_TOKEN
```

### 5. Verify OpenCode authentication

After the container is running:

```bash
docker exec -it agent-orchestrator-agent-orchestrator opencode auth list
```

Confirm that the expected OpenCode provider is available.

## GitHub Authentication Verification

Verify that the container can authenticate to GitHub:

```bash
docker exec -it agent-orchestrator-agent-orchestrator gh auth status
```

The command should report authentication using the configured `GH_TOKEN`.

Verify repository access without modifying anything:

```bash
docker exec -it agent-orchestrator-agent-orchestrator \
  gh repo view emilhornlund/agent-orchestrator
```

## Repository Bootstrap

The repository volume initially starts empty.

Agent Orchestrator handles repository cloning automatically during startup.

If:

```text
/opt/repositories/agent-orchestrator
```

does not exist as a Git repository, Agent Orchestrator runs the equivalent of:

```bash
gh repo clone emilhornlund/agent-orchestrator /opt/repositories/agent-orchestrator
```

After cloning, it verifies that the destination is a valid Git repository.

If the repository already exists, startup does not:

* pull
* reset
* clean
* checkout another branch
* overwrite local state

Repository synchronization for new task branches happens later when Agent Orchestrator prepares a worktree.

## Repository Verification

Verify that the repository was cloned correctly:

```bash
docker exec -it agent-orchestrator-agent-orchestrator \
  git -C /opt/repositories/agent-orchestrator status
```

Verify the configured remote:

```bash
docker exec -it agent-orchestrator-agent-orchestrator \
  git -C /opt/repositories/agent-orchestrator remote -v
```

The remote should point to:

```text
emilhornlund/agent-orchestrator
```

## Default Branch Synchronization

Before creating a new task worktree, Agent Orchestrator fetches the configured default branch:

```bash
git fetch origin main
```

A new task branch is then created from:

```text
origin/main
```

This means new tasks start from the latest remote `main` branch without requiring the persistent repository's local `main` branch to be reset or updated.

Existing worktrees are reused instead of recreated so retries and remediation can continue from their existing state.

## Worktree Verification

Verify that the worktree directory exists and is writable:

```bash
docker exec -it agent-orchestrator-agent-orchestrator \
  sh -lc 'mkdir -p /opt/.agent-worktrees/agent-orchestrator && test -w /opt/.agent-worktrees/agent-orchestrator'
```

A successful command produces no output.

## Commit Signing Verification

Verify the signing key is mounted:

```bash
docker exec -it agent-orchestrator-agent-orchestrator \
  ls -l /run/secrets/agent-orchestrator-signing-key
```

Verify the repository Git configuration after Agent Orchestrator has initialized the repository:

```bash
docker exec -it agent-orchestrator-agent-orchestrator \
  git -C /opt/repositories/agent-orchestrator config --get user.name
```

```bash
docker exec -it agent-orchestrator-agent-orchestrator \
  git -C /opt/repositories/agent-orchestrator config --get user.email
```

## Logs

Agent Orchestrator writes persistent logs under:

```text
/opt/agent-orchestrator/logs
```

To inspect the files inside the running container:

```bash
docker exec -it agent-orchestrator-agent-orchestrator \
  ls -lah /opt/agent-orchestrator/logs
```

Container stdout/stderr is also available through Portainer or Docker:

```bash
docker logs agent-orchestrator-agent-orchestrator
```

To follow logs:

```bash
docker logs -f agent-orchestrator-agent-orchestrator
```

## Initial Deployment Checklist

Before allowing Agent Orchestrator to process a real Trello card, verify:

* The five persistent Docker volumes exist
* The host Git signing key exists
* The OpenCode authentication volume has been initialized
* The stack deploys successfully in Portainer
* `TRELLO_API_KEY` is configured
* `TRELLO_TOKEN` is configured
* `GH_TOKEN` is configured
* `gh auth status` succeeds inside the container
* `opencode auth list` shows the expected provider
* `/opt/repositories/agent-orchestrator` contains the expected Git repository
* The repository remote points to `emilhornlund/agent-orchestrator`
* `/opt/.agent-worktrees/agent-orchestrator` is writable
* `/opt/agent-orchestrator/logs` is writable and persistent
* The Git signing key is mounted inside the container
* Agent Orchestrator validates the Trello configuration successfully
* Agent Orchestrator reaches its normal polling state without startup errors

Only after these checks pass should a test Trello card be moved into the configured Ready list.

## Security

Do not commit any of the following:

* Trello API keys
* Trello tokens
* GitHub tokens
* OpenCode authentication files
* provider credentials
* copied OpenCode configuration containing secrets
* Git signing private keys

Secrets should be supplied through Portainer environment variables, host-mounted secret files, or persistent Docker volumes.

OpenCode authentication volumes are intentionally mounted read/write so OpenCode can update its persistent state when required.
