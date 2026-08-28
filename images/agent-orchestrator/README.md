# Agent Orchestrator Images

These images provide the runtime and project toolchains used by Agent Orchestrator deployments.

## Image Hierarchy

```text
agent-orchestrator-base
        │
        ├── agent-orchestrator-node
        │      ├── Node.js project tooling
        │      └── Agent Orchestrator application
        │
        └── agent-orchestrator-cpp
               ├── C++/SDL project tooling
               └── Agent Orchestrator application
```

### `agent-orchestrator-base`

Provides the common runtime dependencies used by all Agent Orchestrator images:

- Ubuntu 26.04
- Node.js 24
- Yarn Classic
- Git
- GitHub CLI
- OpenCode
- SSH client

### `agent-orchestrator-node`

Extends the base image with tooling required for Node.js projects:

- build-essential
- Docker CLI
- Docker Compose
- Python
- Compiled Agent Orchestrator application

This image is intended for stacks such as:

```text
stacks/agent-orchestrator-klurigo
```

### `agent-orchestrator-cpp`

Extends the base image with tooling required for C++/SDL projects:

- GCC and Clang
- CMake
- Ninja
- ccache
- clang-format
- clang-tidy
- SDL development dependencies
- Compiled Agent Orchestrator application

This image is intended for stacks such as:

```text
stacks/agent-orchestrator-rpg-sdl
```

## Build Process

Images are built manually using:

```text
.github/workflows/agent-orchestrator-images.yml
```

The workflow checks out two repositories into the same GitHub Actions workspace:

```text
workspace/
├── infra/
└── agent-orchestrator/
```

The shared workspace is used as the Docker build context so the Node.js and C++ Dockerfiles can copy and build the Agent Orchestrator application.

The images are published to:

```text
emils-nuc-server:5000
```

Each build publishes both the resolved build tag and `latest`.

## Runtime

The Node.js and C++ images compile Agent Orchestrator with:

```bash
yarn build
```

and start it with:

```bash
node dist/main.js
```

Project-specific configuration is not baked into the images.

Each Portainer stack is responsible for supplying:

- `config.yaml`
- Trello credentials
- GitHub credentials
- OpenCode credentials
- repository storage
- worktree storage
- any project-specific runtime mounts
