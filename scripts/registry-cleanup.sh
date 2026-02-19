#!/bin/sh
set -eu

REGISTRY_HOST="${REGISTRY_HOST:-emils-nuc-server:5000}"
REGISTRY_USER="${REGISTRY_USER:?Missing REGISTRY_USER}"
REGISTRY_PASS="${REGISTRY_PASS:?Missing REGISTRY_PASS}"
KEEP_LAST="${KEEP_LAST:-4}"

REPOS_ALLOWLIST="${REPOS_ALLOWLIST:-klurigo-service klurigo-web}"

HOSTCFG="reg=${REGISTRY_HOST},user=${REGISTRY_USER},pass=${REGISTRY_PASS},tls=insecure"

echo "Starting cleanup at $(date)"
echo "Registry: ${REGISTRY_HOST}"
echo "Keep last: ${KEEP_LAST}"
echo "Repos: ${REPOS_ALLOWLIST}"
echo

# Login without pinging (avoids TLS hostname/cert issues)
printf "%s" "$REGISTRY_PASS" | regctl registry login "$REGISTRY_HOST" -u "$REGISTRY_USER" --pass-stdin --skip-check >/dev/null 2>&1 || true

# List repos
repos="$(regctl --host "$HOSTCFG" repo ls "$REGISTRY_HOST" 2>&1)" || {
  echo "ERROR: failed to list repositories"
  echo "$repos"
  exit 1
}

if [ -z "$repos" ]; then
  echo "No repositories found."
  exit 0
fi

for repo in $repos; do
  allowed="false"
  for a in $REPOS_ALLOWLIST; do
    [ "$repo" = "$a" ] && allowed="true" && break
  done
  [ "$allowed" = "true" ] || continue

  echo "== Repo: $repo =="

  tags="$(regctl --host "$HOSTCFG" tag ls "${REGISTRY_HOST}/${repo}" 2>/dev/null || true)"
  tag_count="$(printf "%s\n" "$tags" | sed '/^$/d' | wc -l | tr -d ' ')"

  if [ "$tag_count" -le "$KEEP_LAST" ]; then
    echo "Skipping (tags=$tag_count <= keep=$KEEP_LAST)"
    echo
    continue
  fi

  tmp="$(mktemp)"

  for tag in $tags; do
    created="$(
      regctl --host "$HOSTCFG" image config "${REGISTRY_HOST}/${repo}:${tag}" 2>/dev/null \
      | grep '"created"' \
      | head -n1 \
      | sed -E 's/.*"created":[[:space:]]*"([^"]+)".*/\1/' \
      || true
    )"

    [ -n "$created" ] || created="0000-00-00T00:00:00Z"
    printf "%s %s\n" "$created" "$tag" >> "$tmp"
  done

  del_tags="$(sort -r "$tmp" | tail -n +"$((KEEP_LAST+1))" | awk '{print $2}')"
  rm -f "$tmp"

  echo "Deleting:"
  for tag in $del_tags; do
    echo "  - ${repo}:${tag}"
    regctl --host "$HOSTCFG" tag delete "${REGISTRY_HOST}/${repo}:${tag}" || true
  done
  echo
done

echo "Done (manifests/tags deleted)."
echo "If you want disk space back, run registry garbage-collect."
