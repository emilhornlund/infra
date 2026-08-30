#!/bin/sh
set -eu

failures=0
registry_restart_required=0

ensure_registry_running() {
  if [ "$registry_restart_required" -eq 1 ]; then
    echo
    echo "Ensuring registry is running..."

    if docker start registry >/dev/null; then
      echo "Registry started."
      registry_restart_required=0
    else
      echo "ERROR: Failed to start registry." >&2
    fi
  fi
}

trap 'ensure_registry_running' EXIT
trap 'exit 1' HUP INT TERM

echo "========================================"
echo "Maintenance started at $(date)"
echo "========================================"
echo

echo "Running registry cleanup..."

if registry-cleanup; then
  echo "Registry cleanup completed."
else
  echo "WARNING: Registry cleanup failed."
  failures=$((failures + 1))
fi

echo
echo "Running registry garbage collection..."

if REGISTRY_IMAGE="$(docker inspect --format '{{.Config.Image}}' registry 2>/dev/null)"; then
  registry_running="$(docker inspect --format '{{.State.Running}}' registry 2>/dev/null || echo false)"
  gc_ready=1

  if [ "$registry_running" = "true" ]; then
    echo "Stopping registry for garbage collection..."
    registry_restart_required=1

    if ! docker stop registry >/dev/null; then
      echo "WARNING: Failed to stop registry. Skipping garbage collection."
      failures=$((failures + 1))
      gc_ready=0
    fi
  fi

  if [ "$gc_ready" -eq 1 ]; then
    if docker run --rm \
      --volumes-from registry \
      "$REGISTRY_IMAGE" \
      garbage-collect \
      --delete-untagged \
      /etc/docker/registry/config.yml; then
      echo "Registry garbage collection completed."
    else
      echo "WARNING: Registry garbage collection failed."
      failures=$((failures + 1))
    fi
  fi

  if [ "$registry_restart_required" -eq 1 ]; then
    echo "Starting registry..."

    if docker start registry >/dev/null; then
      echo "Registry started."
      registry_restart_required=0
    else
      echo "ERROR: Failed to restart registry."
      failures=$((failures + 1))
    fi
  fi
else
  echo "WARNING: Failed to inspect registry container. Skipping garbage collection."
  failures=$((failures + 1))
fi

echo
echo "Pruning unused Docker images older than ${DOCKER_IMAGE_MAX_AGE:-168h}..."

if docker image prune \
  --all \
  --force \
  --filter "until=${DOCKER_IMAGE_MAX_AGE:-168h}"; then
  echo "Docker image pruning completed."
else
  echo "WARNING: Docker image pruning failed."
  failures=$((failures + 1))
fi

echo
echo "Pruning unused Docker build cache older than ${DOCKER_BUILD_CACHE_MAX_AGE:-168h}..."

if docker builder prune \
  --all \
  --force \
  --filter "until=${DOCKER_BUILD_CACHE_MAX_AGE:-168h}"; then
  echo "Docker build cache pruning completed."
else
  echo "WARNING: Docker build cache pruning failed."
  failures=$((failures + 1))
fi

echo
echo "Docker disk usage:"

if ! docker system df; then
  echo "WARNING: Failed to report Docker disk usage."
  failures=$((failures + 1))
fi

echo
echo "Maintenance completed at $(date)"

if [ "$failures" -gt 0 ]; then
  echo "Maintenance completed with $failures failure(s)."
  exit 1
fi

echo "Maintenance completed successfully."
