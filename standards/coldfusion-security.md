# Security — ColdFusion

## Overview

ColdFusion-specific security checks run during spec close security analysis.
Extends the generic checks in `security-network.md` and `security-surface.md`.
See `CLAUDE.md → Security Analysis` for how this file is used.

Add new checks as they are discovered during project work.

---

## Network

| Category | What to look for | Severity |
|---|---|---|
| **CFML Injection** | `#url.*#`, `#form.*#`, or `#cgi.*#` interpolated directly into `<cfquery>` — always use `<cfqueryparam>` with the correct `cfsqltype` | CRITICAL |
| **XSS via cfoutput** | `<cfoutput>` rendering unsanitised URL, form, or cookie values — use `EncodeForHTML()` for HTML context and `EncodeForJavaScript()` for script context | CRITICAL |
| **HTTP method enforcement** | Pages that modify data but do not check `#cgi.request_method#` and reject non-POST requests | WARNING |
| **Verbose error responses** | `<cfcatch>` blocks that write `#cfcatch.detail#`, `#cfcatch.tagcontext#`, or `#cfcatch.stacktrace#` to the response — these expose file paths, line numbers, and query strings | WARNING |
| **Open redirect** | `<cflocation>` targets derived from `url.*` or `form.*` without an allowlist | WARNING |
| **Path traversal** | `<cffile>`, `<cfdirectory>`, or `<cfinclude>` using user-controlled values without strict path normalisation and prefix checks | CRITICAL |

---

## Memory and Runtime

| Category | What to look for | Severity |
|---|---|---|
| **Scope leakage** | Variables intended as request-local written to `variables` scope inside a CFC or shared template — can bleed across concurrent requests; use `var __x` inside `<cffunction>` or `local.*` in cfscript | WARNING |
| **Unvalidated deserialization** | User input passed to `Evaluate()`, `DE()`, or `wddxDeserialize()` without prior sanitisation — these execute arbitrary CFML | CRITICAL |
| **Insecure randomness** | `Rand()` or `RandRange()` used to generate security tokens, nonces, or session IDs — use `GenerateSecretKey("AES")` or `CreateUUID()` instead | WARNING |
| **Sensitive data in logs** | `<cflog>` calls that dump entire `form`, `url`, or `session` scopes — log only the fields needed | WARNING |
| **Secrets in source** | Hardcoded DSN passwords, API keys, or SMTP credentials in `.cfm` or `.cfc` files | CRITICAL |
| **Plaintext credential storage** | Passwords stored as plain text or with a reversible algorithm in the database | CRITICAL |
