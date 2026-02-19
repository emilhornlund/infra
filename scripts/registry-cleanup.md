# Registry Cleanup

A shell script that removes old image tags from the private Docker registry, keeping only the most recent `N` tags per repository.

---

## How It Works

For each repository in the allowlist the script:

1. Lists all tags from the registry.
2. Fetches the `created` timestamp from each image's config.
3. Sorts tags by creation date (newest first) and deletes every tag beyond the `KEEP_LAST` threshold.

Deleted tags free up manifest references but **do not reclaim disk space** until a garbage-collect pass is run (see below).

---

## Prerequisites

Install [`regctl`](https://github.com/regclient/regclient) on the host that will run the script:

```bash
sudo curl -L -o /usr/local/bin/regctl \
  https://github.com/regclient/regclient/releases/latest/download/regctl-linux-amd64
sudo chmod +x /usr/local/bin/regctl
regctl version
```

---

## Configuration

The script is configured via environment variables:

| Variable          | Default                       | Required | Description                                           |
|-------------------|-------------------------------|----------|-------------------------------------------------------|
| `REGISTRY_HOST`   | `emils-nuc-server:5000`       | No       | Hostname and port of the registry.                    |
| `REGISTRY_USER`   | –                             | **Yes**  | Registry username.                                    |
| `REGISTRY_PASS`   | –                             | **Yes**  | Registry password.                                    |
| `KEEP_LAST`       | `4`                           | No       | Number of most-recent tags to keep per repository.    |
| `REPOS_ALLOWLIST` | `klurigo-service klurigo-web` | No       | Space-separated list of repository names to clean up. |

---

## Usage

Export the required credentials and run the script:

```bash
export REGISTRY_USER="YOUR_USERNAME"
export REGISTRY_PASS="YOUR_PASSWORD"
./scripts/registry-cleanup.sh
```

Override optional variables as needed, for example:

```bash
export REGISTRY_USER="YOUR_USERNAME"
export REGISTRY_PASS="YOUR_PASSWORD"
export KEEP_LAST=2
export REPOS_ALLOWLIST="klurigo-service klurigo-web"
./scripts/registry-cleanup.sh
```

---

## Reclaiming Disk Space (Garbage Collection)

Deleting tags only removes manifest references. To actually free disk space, run a garbage-collect pass.

1. **Stop** the registry container (e.g. via Portainer).
2. Run the garbage-collect command:

```bash
docker compose -f stacks/registry/docker-compose.yaml run --rm registry \
  registry garbage-collect /etc/docker/registry/config.yml
```

3. **Restart** the registry container.
