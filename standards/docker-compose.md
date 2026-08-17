# Docker Compose

## Overview

Standards for all Docker Compose files.

Formatting rules (indentation, quoting, booleans, null values, etc.) are
defined in `./yaml.md` and apply to all Compose files without exception.
This file defines only Docker Compose-specific conventions on top of that baseline.

---

## File Naming

| Context | File name |
|---|---|
| Primary compose file | `docker-compose.yml` |
| Production overrides | `docker-compose.prod.yml` |
| Local dev overrides | `docker-compose.local.yml` |
| CI overrides | `docker-compose.ci.yml` |

Never name the primary file `compose.yml` — `docker-compose.yml` is the
conventional name and is recognised automatically by the CLI without `-f`.

---

## File Structure Order

Every `docker-compose.yml` must follow this top-to-bottom structure:

1. Header comment
2. `version`
3. `services`
4. `networks` (if any)
5. `volumes` (if any)

```yaml
# Application stack — web server, API, and database
# See docker-compose.local.yml for local development overrides
---
version: "3.9"

services:
  # ...

networks:
  # ...

volumes:
  # ...
```

---

## Naming Conventions

| Element | Convention | Example |
|---|---|---|
| Service | `kebab-case` | `web-server`, `background-worker` |
| Network | `kebab-case` | `app-network`, `internal-network` |
| Named volume | `snake_case` with `_data` suffix | `postgres_data`, `redis_data` |
| Environment variable | `UPPER_SNAKE_CASE` | `DATABASE_URL`, `APP_PORT` |

---

## Images

Always pin image versions — never use `latest`. Unpinned images cause
silent breaking changes when the upstream image updates:

```yaml
# bad
image: postgres
image: postgres:latest

# good
image: postgres:16.2
image: node:20.11-alpine
```

Prefer slim or alpine variants for application images to reduce attack surface
and image size:

```yaml
# bad
image: node:20

# good
image: node:20.11-alpine
```

---

## Environment Variables

Never hardcode secrets or credentials directly in the Compose file.
Use a `.env` file or host environment variables for all sensitive values:

```yaml
# bad
services:
  db:
    environment:
      POSTGRES_PASSWORD: mysecretpassword

# good — value comes from .env or host environment
services:
  db:
    environment:
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
```

For non-sensitive values that have a sensible default, use the
`${VAR:-default}` syntax to document the default inline:

```yaml
services:
  app:
    environment:
      APP_PORT: ${APP_PORT:-8080}
      LOG_LEVEL: ${LOG_LEVEL:-info}
```

Group environment variables alphabetically within each service:

```yaml
# bad — arbitrary order
environment:
  DATABASE_URL: ${DATABASE_URL}
  APP_PORT: ${APP_PORT:-8080}
  DEBUG: ${DEBUG:-false}

# good — alphabetical
environment:
  APP_PORT: ${APP_PORT:-8080}
  DATABASE_URL: ${DATABASE_URL}
  DEBUG: ${DEBUG:-false}
```

---

## Ports

Only expose ports that are necessary. Map using the string form to avoid
YAML integer parsing issues with uncommon port numbers:

```yaml
# bad — integer form is ambiguous for some port numbers
ports:
  - 5432:5432

# good — string form is unambiguous
ports:
  - "5432:5432"
```

In local development, bind to `127.0.0.1` to avoid unintentionally exposing
services on the network:

```yaml
# bad — exposes on all interfaces
ports:
  - "5432:5432"

# good — local only
ports:
  - "127.0.0.1:5432:5432"
```

---

## Volumes

Always use named volumes for persistent data — never anonymous volumes or
bind mounts for data that must survive container restarts:

```yaml
# bad — anonymous volume, data is lost on container removal
services:
  db:
    volumes:
      - /var/lib/postgresql/data

# bad — bind mount is fragile across environments
services:
  db:
    volumes:
      - ./data:/var/lib/postgresql/data

# good — named volume, data persists
services:
  db:
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

Use bind mounts only for source code and config files in local development
overrides, not in the primary Compose file.

---

## Dependencies

Use `depends_on` with `condition: service_healthy` rather than
`condition: service_started` — a started container is not necessarily ready
to accept connections:

```yaml
# bad — service may not be ready yet
depends_on:
  - db

# good — waits for healthy status
depends_on:
  db:
    condition: service_healthy
```

---

## Health Checks

Define a `healthcheck` for every service that other services depend on.
Set conservative intervals and retries to avoid flapping during slow starts:

```yaml
services:
  db:
    image: postgres:16.2
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
```

---

## Restart Policy

Always define a restart policy. Use `unless-stopped` for long-running services
and `on-failure` for workers or jobs that should not restart indefinitely:

```yaml
# long-running service
services:
  app:
    restart: unless-stopped

# worker — restart on failure but not if manually stopped
services:
  worker:
    restart: on-failure
```

Never use `always` — it prevents intentional stops from being respected.

---

## YAML Anchors

Use YAML anchors (`&`) and aliases (`*`) via `x-` extension fields to avoid
repeating common configuration blocks:

```yaml
x-common-env: &common-env
  LOG_LEVEL: ${LOG_LEVEL:-info}
  APP_ENV: ${APP_ENV:-production}

services:
  app:
    environment:
      <<: *common-env
      APP_PORT: ${APP_PORT:-8080}

  worker:
    environment:
      <<: *common-env
      QUEUE_NAME: ${QUEUE_NAME:-default}
```

---

## What Claude Must Not Do

- Do not use `latest` or unpinned image tags
- Do not hardcode secrets, passwords, or API keys in the Compose file
- Do not use anonymous volumes for persistent data
- Do not use `depends_on` without a `condition` — always specify `service_healthy`
- Do not expose ports on all interfaces in local development — bind to `127.0.0.1`
- Do not use `restart: always` — use `unless-stopped` or `on-failure`
- Do not name the primary file `compose.yml` — use `docker-compose.yml`
- Do not add services, networks, or volumes not referenced in the current task
