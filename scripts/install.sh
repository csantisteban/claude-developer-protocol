#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Config
# -----------------------------------------------------------------------------
BUCKET_BASE_URL="https://github.com/csantisteban/claude-developer-protocol/releases/latest/download"

# -----------------------------------------------------------------------------
# Fetch latest version
# -----------------------------------------------------------------------------
echo "Fetching latest version..."
VERSION=$(curl -fsSL "${BUCKET_BASE_URL}/latest.txt")

if [ -z "$VERSION" ]; then
    echo "Failed to determine latest version from ${BUCKET_BASE_URL}/latest.txt" >&2
    exit 1
fi

if ! echo "$VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
    echo "Invalid version string from latest.txt: $VERSION" >&2
    exit 1
fi

if [ -f ".claude/version.txt" ]; then
    echo "Reinstalling CDP ${VERSION}..."
else
    echo "Installing CDP ${VERSION}..."
fi

# -----------------------------------------------------------------------------
# Download to temp directory (cleaned up on exit)
# -----------------------------------------------------------------------------
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

ZIP_FILE="${TMP_DIR}/cdp-${VERSION}.zip"
curl -fsSL "${BUCKET_BASE_URL}/cdp-${VERSION}.zip" -o "$ZIP_FILE"

# -----------------------------------------------------------------------------
# Verify SHA256 checksum before extracting
# -----------------------------------------------------------------------------
EXPECTED=$(curl -fsSL "${BUCKET_BASE_URL}/cdp-${VERSION}.zip.sha256")
SHA256CMD=$(command -v sha256sum 2>/dev/null || command -v shasum 2>/dev/null)
if [ -z "$SHA256CMD" ]; then
    echo "Warning: no sha256sum or shasum found - skipping checksum verification." >&2
elif [ "$(basename "$SHA256CMD")" = "shasum" ]; then
    ACTUAL=$("$SHA256CMD" -a 256 "$ZIP_FILE" | awk '{print $1}')
else
    ACTUAL=$("$SHA256CMD" "$ZIP_FILE" | awk '{print $1}')
fi
if [ -n "${ACTUAL:-}" ] && [ "$ACTUAL" != "$EXPECTED" ]; then
    echo "Checksum mismatch - aborting installation." >&2
    exit 1
fi

# -----------------------------------------------------------------------------
# Extract to temp directory
# -----------------------------------------------------------------------------
# Screen zip entries for path traversal before extracting
if unzip -Z1 "$ZIP_FILE" | grep -qE '^\.\.|^/|/\.\./'; then
    echo "Aborting: zip contains unsafe paths." >&2
    exit 1
fi

unzip -q "$ZIP_FILE" -d "${TMP_DIR}/extract"

SRC="${TMP_DIR}/extract"

# -----------------------------------------------------------------------------
# Copy protocol files to .claude/
# Fresh install: copy everything except runtime state.
# Reinstall: exclude everything manifest.txt marks as operator-owned, using
# the same manifest-driven mechanism as autoupdate.sh - avoids maintaining a
# second, hand-duplicated exclude list that can drift out of sync (see
# .claude/specs/008-protocol-v1.4.2-improvements/memory.md for the prior
# minimal fix and why this recurrence triggered the structural one instead).
# -----------------------------------------------------------------------------
mkdir -p .claude
if [ -f ".claude/version.txt" ]; then
    rsync -a --exclude-from="${SRC}/manifest.txt" "${SRC}/" ".claude/"
else
    rsync -a --exclude='.last-update-check' --exclude='.pinned-version' \
        --exclude='old-versions/' "${SRC}/" ".claude/"
fi

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
# Verify
# -----------------------------------------------------------------------------
if [ ! -f ".claude/version.txt" ]; then
    echo "Installation failed: .claude/version.txt not found after extraction." >&2
    exit 1
fi

INSTALLED_VERSION="$(cat ".claude/version.txt")"
echo "CDP ${INSTALLED_VERSION} installed successfully."
