## Configuration Files

This document lists all configuration files available in this project.
It is the reference Claude uses to locate settings, tokens, and environment-specific overrides.

> All paths are relative to the project root unless stated otherwise.

---

### Primary Configuration (Source of Truth)

These files are deployed to all environments and are the authoritative source of truth.

| File                    | Purpose                                      |
|-------------------------|----------------------------------------------|
| `./config/app.config`   | Base application settings for all environments |

---

### Environment Overrides

These files are for local development only and are never deployed. They take
**higher** precedence than the primary configuration when present.

| File                        | Purpose                              |
|-----------------------------|--------------------------------------|
| `./config/app.local.config` | Base config overrides for local development |

---

### Environment Variables

Variables injected at runtime via the host environment or a `.env` file.
Never hardcode these values in any config file.

| Variable     | Type    | Default | Purpose                          |
|--------------|---------|---------|----------------------------------|
| `is_local`   | Boolean | `false` | Flags the app as running locally |

---

### Secrets

Credentials, API keys, and tokens are never stored in config files or committed
to version control. Document where they are provisioned below.

| Secret            | Where it lives                              |
|-------------------|---------------------------------------------|
| `example_api_key` | Environment variable — set in host or `.env` |

---

### What Claude Must Not Do

- Do not hardcode secrets, tokens, or credentials in any config file
- Do not modify primary config files unless explicitly instructed in the current task
- Do not commit `.env` or local override files — these are always gitignored
- Do not infer missing config values — stop and ask if a required value is not documented here
