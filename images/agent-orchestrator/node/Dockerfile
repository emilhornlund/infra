ARG BASE_IMAGE=agent-orchestrator-base:local
FROM ${BASE_IMAGE}

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        docker.io \
        docker-compose-v2 \
        python3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/agent-orchestrator

COPY agent-orchestrator/package.json agent-orchestrator/yarn.lock ./
RUN yarn install --frozen-lockfile

COPY agent-orchestrator/ ./
RUN yarn build

CMD ["node", "dist/main.js"]
