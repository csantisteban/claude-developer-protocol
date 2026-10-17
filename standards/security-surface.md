# Security — Memory, Runtime, and Data Exposure

## Overview

Checks for memory, runtime, and data-exposure vulnerabilities run during spec close security analysis.
See `CLAUDE.md → Security Analysis` for how this file is used.

Stack-specific checks live in the named language files (e.g. `coldfusion-security.md`, `javascript-security.md`).

---

## Checks

| Category | What to look for | Default Severity |
|---|---|---|
| **Secrets in source** | Hardcoded passwords, API keys, tokens, or connection strings in any committed file | CRITICAL |
| **Sensitive data in logs** | Passwords, tokens, PII, or card numbers written to any logging call | WARNING |
| **Sensitive data in error responses** | Internal identifiers, field names, or stack traces exposed in API error bodies | WARNING |
| **Plaintext credential storage** | Passwords stored as plain text in the database rather than as a salted hash (bcrypt, Argon2) | CRITICAL |
| **Insecure randomness** | Use of non-cryptographic random functions for security tokens, nonces, or session IDs | WARNING |
| **Unvalidated deserialization** | User-supplied data passed to a deserialisation function without type or schema validation | CRITICAL |
| **Unsafe object references in memory** | Shared mutable state accessible across requests or users in a long-running process | WARNING |
| **Resource exhaustion** | Unbounded queries with no `LIMIT` / `MAXROWS`, or file uploads with no maximum size check | WARNING |
| **Dependency vulnerabilities** | Third-party packages with known CVEs — flag if a lockfile or manifest was modified in this spec | INFO |
| **Timing attacks** | Secrets or tokens compared with standard string equality instead of a constant-time comparison | INFO |


