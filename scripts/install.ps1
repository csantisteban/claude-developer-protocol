#Requires -Version 5.1
<#
.SYNOPSIS
    Installs the Claude Developer Protocol (CDP) into the current project.

.DESCRIPTION
    Downloads and extracts the latest CDP release into a .claude\ subdirectory
    of the current working directory.

    Run from your project root:

        powershell -ExecutionPolicy Bypass -File .\cdp_install.ps1

    If you prefer to allow local scripts permanently for your user account:

        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

    Then run the script normally:

        .\cdp_install.ps1
#>
[CmdletBinding()]
param()

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

# -----------------------------------------------------------------------------
# Guard: already installed
# -----------------------------------------------------------------------------
if (Test-Path ".claude\version.txt") {
    Write-Error "CDP is already installed (.claude\version.txt exists). Aborting."
    exit 1
}

# -----------------------------------------------------------------------------
# Fetch latest version
# -----------------------------------------------------------------------------
Write-Host "Fetching latest version..."

try {
    $Version = (ConvertTo-ResponseText (Invoke-WebRequest -Uri "$BucketBaseUrl/latest.txt" -UseBasicParsing).Content).Trim()
} catch {
    Write-Error "Failed to fetch latest version from $BucketBaseUrl/latest.txt: $_"
    exit 1
}

if ([string]::IsNullOrWhiteSpace($Version)) {
    Write-Error "latest.txt was empty or could not be read."
    exit 1
}

if ($Version -notmatch '^[0-9]+\.[0-9]+\.[0-9]+$') {
    Write-Error "Invalid version string from latest.txt: $Version"
    exit 1
}

Write-Host "Installing CDP $Version..."

# -----------------------------------------------------------------------------
# Download to temp file (cleaned up in finally block)
# -----------------------------------------------------------------------------
$TempFile = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "cdp-$Version.zip")
$TempExtract = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "cdp-extract-$Version")

try {
    Invoke-WebRequest -Uri "$BucketBaseUrl/cdp-$Version.zip" -OutFile $TempFile -UseBasicParsing

    # -----------------------------------------------------------------------------
    # Verify SHA256 checksum before extracting
    # -----------------------------------------------------------------------------
    $ExpectedHash = (ConvertTo-ResponseText (Invoke-WebRequest -Uri "$BucketBaseUrl/cdp-$Version.zip.sha256" -UseBasicParsing).Content).Trim()
    $ActualHash   = (Get-FileHash -Path $TempFile -Algorithm SHA256).Hash.ToLower()
    if ($ActualHash -ne $ExpectedHash.ToLower()) {
        Write-Error "Checksum mismatch - aborting installation."
        exit 1
    }

    # -----------------------------------------------------------------------------
    # Extract into .claude\
    # -----------------------------------------------------------------------------
    if (-not (Test-Path ".claude")) {
        New-Item -ItemType Directory -Path ".claude" -Force | Out-Null
    }

    Expand-Archive -Path $TempFile -DestinationPath ".claude" -Force

    # -----------------------------------------------------------------------------
    # Verify
    # -----------------------------------------------------------------------------
    if (-not (Test-Path ".claude\version.txt")) {
        Write-Error "Installation failed: .claude\version.txt not found after extraction."
        exit 1
    }

    # -----------------------------------------------------------------------------
    # Ensure required .gitignore entries
    # -----------------------------------------------------------------------------
    $GitignoreEntries = @(
        ".claude/specs/**/.last-hash",
        ".claude/tasks/**/.last-hash",
        ".claude/**/session.md",
        ".claude/local/overview.md"
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

    Write-Host "CDP $Version installed successfully."

} finally {
    if (Test-Path $TempFile)    { Remove-Item $TempFile    -Force -ErrorAction SilentlyContinue }
    if (Test-Path $TempExtract) { Remove-Item $TempExtract -Recurse -Force -ErrorAction SilentlyContinue }
}
