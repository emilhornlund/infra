#!/bin/sh
set -eu

echo "========================================"
echo "Maintenance started at $(date)"
echo "========================================"
echo

echo "Running registry cleanup..."

if registry-cleanup; then
  echo "Registry cleanup completed."
else
  echo "WARNING: Registry cleanup failed."
fi

echo
echo "Running registry garbage collection..."

REGISTRY_IMAGE="$(docker inspect --format '{{.Config.Image}}' registry)"

echo "Stopping registry for garbage collection..."
docker stop registry >/dev/null

if docker run --rm \
  --volumes-from registry \
  "$REGISTRY_IMAGE" \
  garbage-collect \
  --delete-untagged \
  /etc/docker/registry/config.yml; then
  echo "Registry garbage collection completed."
else
  echo "WARNING: Registry garbage collection failed."
fi

echo "Starting registry..."
docker start registry >/dev/null

echo
echo "Pruning unused Docker images older than ${DOCKER_IMAGE_MAX_AGE:-168h}..."

docker image prune \
  --all \
  --force \
  --filter "until=${DOCKER_IMAGE_MAX_AGE:-168h}"

echo
echo "Pruning unused Docker build cache older than ${DOCKER_BUILD_CACHE_MAX_AGE:-168h}..."

docker builder prune \
  --all \
  --force \
  --filter "until=${DOCKER_BUILD_CACHE_MAX_AGE:-168h}"

echo
echo "Docker disk usage:"
docker system df

echo
echo "Maintenance completed at $(date)"
