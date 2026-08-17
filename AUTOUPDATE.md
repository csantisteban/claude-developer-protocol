# AUTOUPDATE - CDP Auto-Update Procedure

Read this file on demand. Claude reads it at session start (unless `.pinned-version`
exists) and when the user requests a manual protocol update.

---

## Overview

CDP checks for protocol updates automatically once every 7 days at session
start, unless the project is pinned via `.pinned-version`. The same update
script also runs on demand when the human asks to update the protocol.

---

## Session-Start Autoupdate

Run this procedure once at each session start, after the Open-Spec Check.

### Step 1 - Pinned version check

```bash
test -f .pinned-version && echo "pinned" || echo "ok"
```

If the file exists, stop here. Skip the update silently - do not mention the check
to the human.

### Step 2 - Git safety check

```bash
git status --porcelain
```

If the output is non-empty (uncommitted changes exist), prompt the human:

> *"There are uncommitted changes. Please commit or stash them before the protocol
> update so the update has its own clean commit."*

Do not proceed until the working tree is clean.

### Step 3 - Run the update script

Detect the OS and run the appropriate script:

```bash
if uname -s 2>/dev/null | grep -qiE 'mingw|msys|cygwin'; then
    powershell.exe -ExecutionPolicy Bypass -File .claude/autoupdate.ps1
else
    bash .claude/autoupdate.sh
fi
```

### Step 4 - Commit if updated

If the script printed a line matching `CDP updated: ... -> {version}`, stage and
commit everything the update changed:

```bash
git add .claude/
git commit -m "chore: update CDP to {version}"
```

**Why `git add .claude/` is safe here, not a risk of over-staging:** Step 2
already required a clean working tree before the update ran, and rsync (Step 3)
already used `manifest.txt` to decide what to touch. Since nothing else could
have changed the tree in between, whatever `git status` shows now is exactly
what the update changed - already manifest-compliant with no re-parsing
needed. Runtime-only paths (`session.md`, `.last-hash`, `old-versions/`,
`.last-update-check`) are excluded by `.gitignore`, so they are never staged
either way. This also means the commit step never drifts as new protocol
files are added - there is no list here to keep in sync.

---

## User-Initiated Update

Run this procedure when the human asks to update the protocol (e.g. "update the
protocol", "run the autoupdate", "check for protocol updates").

### Step 1 - Pinned version check

```bash
test -f .pinned-version && echo "pinned" || echo "ok"
```

If the file exists, inform the human and stop:

> *"The protocol is pinned at the version in `.pinned-version`. Remove that file
> to allow updates."*

Do not run the update script.

### Step 2 - Git safety check

Same as Session-Start Step 2 above.

### Step 3 - Run the update script with --force

Detect the OS and run the appropriate script:

```bash
if uname -s 2>/dev/null | grep -qiE 'mingw|msys|cygwin'; then
    powershell.exe -ExecutionPolicy Bypass -File .claude/autoupdate.ps1 -Force
else
    bash .claude/autoupdate.sh --force
fi
```

### Step 4 - Commit if updated

Same as Session-Start Step 4 above.