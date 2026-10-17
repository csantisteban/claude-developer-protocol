# Bash

## Overview

Standards for all Bash scripts, including utility scripts, deployment scripts,
and automation helpers.

The baseline is the **Google Shell Style Guide**:
https://google.github.io/styleguide/shellguide.html

This file defines only the rules that differ from or extend the Google baseline.
When in doubt, the Google guide is the authority.

Linting is enforced via **ShellCheck**:
https://www.shellcheck.net

All scripts must pass ShellCheck with no warnings before being committed.

---

## Rules That Override Google

### Shebang

Google permits `/bin/sh` for portable scripts. Always use `/usr/bin/env bash`
to ensure Bash 4+ features are available and the correct interpreter is resolved
from `PATH`:

```bash
# bad
#!/bin/sh
#!/bin/bash

# good
#!/usr/bin/env bash
```

### Strict Mode

Every script must enable strict mode immediately after the shebang:

```bash
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
```

- `-e` — exit immediately on error
- `-u` — treat unset variables as an error
- `-o pipefail` — catch errors inside pipelines, not just the last command
- `IFS` — prevent word splitting on spaces; only split on newlines and tabs

---

## Rules That Match Google (Key Reminders)

These Google rules are highlighted because they are commonly missed:

### File Naming

Script files must use `.sh` extension and `snake_case`:

```
# bad
deployApp.sh
Deploy-App.sh
runmigrations

# good
deploy_app.sh
run_migrations.sh
```

### Indentation and Line Length

- 2-space indentation — no tabs
- Maximum line length: 80 characters
- Break long commands with `\` and indent the continuation 4 spaces

```bash
# good
some_command \
    --flag-one value \
    --flag-two value
```

### Variable Declarations

- Local variables inside functions must use `local`
- Constants must be `UPPER_SNAKE_CASE` and declared at the top of the script
- All other variables use `lower_snake_case`
- Always brace variables: `"${var}"` not `"$var"`

```bash
# bad
NAME=$1
readonly BASE=/opt/app

# good
local name="${1}"
readonly BASE_DIR="/opt/app"
```

### Command Substitution

Always use `$(...)` — never backticks:

```bash
# bad
result=`date +%Y-%m-%d`

# good
result="$(date +%Y-%m-%d)"
```

---

## Functions

All reusable logic must be in functions. Scripts must follow this structure:

1. Shebang and strict mode
2. Constants
3. Function definitions
4. `main` function
5. Call to `main "$@"` as the last line

```bash
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() {
  echo "[$(date +%Y-%m-%dT%H:%M:%S)] $*"
}

main() {
  log "Starting"
  # ...
}

main "$@"
```

---

## Error Handling

Always provide a cleanup trap for temp files and other resources:

```bash
readonly TMP_FILE="$(mktemp)"

cleanup() {
  rm -f "${TMP_FILE}"
}
trap cleanup EXIT
```

Never silence errors with `|| true` unless the failure is explicitly acceptable.
Add a comment explaining why when you do:

```bash
# bad
some_command || true

# good — port may not be in use yet, failure is expected on first run
lsof -ti :"${PORT}" | xargs kill || true
```

---

## What Claude Must Not Do

- Do not write scripts without `set -euo pipefail` and the `IFS` assignment
- Do not use backtick command substitution
- Do not use `#!/bin/sh` or `#!/bin/bash` as the shebang
- Do not commit a script that produces ShellCheck warnings
- Do not use unbraced variables: `$var` must always be `"${var}"`
