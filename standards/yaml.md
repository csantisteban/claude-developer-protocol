# YAML

## Overview

Standards for all YAML files, including configuration, CI/CD pipelines,
Docker Compose, and infrastructure definitions.

Unlike other standards in this directory, there is no single authoritative
external style guide for YAML. This file is the complete standard — all rules
are defined here.

Linting is enforced via **yamllint**:
https://yamllint.readthedocs.io

All files must pass yamllint with no warnings before being committed.

---

## Indentation

Always use 2-space indentation — no tabs, never 4 spaces:

```yaml
# bad
service:
    name: my-app
    port: 8080

# good
service:
  name: my-app
  port: 8080
```

---

## Quoting

Only quote strings when necessary. Necessary means the value would otherwise
be misread as another type (boolean, number, null) or contains special
characters:

```yaml
# bad — unnecessary quotes
name: "my-app"
version: "latest"

# good — no quotes needed
name: my-app
version: latest

# good — quotes required to preserve string type
enabled: "true"      # without quotes, this is a boolean
port: "8080"         # without quotes, this is an integer
value: "null"        # without quotes, this is null
path: "key: value"   # contains a colon followed by a space
```

Use double quotes (`"`) for strings that require quoting — never single quotes
unless the string itself contains double quotes.

---

## Booleans

Always use `true` and `false`. Never use `yes`, `no`, `on`, or `off` — these
are valid YAML booleans in older specs but ambiguous and error-prone:

```yaml
# bad
enabled: yes
debug: on
active: no

# good
enabled: true
debug: true
active: false
```

---

## Null Values

Always use `null` explicitly. Never use `~` or leave a value blank:

```yaml
# bad
middle_name: ~
nickname:

# good
middle_name: null
```

---

## Numbers

Do not quote numbers unless you explicitly need a string type.
Use underscores for large integers to aid readability:

```yaml
# bad
max_connections: "100"
timeout_ms: "30000"

# good
max_connections: 100
timeout_ms: 30_000
```

---

## Multi-line Strings

Use the literal block scalar (`|`) when line breaks are significant (e.g. shell
scripts, SQL, structured text). Use the folded block scalar (`>`) when line
breaks are cosmetic and the string should be treated as a single paragraph:

```yaml
# literal — line breaks preserved
script: |
  #!/usr/bin/env bash
  set -euo pipefail
  echo "Starting deployment"

# folded — line breaks collapsed into spaces
description: >
  This service handles all inbound webhook events
  and routes them to the appropriate processor.
```

Never use multi-line strings with concatenated quoted values:

```yaml
# bad
message: "This is a long message that " +
         "spans multiple lines"

# good
message: >
  This is a long message that
  spans multiple lines.
```

---

## Lists

Always use block style for lists — never inline (flow) style unless the list
is short and fits on one line as a scalar value:

```yaml
# bad
ports: [80, 443, 8080]

# good — block style
ports:
  - 80
  - 443
  - 8080

# acceptable — short inline list as a value
allowed_methods: [GET, POST]
```

---

## Mappings

Always use block style for mappings — never inline (flow) style:

```yaml
# bad
server: {host: localhost, port: 8080}

# good
server:
  host: localhost
  port: 8080
```

---

## Keys

Always use `snake_case` for keys — no `camelCase`, no `kebab-case`,
no `PascalCase`:

```yaml
# bad
maxConnections: 100
max-connections: 100
MaxConnections: 100

# good
max_connections: 100
```

---

## Comments

Use `#` followed by a single space. Comments should explain why, not what.
Place comments on the line above the key they describe, not inline, unless
the comment is very short:

```yaml
# bad — explains what, not why
# Set max connections
max_connections: 100

# bad — inline comment is too long
max_connections: 100  # this controls the maximum number of simultaneous database connections allowed

# good — explains why
# Capped at 100 to stay within the database server's connection limit
max_connections: 100

# acceptable — short inline comment
debug: false  # enable in local only
```

---

## File Structure

Every YAML file must start with a comment block identifying its purpose,
followed by the document start marker (`---`):

```yaml
# Application base configuration
# Applies to all environments — see app.local.config for local overrides
---
app:
  name: my-app
  version: 1.0.0
```

---

## File Naming

Use `kebab-case` for all YAML file names. Use `.yml` as the extension —
not `.yaml`:

```
# bad
app_config.yaml
AppConfig.yml
appconfig.yml

# good
app-config.yml
docker-compose.yml
github-actions.yml
```

---

## What Claude Must Not Do

- Do not use tabs for indentation — always 2 spaces
- Do not use `yes`, `no`, `on`, or `off` as boolean values
- Do not use `~` or blank values for null — always use `null`
- Do not use inline (flow) style for lists or mappings
- Do not use single quotes for quoting — use double quotes
- Do not quote strings that do not require quoting
- Do not use `camelCase` or `kebab-case` for keys
- Do not use `.yaml` as the file extension — always `.yml`
- Do not commit a file that produces yamllint warnings
