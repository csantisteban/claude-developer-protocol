# Security — PowerShell

## Overview

PowerShell-specific security checks run during spec close security analysis.
Extends the generic checks in `security-network.md` and `security-surface.md`.
See `CLAUDE.md -> Security Analysis` for how this file is used.

Add new checks as they are discovered during project work.

---

## Network

| Category | What to look for | Severity |
|---|---|---|
| **Command injection via Invoke-Expression** | User-controlled strings passed to `Invoke-Expression`, `Invoke-Command -ScriptBlock ([scriptblock]::Create(...))`, or `& $userInput` - these execute arbitrary PowerShell | CRITICAL |
| **Unvalidated URL in web calls** | `Invoke-WebRequest` or `Invoke-RestMethod` called with a URL derived from user input or an environment variable without validation - enables SSRF | CRITICAL |
| **TLS/SSL bypass** | `[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }` or `-SkipCertificateCheck` used outside an explicitly documented test context | CRITICAL |
| **Credential in command string** | Passwords or tokens passed as plain-text arguments on a command line (e.g. `-Password $PlainText`) rather than as a `[SecureString]` or `[PSCredential]` - visible in process lists and logs | WARNING |
| **Unencrypted credential transmission** | `Invoke-RestMethod` or `Invoke-WebRequest` calls over `http://` that include credentials or session tokens | WARNING |
| **Open redirect via Start-Process / Start-BrowserProcess** | URLs passed to `Start-Process` derived from user input without an allowlist | WARNING |

---

## Memory and Runtime

| Category | What to look for | Severity |
|---|---|---|
| **Secrets in source** | Hardcoded passwords, API keys, connection strings, or tokens in `.ps1`, `.psm1`, or `.psd1` files - including values labelled as examples or placeholders | CRITICAL |
| **ConvertTo-SecureString with plain text** | `ConvertTo-SecureString -String $value -AsPlainText -Force` used outside of a controlled bootstrap context - the plain-text value remains in memory and may appear in logs | WARNING |
| **Sensitive data in transcripts or logs** | `Write-Host`, `Write-Output`, `Write-Information`, or `Add-Content` calls that emit passwords, tokens, PII, or full credential objects - transcript logging captures all output streams | WARNING |
| **Insecure randomness** | `Get-Random` used to generate security tokens, nonces, or session IDs - use `[System.Security.Cryptography.RandomNumberGenerator]` instead | WARNING |
| **Plaintext credential storage** | Credentials exported with `Export-Clixml` on a shared or non-owner-controlled path - `Export-Clixml` encrypts with DPAPI but the file is readable by any process running as the same user | WARNING |
| **Unrestricted execution policy set in script** | `Set-ExecutionPolicy Unrestricted` or `Set-ExecutionPolicy Bypass` called inside a script rather than scoped to a session with `-Scope Process` | WARNING |
| **Unvalidated deserialization** | `Import-Clixml`, `ConvertFrom-Json`, or `[System.Runtime.Serialization.Formatters.Binary.BinaryFormatter]` used on data from an untrusted source without schema validation | CRITICAL |
| **Environment variable secrets** | Secrets read from `$env:*` variables and then written to a log, a file, or an interpolated command string where they may be captured | WARNING |
| **Dependency vulnerabilities** | Modules installed via `Install-Module` or referenced in a `RequiredModules` manifest modified in this spec - flag for a review against known CVEs in the PowerShell Gallery | INFO |
