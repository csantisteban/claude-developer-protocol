# Security — Visual Basic

## Overview

Visual Basic security checks run during spec close security analysis.
Extends the generic checks in `security-network.md` and `security-surface.md`.
Covers both eras - VB.NET (shares most of its risk surface with
`csharp-security.md`, since both compile to .NET IL) and VB6 (a genuinely
different, older risk profile with no structured exception handling and
COM-based APIs). See `CLAUDE.md → Security Analysis` for how this file is
used.

Add new checks as they are discovered during project work.

---

## VB.NET

| Category | What to look for | Severity |
|---|---|---|
| **SQL injection** | User input concatenated into a query string instead of parameterised `SqlCommand`/Entity Framework queries | CRITICAL |
| **Command injection** | `Process.Start` called with unsanitised user input as part of the command or arguments | CRITICAL |
| **Unvalidated deserialization** | `BinaryFormatter.Deserialize` or `XmlSerializer` used on data from an untrusted source without type restrictions | CRITICAL |
| **Swallowed exceptions** | `Catch ex As Exception` with an empty block or no logging - silently hides failures, including security-relevant ones | WARNING |
| **Insecure randomness** | `System.Random` used to generate security tokens, nonces, or session IDs - use `System.Security.Cryptography.RandomNumberGenerator` | CRITICAL |
| **TLS verification disabled** | `ServicePointManager.ServerCertificateValidationCallback` overridden to always return `True` | CRITICAL |
| **Secrets in source** | Hardcoded connection strings, passwords, or API keys in any `.vb` file or `App.config`/`Web.config` - including values labelled as examples | CRITICAL |

---

## VB6 (Legacy)

| Category | What to look for | Severity |
|---|---|---|
| **`On Error Resume Next` masking failures** | Used as a substitute for real error handling rather than around a specific, expected-to-fail statement - can silently continue past a security-relevant failure (e.g. a failed permission check) | WARNING |
| **SQL injection via string-built queries** | ADO/DAO queries built with string concatenation instead of parameterised commands - VB6 has no modern ORM, so this pattern is common | CRITICAL |
| **Unsafe API calls via Declare** | `Declare Function` calls into unmanaged Win32 DLLs with buffer sizes or pointers derived from user input, without bounds validation | CRITICAL |
| **Secrets in source or `.frm`/`.bas` files** | Hardcoded passwords, connection strings, or API keys - including values labelled as examples | CRITICAL |
| **Insecure randomness** | The `Rnd()` function used to generate security tokens or session identifiers - VB6 has no CSPRNG in the standard library; flag for a platform API (`CryptGenRandom` via `Declare`) if security tokens are needed | CRITICAL |
