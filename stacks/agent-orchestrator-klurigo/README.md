# Agent Orchestrator — klurigo

This stack runs Agent Orchestrator for the `emilhornlund/klurigo` repository using the Node.js Agent Orchestrator image.

It is designed to run as a dedicated Portainer-managed container with isolated project configuration and persistent state.

## Image

The stack uses:

```text
emils-nuc-server:5000/agent-orchestrator-node:latest
```

This image contains the runtime and tooling required to run Agent Orchestrator against the Klurigo Node.js monorepo, including:

- Ubuntu
- Node.js 24
- Yarn Classic
- Git
- GitHub CLI
- OpenCode
- The compiled Agent Orchestrator application

## Test Infrastructure

The stack includes dedicated Redis and MongoDB services for Klurigo tests:

```text
klurigo-test-redis
klurigo-test-mongodb
```

The services use:

```text
redis:8.0.1
mongo:8.0.9
```

They are only available on the stack's internal Docker network and are not exposed on host ports.

The Agent Orchestrator container connects to them using:

```text
REDIS_HOST=klurigo-test-redis
REDIS_PORT=6379
MONGODB_HOST=klurigo-test-mongodb
MONGODB_PORT=27017
```

The Redis and MongoDB containers are disposable test infrastructure and do not use persistent Docker volumes.

## Project

The stack manages:

```text
emilhornlund/klurigo
```

The repository is cloned automatically by Agent Orchestrator if the configured repository path does not already contain a valid Git repository.

The persistent repository path inside the container is:

```text
/opt/repositories/klurigo
```

Agent worktrees are stored under:

```text
/opt/.agent-worktrees/klurigo
```

## Portainer GitOps

Configure the stack in Portainer with:

- Git repository: this infrastructure repository
- Repository reference: `refs/heads/main`
- Compose path: `stacks/agent-orchestrator-klurigo/docker-compose.yaml`
- Automatic updates: optional
- Required environment secrets: configured in Portainer

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
gh repo clone emilhornlund/klurigo /opt/repositories/klurigo
```

and other GitHub CLI operations performed by Agent Orchestrator.

The token must have sufficient access to the repository for the workflow Agent Orchestrator performs, including creating and updating branches and pull requests.

Do not embed GitHub credentials in repository URLs or configuration files.

## Persistent State

The stack uses named Docker volumes for state that must survive container recreation and image updates.

### Repository

```text
agent-orchestrator-klurigo-repository-volume
```

Mounted at:

```text
/opt/repositories
```

The Klurigo repository itself is stored inside that volume at:

```text
/opt/repositories/klurigo
```

Contains the persistent Git checkout of `emilhornlund/klurigo`.

On first startup, Agent Orchestrator clones the repository into this volume if the configured repository path does not already contain a valid Git repository.

If the configured repository path already contains a valid Git repository, Agent Orchestrator leaves it untouched.

If the configured repository path exists but is not a valid Git repository, Agent Orchestrator fails startup instead of overwriting it.

### Worktrees

```text
agent-orchestrator-klurigo-worktrees-volume
```

Mounted at:

```text
/opt/.agent-worktrees/klurigo
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
agent-orchestrator-klurigo-opencode-config-volume
```

Mounted at:

```text
/root/.config/opencode
```

Contains persistent OpenCode configuration.

### OpenCode Data and Authentication

```text
agent-orchestrator-klurigo-opencode-data-volume
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
agent-orchestrator-klurigo-logs-volume
```

Mounted at:

```text
/opt/agent-orchestrator/logs
```

Contains Agent Orchestrator log files.

This volume ensures logs survive container recreation and image updates.

## OpenCode Authentication Bootstrap

OpenCode authentication is not stored in Git and is not baked into the image.

The OpenCode authentication state must be copied into the persistent Docker volume once before Agent Orchestrator can use authenticated OpenCode providers.

On a machine where OpenCode is already authenticated, locate:

```text
~/.local/share/opencode/auth.json
```

The optional global OpenCode configuration may be located at:

```text
~/.config/opencode/opencode.json
```

Do not blindly copy unrelated OpenCode caches or session data unless they are required.

### 1. Copy the files to the NUC

From the machine where OpenCode is already configured, copy the required files to a temporary location on the NUC.

For example:

```bash
scp ~/.local/share/opencode/auth.json <nuc-host>:/tmp/opencode-auth.json
```

If the global OpenCode configuration is also required:

```bash
scp ~/.config/opencode/opencode.json <nuc-host>:/tmp/opencode.json
```

### 2. Ensure the stack volumes exist

Create the persistent Klurigo Docker volumes before deploying the stack.

The required OpenCode volumes are:

```text
agent-orchestrator-klurigo-opencode-data-volume
agent-orchestrator-klurigo-opencode-config-volume
```

The OpenCode authentication state should be initialized before the Agent Orchestrator container is started for the first time.

### 3. Copy `auth.json` into the OpenCode data volume

On the NUC:

```bash
docker run --rm \
  -v agent-orchestrator-klurigo-opencode-data-volume:/target \
  -v /tmp/opencode-auth.json:/source/auth.json:ro \
  alpine \
  sh -c 'mkdir -p /target && cp /source/auth.json /target/auth.json'
```

The resulting file inside the Agent Orchestrator container will be:

```text
/root/.local/share/opencode/auth.json
```

### 4. Optionally copy the OpenCode global configuration

If the local OpenCode installation uses a global configuration that is required by Agent Orchestrator:

```bash
docker run --rm \
  -v agent-orchestrator-klurigo-opencode-config-volume:/target \
  -v /tmp/opencode.json:/source/opencode.json:ro \
  alpine \
  sh -c 'mkdir -p /target && cp /source/opencode.json /target/opencode.json'
```

Before copying the global configuration, inspect it for machine-specific paths, plugins, commands, or other settings that may not make sense inside the container.

### 5. Remove temporary credential files

After the Docker volume has been initialized:

```bash
rm -f /tmp/opencode-auth.json
rm -f /tmp/opencode.json
```

Do not leave authentication files in temporary host locations longer than necessary.

### 6. Restart the Agent Orchestrator container

Restart the stack or container through Portainer.

Alternatively:

```bash
docker restart agent-orchestrator-klurigo
```

### 7. Verify OpenCode authentication

Run:

```bash
docker exec -it agent-orchestrator-klurigo opencode auth list
```

Confirm that the expected OpenCode provider is available.

## GitHub Authentication Verification

Verify that the container can authenticate to GitHub:

```bash
docker exec -it agent-orchestrator-klurigo gh auth status
```

The command should report authentication using the configured `GH_TOKEN`.

You can also verify repository access without modifying anything:

```bash
docker exec -it agent-orchestrator-klurigo \
  gh repo view emilhornlund/klurigo
```

## Repository Bootstrap

The repository volume initially starts empty.

Agent Orchestrator handles this automatically during startup.

If:

```text
/opt/repositories/klurigo
```

does not exist as a Git repository, Agent Orchestrator runs the equivalent of:

```bash
gh repo clone emilhornlund/klurigo /opt/repositories/klurigo
```

After cloning, it verifies that the destination is a valid Git repository.

If the repository already exists, startup does not:

- pull
- reset
- clean
- checkout another branch
- overwrite local state

Repository synchronization for new task branches happens later when Agent Orchestrator prepares a worktree.

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

## Logs

Agent Orchestrator writes persistent logs under:

```text
/opt/agent-orchestrator/logs
```

To inspect the files inside the running container:

```bash
docker exec -it agent-orchestrator-klurigo \
  ls -lah /opt/agent-orchestrator/logs
```

Container stdout/stderr is also available through Portainer or Docker:

```bash
docker logs agent-orchestrator-klurigo
```

To follow logs:

```bash
docker logs -f agent-orchestrator-klurigo
```

## Initial Deployment Checklist

Before allowing Agent Orchestrator to process a real Trello card, verify:

- The stack deploys successfully in Portainer
- `TRELLO_API_KEY` is configured
- `TRELLO_TOKEN` is configured
- `GH_TOKEN` is configured
- The OpenCode authentication volume has been initialized
- `gh auth status` succeeds inside the container
- `opencode auth list` shows the expected provider
- `/opt/repositories/klurigo` contains the expected Git repository
- The repository remote points to `emilhornlund/klurigo`
- `/opt/.agent-worktrees/klurigo` is writable
- `/opt/agent-orchestrator/logs` is writable and persistent
- Agent Orchestrator validates the Trello configuration successfully
- Agent Orchestrator reaches its normal polling state without startup errors

Only after these checks pass should a test Trello card be moved into the configured Ready list.

## Security

Do not commit any of the following:

- Trello API keys
- Trello tokens
- GitHub tokens
- OpenCode authentication files
- provider credentials
- copied OpenCode configuration containing secrets

Secrets should be supplied through Portainer environment secrets or persistent Docker volumes.

OpenCode authentication volumes are intentionally mounted read/write so OpenCode can update its persistent state when required.
