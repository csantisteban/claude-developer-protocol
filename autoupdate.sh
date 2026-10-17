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
# A non-numeric timestamp (empty, truncated, hand-edited) counts as "no
# previous check" instead of aborting every run until the file is deleted.
if [ "$FORCE" -eq 0 ] && [ -f ".claude/.last-update-check" ]; then
    LAST_CHECK=$(cat ".claude/.last-update-check")
    if [[ "$LAST_CHECK" =~ ^[0-9]+$ ]]; then
        NOW=$(date +%s)
        if [ $(( NOW - LAST_CHECK )) -lt $(( 7 * 24 * 3600 )) ]; then
            exit 0
        fi
    fi
fi

# -----------------------------------------------------------------------------
# Version check - reqs 15-16
# -----------------------------------------------------------------------------
# Offline: the session-start check skips quietly; --force reports the error.
if ! REMOTE_VERSION=$(curl -fsSL "${BUCKET_BASE_URL}/latest.txt" 2>/dev/null); then
    if [ "$FORCE" -eq 1 ]; then
        echo "Could not reach the CDP update server - check your connection." >&2
        exit 1
    fi
    exit 0
fi

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
# Clean working tree check - the update never commits; the human does
# Runtime-only paths written by this script are left out of the check.
# -----------------------------------------------------------------------------
if git -C . rev-parse --git-dir > /dev/null 2>&1; then
    if [ -n "$(git -C . status --porcelain -- . \
            ':(exclude).claude/.last-update-check' \
            ':(exclude).claude/old-versions')" ]; then
        echo "Uncommitted changes - commit or stash them before updating CDP." >&2
        exit 1
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
if command -v sha256sum > /dev/null 2>&1; then
    ACTUAL=$(sha256sum "${TMP_DIR}/cdp.zip" | awk '{print $1}')
elif command -v shasum > /dev/null 2>&1; then
    ACTUAL=$(shasum -a 256 "${TMP_DIR}/cdp.zip" | awk '{print $1}')
else
    echo "CDP update needs sha256sum or shasum to verify the release; install one and retry." >&2
    exit 1
fi
if [ "$ACTUAL" != "$EXPECTED" ]; then
    echo "Checksum mismatch - aborting update." >&2
    exit 1
fi

# Screen zip entries for path traversal before extracting - any absolute path
# or any path component that is exactly ".."
if unzip -Z1 "${TMP_DIR}/cdp.zip" | grep -qE '^/|(^|/)\.\.(/|$)'; then
    echo "Aborting: zip contains unsafe paths." >&2
    exit 1
fi

unzip -q "${TMP_DIR}/cdp.zip" -d "${TMP_DIR}/extract"

SRC="${TMP_DIR}/extract"

# Refuse a package that contains symbolic links - copied into .claude/, a link
# could later redirect reads or writes outside the project
if [ -n "$(find "${SRC}" -type l -print -quit)" ]; then
    echo "Aborting: release package contains symbolic links." >&2
    exit 1
fi

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

for template in ".claude/specs/spec-template" \
                ".claude/tasks/nnn-task-template" \
                ".claude/tasks/000-sync-memory"; do
    if [ -L "${template}" ]; then
        echo "Aborting: ${template} is a symbolic link." >&2
        exit 1
    fi
done

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
    ".claude/.last-update-check"
    ".claude/old-versions/"
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
