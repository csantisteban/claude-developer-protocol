#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Config
# -----------------------------------------------------------------------------
BUCKET_BASE_URL="https://github.com/csantisteban/claude-developer-protocol/releases/latest/download"

# -----------------------------------------------------------------------------
# Argument parsing - req 12
# -----------------------------------------------------------------------------
FORCE=0
for arg in "$@"; do
    case "$arg" in
        --force) FORCE=1 ;;
    esac
done

# -----------------------------------------------------------------------------
# Pinned version check - req 13
# Runs before --force and before any network calls
# -----------------------------------------------------------------------------
if [ -f ".pinned-version" ]; then
    exit 0
fi

# -----------------------------------------------------------------------------
# Working directory guard
# autoupdate.sh must be run from the project root (the dir containing .claude/)
# -----------------------------------------------------------------------------
if [ ! -f ".claude/version.txt" ]; then
    echo "autoupdate.sh must be run from the project root (.claude/version.txt not found)." >&2
    exit 1
fi

# -----------------------------------------------------------------------------
# Cadence check - req 14
# -----------------------------------------------------------------------------
if [ "$FORCE" -eq 0 ] && [ -f ".claude/.last-update-check" ]; then
    LAST_CHECK=$(cat ".claude/.last-update-check")
    NOW=$(date +%s)
    if [ $(( NOW - LAST_CHECK )) -lt $(( 7 * 24 * 3600 )) ]; then
        exit 0
    fi
fi

# -----------------------------------------------------------------------------
# Version check - reqs 15-16
# -----------------------------------------------------------------------------
REMOTE_VERSION=$(curl -fsSL "${BUCKET_BASE_URL}/latest.txt")

if ! echo "$REMOTE_VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
    echo "Invalid version string from latest.txt: $REMOTE_VERSION" >&2
    exit 1
fi

INSTALLED_VERSION=$(cat ".claude/version.txt")

semver_gt() {
    # Returns 0 (true) if $1 > $2 in MAJOR.MINOR.PATCH ordering
    local IFS='.'
    local -a v1 v2
    read -ra v1 <<< "$1"
    read -ra v2 <<< "$2"
    local a1="${v1[0]:-0}" a2="${v1[1]:-0}" a3="${v1[2]:-0}"
    local b1="${v2[0]:-0}" b2="${v2[1]:-0}" b3="${v2[2]:-0}"
    if [ "$a1" -gt "$b1" ]; then return 0; fi
    if [ "$a1" -lt "$b1" ]; then return 1; fi
    if [ "$a2" -gt "$b2" ]; then return 0; fi
    if [ "$a2" -lt "$b2" ]; then return 1; fi
    if [ "$a3" -gt "$b3" ]; then return 0; fi
    return 1
}

if ! semver_gt "$REMOTE_VERSION" "$INSTALLED_VERSION"; then
    date +%s > ".claude/.last-update-check"
    exit 0
fi

# -----------------------------------------------------------------------------
# Pre-update snapshot - captures any local changes before overwriting
# -----------------------------------------------------------------------------
if git -C . rev-parse --git-dir > /dev/null 2>&1; then
    if ! git -C . diff --quiet || \
       ! git -C . diff --cached --quiet || \
       [ -n "$(git -C . ls-files --others --exclude-standard)" ]; then
        echo "Uncommitted changes found - creating pre-update snapshot..."
        git -C . add -A
        git -C . \
            -c user.name="cdp-update" \
            -c user.email="cdp@$(hostname)" \
            commit -m "chore(backup): pre-update snapshot at ${INSTALLED_VERSION}"
        echo "Snapshot committed."
    fi
fi

# -----------------------------------------------------------------------------
# Download to temp directory - reqs 17-20
# -----------------------------------------------------------------------------
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

curl -fsSL "${BUCKET_BASE_URL}/cdp-${REMOTE_VERSION}.zip" -o "${TMP_DIR}/cdp.zip"

# Verify SHA256 checksum before extracting
EXPECTED=$(curl -fsSL "${BUCKET_BASE_URL}/cdp-${REMOTE_VERSION}.zip.sha256")
SHA256CMD=$(command -v sha256sum 2>/dev/null || command -v shasum 2>/dev/null)
if [ -z "$SHA256CMD" ]; then
    echo "Warning: no sha256sum or shasum found - skipping checksum verification." >&2
elif [ "$(basename "$SHA256CMD")" = "shasum" ]; then
    ACTUAL=$("$SHA256CMD" -a 256 "${TMP_DIR}/cdp.zip" | awk '{print $1}')
else
    ACTUAL=$("$SHA256CMD" "${TMP_DIR}/cdp.zip" | awk '{print $1}')
fi
if [ -n "${ACTUAL:-}" ] && [ "$ACTUAL" != "$EXPECTED" ]; then
    echo "Checksum mismatch - aborting update." >&2
    exit 1
fi

# Screen zip entries for path traversal before extracting
if unzip -Z1 "${TMP_DIR}/cdp.zip" | grep -qE '^\.\.|^/|/\.\./'; then
    echo "Aborting: zip contains unsafe paths." >&2
    exit 1
fi

unzip -q "${TMP_DIR}/cdp.zip" -d "${TMP_DIR}/extract"

SRC="${TMP_DIR}/extract"

# -----------------------------------------------------------------------------
# Validate manifest.txt is present in the release package
# -----------------------------------------------------------------------------
if [ ! -f "${SRC}/manifest.txt" ]; then
    echo "Error: manifest.txt not found in release package - aborting." >&2
    exit 1
fi

# -----------------------------------------------------------------------------
# Back up existing templates before rsync overwrites them
# Old versions are preserved in .claude/old-versions/ (gitignored)
# -----------------------------------------------------------------------------
BACKUP_DIR=".claude/old-versions/${INSTALLED_VERSION}"

if [ -d ".claude/specs/spec-template" ]; then
    mkdir -p "${BACKUP_DIR}/specs"
    mv ".claude/specs/spec-template" "${BACKUP_DIR}/specs/spec-template"
fi

if [ -d ".claude/tasks/nnn-task-template" ]; then
    mkdir -p "${BACKUP_DIR}/tasks"
    mv ".claude/tasks/nnn-task-template" "${BACKUP_DIR}/tasks/nnn-task-template"
fi

if [ -d ".claude/tasks/000-sync-memory" ]; then
    mkdir -p "${BACKUP_DIR}/tasks"
    mv ".claude/tasks/000-sync-memory" "${BACKUP_DIR}/tasks/000-sync-memory"
fi

# -----------------------------------------------------------------------------
# Copy all protocol-owned files using manifest.txt as the exclusion list
# -----------------------------------------------------------------------------
rsync -a --exclude-from="${SRC}/manifest.txt" "${SRC}/" ".claude/"

chmod +x ".claude/autoupdate.sh"

# -----------------------------------------------------------------------------
# Ensure required .gitignore entries
# -----------------------------------------------------------------------------
gitignore_entries=(
    ".claude/specs/**/.last-hash"
    ".claude/tasks/**/.last-hash"
    ".claude/**/session.md"
    ".claude/local/overview.md"
)

touch ".gitignore"
# A missing trailing newline would merge the first appended entry onto the
# existing last line, producing a broken combined pattern.
if [ -s ".gitignore" ] && [ -n "$(tail -c 1 ".gitignore")" ]; then
    printf '\n' >> ".gitignore"
fi
for entry in "${gitignore_entries[@]}"; do
    if ! grep -qxF "${entry}" ".gitignore"; then
        echo "${entry}" >> ".gitignore"
    fi
done

# -----------------------------------------------------------------------------
# Write timestamp and report - reqs 21-22
# -----------------------------------------------------------------------------
date +%s > ".claude/.last-update-check"
echo "CDP updated: ${INSTALLED_VERSION} -> ${REMOTE_VERSION}."
if [ -d "${BACKUP_DIR}" ]; then
    echo "Templates backed up to .claude/old-versions/${INSTALLED_VERSION}/."
fi
