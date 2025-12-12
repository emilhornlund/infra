# AGENTS.md - Repository Guidelines for Agentic Coding

## Build/Test Commands
This is a Docker Compose infrastructure repository - no traditional build/test commands.
- Validate compose files: `docker-compose -f stacks/[service]/docker-compose.yaml config`
- Test locally: `docker-compose -f stacks/[service]/docker-compose.yaml up --dry-run`
- Backup volumes: `./scripts/docker_volume_backup.sh`

## Code Style Guidelines

### Docker Compose Files
- Use YAML with 2-space indentation
- Services use kebab-case naming (e.g., `prod-quiz`, `quiz-service`)
- Always include `restart: unless-stopped`
- Use external `core-network` for service communication
- Environment files loaded via `env_file:` with specific ordering

### Environment Variables
- Use `VIRTUAL_HOST` and `LETSENCRYPT_HOST` for nginx-proxy integration
- Secrets managed via Portainer environment secrets, not committed
- Use descriptive env var names in UPPER_SNAKE_CASE

### File Organization
- Each stack in `stacks/[service]/` with its own folder
- Include `README.md` explaining service purpose and configuration
- Use separate compose files for environments (e.g., `docker-compose.prod.yaml`)
- Environment-specific files: `stacks.env`, `stacks.prod.env`, `stacks.beta.env`

### Volume Naming
- Use hyphenated naming: `[service]-[purpose]-volume`
- Example: `mongodb-data-volume`, `quiz-service-uploads-volume`

### Network Configuration
- All services connect to external `core-network` (172.20.0.0/16)
- Static IPs assigned where needed (e.g., Pi-hole at 172.20.0.8)

### Health Checks
- Include healthcheck directives for critical services
- Use appropriate intervals and test commands
