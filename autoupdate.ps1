#Requires -Version 5.1
<#
.SYNOPSIS
    Auto-updates the Claude Developer Protocol (CDP) in the current project.

.DESCRIPTION
    Checks for a newer CDP release on Backblaze and updates .claude\ if one is found.
    Runs automatically at session start (once every 7 days) or on demand with -Force.

    Run from your project root:

        powershell -ExecutionPolicy Bypass -File .claude\autoupdate.ps1

    Pass -Force to bypass the 7-day cadence check:

        powershell -ExecutionPolicy Bypass -File .claude\autoupdate.ps1 -Force
#>
[CmdletBinding()]
param(
    [switch]$Force
)

# -----------------------------------------------------------------------------
# Config
# -----------------------------------------------------------------------------
$BucketBaseUrl = "https://github.com/csantisteban/claude-developer-protocol/releases/latest/download"

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------
function ConvertTo-ResponseText {
    param($Content)
    if ($Content -is [byte[]]) {
        return [System.Text.Encoding]::UTF8.GetString($Content)
    }
    return $Content
}

function Compare-Semver {
    # Returns $true if $V1 > $V2 in MAJOR.MINOR.PATCH ordering
    param([string]$V1, [string]$V2)
    $a = $V1 -split '\.' | ForEach-Object { [int]$_ }
    $b = $V2 -split '\.' | ForEach-Object { [int]$_ }
    for ($i = 0; $i -lt 3; $i++) {
        $ai = if ($i -lt $a.Length) { $a[$i] } else { 0 }
        $bi = if ($i -lt $b.Length) { $b[$i] } else { 0 }
        if ($ai -gt $bi) { return $true }
        if ($ai -lt $bi) { return $false }
    }
    return $false
}

function Test-Excluded {
    # Returns $true if the relative file path matches an exclusion in manifest.txt.
    # Follows rsync --exclude-from pattern semantics:
    #   - A pattern starting with / is anchored to the sync root - it must match
    #     starting at the very first path segment, not at any depth
    #   - Pattern ending with / excludes an entire directory subtree
    #   - Pattern without / matches the filename (basename) only (any depth,
    #     unless anchored - then only the root-level file counts)
    #   - Pattern containing / (other than trailing) matches the full relative
    #     path - already inherently anchored at the root by construction below
    param([string]$RelativePath, [string[]]$Exclusions)

    $normalPath = $RelativePath.Replace('\', '/')
    $pathParts  = $normalPath -split '/'
    $fileName   = $pathParts[-1]

    foreach ($pattern in $Exclusions) {
        if ([string]::IsNullOrWhiteSpace($pattern) -or $pattern.StartsWith('#')) {
            continue
        }

        $anchored = $pattern.StartsWith('/')
        if ($anchored) {
            $pattern = $pattern.Substring(1)
        }

        if ($pattern.EndsWith('/')) {
            # Directory pattern - exclude if a directory prefix of the path matches
            $dirPattern = $pattern.TrimEnd('/')
            if ($anchored -and -not ($dirPattern -like '*/*')) {
                # Anchored simple directory name - only the first segment counts
                if ($pathParts.Length -gt 1 -and $pathParts[0] -like $dirPattern) { return $true }
                continue
            }
            for ($i = 0; $i -lt ($pathParts.Length - 1); $i++) {
                if ($dirPattern -like '*/*') {
                    # Path-based directory pattern (e.g. specs/00[1-9]*) - already
                    # anchored at the root, since the prefix always starts at index 0
                    $prefix = ($pathParts[0..$i] -join '/')
                    if ($prefix -like $dirPattern) { return $true }
                } else {
                    # Simple directory name pattern (e.g. knowledge), unanchored - any depth
                    if ($pathParts[$i] -like $dirPattern) { return $true }
                }
            }
        } elseif ($pattern -like '*/*') {
            # Path-based file pattern - match against the full relative path
            if ($normalPath -like $pattern) { return $true }
        } elseif ($anchored) {
            # Anchored simple file pattern - only matches at the sync root, not nested
            if ($normalPath -like $pattern) { return $true }
        } else {
            # Basename-only pattern, unanchored - match against the filename, any depth
            if ($fileName -like $pattern) { return $true }
        }
    }
    return $false
}

# -----------------------------------------------------------------------------
# Pinned version check - req 13
# Runs before -Force and before any network calls
# -----------------------------------------------------------------------------
if (Test-Path ".pinned-version") {
    exit 0
}

# -----------------------------------------------------------------------------
# Working directory guard
# autoupdate.ps1 must be run from the project root (the dir containing .claude\)
# -----------------------------------------------------------------------------
if (-not (Test-Path ".claude\version.txt")) {
    Write-Error "autoupdate.ps1 must be run from the project root (.claude\version.txt not found)."
    exit 1
}

# -----------------------------------------------------------------------------
# Cadence check - req 14
# -----------------------------------------------------------------------------
# A non-numeric timestamp (empty, truncated, hand-edited) counts as "no
# previous check" instead of aborting every run until the file is deleted.
if (-not $Force -and (Test-Path ".claude\.last-update-check")) {
    $LastCheckRaw = "$(Get-Content ".claude\.last-update-check" -Raw)".Trim()
    $LastCheck    = [long]0
    if ([long]::TryParse($LastCheckRaw, [ref]$LastCheck)) {
        $Now = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
        if (($Now - $LastCheck) -lt (7 * 24 * 3600)) {
            exit 0
        }
    }
}

# -----------------------------------------------------------------------------
# Version check - reqs 15-16
# -----------------------------------------------------------------------------
try {
    $RemoteVersion = (ConvertTo-ResponseText (Invoke-WebRequest -Uri "$BucketBaseUrl/latest.txt" -UseBasicParsing).Content).Trim()
} catch {
    # Offline: the session-start check skips quietly; -Force reports the error.
    if ($Force) {
        Write-Error "Could not reach the CDP update server - check your connection. $_"
        exit 1
    }
    exit 0
}

if ($RemoteVersion -notmatch '^[0-9]+\.[0-9]+\.[0-9]+$') {
    Write-Error "Invalid version string from latest.txt: $RemoteVersion"
    exit 1
}

$InstalledVersion = (Get-Content ".claude\version.txt" -Raw).Trim()

if (-not (Compare-Semver -V1 $RemoteVersion -V2 $InstalledVersion)) {
    [DateTimeOffset]::UtcNow.ToUnixTimeSeconds() | Set-Content ".claude\.last-update-check"
    exit 0
}

# -----------------------------------------------------------------------------
# Clean working tree check - the update never commits; the human does
# Runtime-only paths written by this script are left out of the check.
# -----------------------------------------------------------------------------
git rev-parse --git-dir 2>$null | Out-Null
if ($LASTEXITCODE -eq 0) {
    $dirty = git status --porcelain -- . `
        ':(exclude).claude/.last-update-check' `
        ':(exclude).claude/old-versions' 2>$null
    if ($dirty) {
        Write-Error "Uncommitted changes - commit or stash them before updating CDP."
        exit 1
    }
}

# -----------------------------------------------------------------------------
# Download to temp directory - reqs 17-20
# -----------------------------------------------------------------------------
$TempDir     = Join-Path ([System.IO.Path]::GetTempPath()) ("cdp-update-" + [System.IO.Path]::GetRandomFileName())
$TempZip     = Join-Path $TempDir "cdp.zip"
$TempExtract = Join-Path $TempDir "extract"

New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

try {
    try {
        Invoke-WebRequest -Uri "$BucketBaseUrl/cdp-$RemoteVersion.zip" -OutFile $TempZip -UseBasicParsing
    } catch {
        Write-Error "Failed to download release package: $_"
        exit 1
    }

    # Verify SHA256 checksum before extracting
    try {
        $ExpectedHash = (ConvertTo-ResponseText (Invoke-WebRequest -Uri "$BucketBaseUrl/cdp-$RemoteVersion.zip.sha256" -UseBasicParsing).Content).Trim()
    } catch {
        Write-Error "Failed to fetch checksum: $_"
        exit 1
    }
    $ActualHash = (Get-FileHash -Path $TempZip -Algorithm SHA256).Hash.ToLower()
    if ($ActualHash -ne $ExpectedHash.ToLower()) {
        Write-Error "Checksum mismatch - aborting update."
        exit 1
    }

    # Screen zip entries for path traversal before extracting - any absolute
    # path (rooted or drive-qualified) or any path component that is exactly ".."
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zipFile = [System.IO.Compression.ZipFile]::OpenRead($TempZip)
    try {
        foreach ($entry in $zipFile.Entries) {
            $parts = $entry.FullName -split '[/\\]'
            if ($parts -contains '..' -or $entry.FullName -match '^([/\\]|[A-Za-z]:)') {
                Write-Error "Aborting: zip contains unsafe paths."
                exit 1
            }
        }
    } finally {
        $zipFile.Dispose()
    }

    Expand-Archive -Path $TempZip -DestinationPath $TempExtract -Force

    $SrcDir = $TempExtract

    # Refuse a package that contains symbolic links or other reparse points -
    # copied into .claude\, a link could later redirect reads or writes
    # outside the project
    $links = Get-ChildItem -Path $SrcDir -Recurse -Force |
        Where-Object { $_.Attributes -band [System.IO.FileAttributes]::ReparsePoint }
    if ($links) {
        Write-Error "Aborting: release package contains symbolic links."
        exit 1
    }

    # -------------------------------------------------------------------------
    # Validate manifest.txt is present in the release package
    # -------------------------------------------------------------------------
    if (-not (Test-Path "$SrcDir\manifest.txt")) {
        Write-Error "manifest.txt not found in release package - aborting."
        exit 1
    }

    # -------------------------------------------------------------------------
    # Back up existing templates before copy overwrites them
    # Old versions are preserved in .claude\old-versions\ (gitignored)
    # -------------------------------------------------------------------------
    $BackupDir = ".claude\old-versions\$InstalledVersion"

    foreach ($template in @(".claude\specs\spec-template",
                            ".claude\tasks\nnn-task-template",
                            ".claude\tasks\000-sync-memory")) {
        if ((Test-Path $template) -and
            ((Get-Item $template -Force).Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
            Write-Error "Aborting: $template is a symbolic link."
            exit 1
        }
    }

    if (Test-Path ".claude\specs\spec-template") {
        New-Item -ItemType Directory -Path "$BackupDir\specs" -Force | Out-Null
        Move-Item ".claude\specs\spec-template" "$BackupDir\specs\spec-template"
    }

    if (Test-Path ".claude\tasks\nnn-task-template") {
        New-Item -ItemType Directory -Path "$BackupDir\tasks" -Force | Out-Null
        Move-Item ".claude\tasks\nnn-task-template" "$BackupDir\tasks\nnn-task-template"
    }

    if (Test-Path ".claude\tasks\000-sync-memory") {
        if (-not (Test-Path "$BackupDir\tasks")) {
            New-Item -ItemType Directory -Path "$BackupDir\tasks" -Force | Out-Null
        }
        Move-Item ".claude\tasks\000-sync-memory" "$BackupDir\tasks\000-sync-memory"
    }

    # -------------------------------------------------------------------------
    # Copy all protocol-owned files using manifest.txt as the exclusion list
    # -------------------------------------------------------------------------
    $Exclusions = @(Get-Content "$SrcDir\manifest.txt" -ErrorAction SilentlyContinue) |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and -not $_.StartsWith('#') }

    Get-ChildItem -Path $SrcDir -Recurse -File | ForEach-Object {
        $relativePath = $_.FullName.Substring($SrcDir.Length).TrimStart('\/')

        if (-not (Test-Excluded -RelativePath $relativePath -Exclusions $Exclusions)) {
            $dest    = Join-Path ".claude" $relativePath
            $destDir = Split-Path $dest -Parent
            if (-not (Test-Path $destDir)) {
                New-Item -ItemType Directory -Path $destDir -Force | Out-Null
            }
            Copy-Item -Path $_.FullName -Destination $dest -Force
        }
    }

    # -------------------------------------------------------------------------
    # Ensure required .gitignore entries
    # -------------------------------------------------------------------------
    $GitignoreEntries = @(
        ".claude/specs/**/.last-hash",
        ".claude/tasks/**/.last-hash",
        ".claude/**/session.md",
        ".claude/local/overview.md",
        ".claude/.last-update-check",
        ".claude/old-versions/"
    )

    if (-not (Test-Path ".gitignore")) {
        New-Item -ItemType File -Path ".gitignore" | Out-Null
    }
    # A missing trailing newline would merge the first appended entry onto
    # the existing last line, producing a broken combined pattern.
    $RawContent = Get-Content ".gitignore" -Raw -ErrorAction SilentlyContinue
    if ($RawContent -and -not $RawContent.EndsWith("`n")) {
        Add-Content ".gitignore" ""
    }
    $ExistingLines = @(Get-Content ".gitignore" -ErrorAction SilentlyContinue)
    foreach ($Entry in $GitignoreEntries) {
        if ($ExistingLines -notcontains $Entry) {
            Add-Content ".gitignore" $Entry
            $ExistingLines += $Entry
        }
    }

    # -------------------------------------------------------------------------
    # Write timestamp and report - reqs 21-22
    # -------------------------------------------------------------------------
    [DateTimeOffset]::UtcNow.ToUnixTimeSeconds() | Set-Content ".claude\.last-update-check"
    Write-Host "CDP updated: $InstalledVersion -> $RemoteVersion."
    if (Test-Path $BackupDir) {
        Write-Host "Templates backed up to .claude\old-versions\$InstalledVersion\."
    }

} finally {
    if (Test-Path $TempDir) {
        Remove-Item $TempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
