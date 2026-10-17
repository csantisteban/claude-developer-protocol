# PowerShell

## Overview

Standards for all PowerShell scripts, including utility scripts, deployment
scripts, and automation helpers.

The baseline is the **PowerShell Practice and Style Guide**:
https://poshcode.gitbook.io/powershell-practice-and-style

This file defines only the rules that differ from or extend that baseline.
When in doubt, the PoshCode guide is the authority.

Linting is enforced via **PSScriptAnalyzer**:
https://github.com/PowerShell/PSScriptAnalyzer

All scripts must pass PSScriptAnalyzer with no warnings before being committed:

```powershell
Invoke-ScriptAnalyzer -Path .\script.ps1 -Severity Warning,Error
```

---

## Rules That Override PoshCode

### Strict Mode

Every script must enable strict mode immediately after the `#Requires` block:

```powershell
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
```

- `Set-StrictMode -Version Latest` - treats uninitialized variables, missing
  properties, and other common mistakes as terminating errors
- `$ErrorActionPreference = 'Stop'` - converts non-terminating errors into
  terminating errors so they cannot be silently swallowed

### `#Requires` Block

Every script must declare its PowerShell version requirement as the first line:

```powershell
#Requires -Version 7.2
```

Use 7.2 as the minimum unless a specific constraint requires otherwise. Never
omit the `#Requires` block - silent version mismatches cause unpredictable
failures.

### Approved Verbs

All functions must use an approved PowerShell verb as the prefix. Never invent
verbs. Check the approved list before naming a function:

```powershell
# bad
function Fetch-Data { }
function DoWork { }

# good
function Get-Data { }
function Invoke-Work { }
```

Run `Get-Verb` to list all approved verbs.

---

## Rules That Match PoshCode (Key Reminders)

These PoshCode rules are highlighted because they are commonly missed:

### File Naming

Script files must use `.ps1` extension and `PascalCase` matching the primary
function or purpose of the script:

```
# bad
deploy_app.ps1
deployApp.ps1
RunMigrations.ps1

# good
Deploy-App.ps1
Invoke-Migration.ps1
```

Module files use `.psm1` and manifests use `.psd1`.

### Indentation and Line Length

- 4-space indentation - no tabs
- Maximum line length: 120 characters
- Break long pipelines and parameter lists with a backtick `` ` `` at the end
  of the line and indent the continuation 4 spaces. Prefer splatting over
  backtick line continuation where possible:

```powershell
# bad - backtick continuation
Invoke-Command -ComputerName $server `
    -ScriptBlock { Get-Process }

# good - splatting
$params = @{
    ComputerName = $server
    ScriptBlock  = { Get-Process }
}
Invoke-Command @params
```

### Variable Naming

- Script-level and local variables use `$PascalCase`
- Constants and environment-level values use `$UPPER_SNAKE_CASE`
- Loop variables and short-lived locals use `$camelCase`
- Always use explicit types in `param()` blocks

```powershell
# bad
$x = Get-Content $file
$SERVER_URL = 'https://example.com'

# good
[string] $Content = Get-Content -Path $FilePath
[string] $SERVER_URL = 'https://example.com'
```

### Parameters

All scripts and functions that accept input must use a `param()` block. Never
use `$args`. Always decorate with `[CmdletBinding()]`:

```powershell
# bad
function Deploy-App {
    $name = $args[0]
}

# good
function Deploy-App {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $AppName,

        [Parameter()]
        [ValidateSet('dev', 'staging', 'prod')]
        [string] $Environment = 'dev'
    )
}
```

### Comparison Operators

Always use PowerShell comparison operators. Never use `=` for comparison:

```powershell
# bad
if ($value = $null) { }
if ($status == 'active') { }

# good
if ($value -eq $null) { }
if ($status -eq 'active') { }
```

Prefer `-is` and `-isnot` for type checks over casting and comparison:

```powershell
# bad
if ($obj.GetType() -eq [string]) { }

# good
if ($obj -is [string]) { }
```

### String Handling

Use double-quoted strings for interpolation. Use single-quoted strings for
literals that contain no variables. Never use string concatenation with `+`:

```powershell
# bad
$message = 'Hello ' + $name
$path = "C:\fixed\literal\path"

# good
$message = "Hello $name"
$path = 'C:\fixed\literal\path'
$multiline = @"
Line one for $name
Line two
"@
```

### Pipelines

Prefer pipeline over loops where the intent is clear and the operation is
simple. Break pipelines longer than two stages onto multiple lines:

```powershell
# bad - loop where a pipeline reads better
$results = @()
foreach ($item in $items) {
    $results += $item | Where-Object { $_.Active }
}

# good - pipeline
$results = $items |
    Where-Object { $_.Active } |
    Select-Object -Property Name, Id
```

---

## Functions

All reusable logic must be in functions. Scripts must follow this structure:

1. `#Requires` block
2. `Set-StrictMode` and `$ErrorActionPreference`
3. Constants and configuration
4. Helper function definitions
5. Main entry-point function
6. Call to the main function at the bottom

```powershell
#Requires -Version 7.2

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

[string] $SCRIPT_DIR = $PSScriptRoot

function Write-Log {
    [CmdletBinding()]
    param([string] $Message)
    Write-Information "[$(Get-Date -Format 'o')] $Message" -InformationAction Continue
}

function Invoke-Main {
    [CmdletBinding()]
    param()

    Write-Log -Message 'Starting'
    # ...
}

Invoke-Main
```

---

## Error Handling

Use `try / catch / finally` for all error-prone operations. Always clean up
resources in `finally`, not in `catch`:

```powershell
# bad - cleanup only on error
try {
    $TempFile = New-TemporaryFile
    # work...
} catch {
    Remove-Item -Path $TempFile -ErrorAction SilentlyContinue
    throw
}

# good - cleanup always runs
$TempFile = New-TemporaryFile
try {
    # work...
} finally {
    Remove-Item -Path $TempFile -ErrorAction SilentlyContinue
}
```

Never swallow errors with an empty `catch` block. If a failure is explicitly
acceptable, document why with a comment:

```powershell
# bad
try { Stop-Service -Name $ServiceName } catch { }

# good - service may already be stopped on first run
try {
    Stop-Service -Name $ServiceName
} catch [Microsoft.PowerShell.Commands.ServiceCommandException] {
    Write-Log -Message "Service '$ServiceName' was not running - skipping stop"
}
```

Always rethrow unexpected errors after logging:

```powershell
} catch {
    Write-Error "Unexpected error in Deploy-App: $_"
    throw
}
```

---

## Output

Use `Write-Information` for progress and status messages. Never use
`Write-Host` - it bypasses the output stream and cannot be captured or
redirected. Use `Write-Verbose` for debug-level detail behind the
`-Verbose` flag:

```powershell
# bad
Write-Host "Deploying $AppName..."

# good
Write-Information "Deploying $AppName..." -InformationAction Continue
Write-Verbose "Connecting to $ServerUrl with timeout $TimeoutSeconds"
```

---

## What Claude Must Not Do

- Do not write scripts without `Set-StrictMode -Version Latest` and
  `$ErrorActionPreference = 'Stop'`
- Do not omit the `#Requires -Version` block
- Do not use `$args` - always use a `param()` block with `[CmdletBinding()]`
- Do not use unapproved verbs in function names
- Do not use `Write-Host` - use `Write-Information` or `Write-Verbose`
- Do not use `+` for string concatenation - use interpolation or here-strings
- Do not use an empty `catch` block to swallow errors silently
- Do not commit a script that produces PSScriptAnalyzer warnings
