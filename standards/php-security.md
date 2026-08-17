# Security — PHP

## Overview

PHP-specific security checks run during spec close security analysis.
Extends the generic checks in `security-network.md` and `security-surface.md`.
PHP has a long history of web-application-class vulnerabilities - these
checks weight that history heavily. See `CLAUDE.md → Security Analysis` for
how this file is used.

Add new checks as they are discovered during project work.

---

## Network

| Category | What to look for | Severity |
|---|---|---|
| **SQL injection** | User input concatenated into a query string instead of PDO/mysqli prepared statements with bound parameters | CRITICAL |
| **Command injection** | `exec`, `shell_exec`, `system`, `passthru`, or backticks called with unsanitised user input | CRITICAL |
| **Remote/local file inclusion** | `include`/`require` (or `_once` variants) called with a path built from user input - enables RFI/LFI, one of PHP's signature vulnerability classes | CRITICAL |
| **Unsafe deserialization** | `unserialize()` called on data from an untrusted source without `['allowed_classes' => false]` - PHP object injection | CRITICAL |
| **`eval()` on untrusted input** | `eval()`, `create_function()`, or `assert()` with a string argument derived from user input | CRITICAL |
| **XSS** | User input echoed into an HTML response without `htmlspecialchars()`/`htmlentities()` - a template engine's autoescaping is acceptable, raw `echo $userInput` is not | CRITICAL |
| **Path traversal** | File paths built from user input without `realpath()` + a prefix check against an expected root | CRITICAL |
| **SSRF** | `file_get_contents`, `curl`, or `Guzzle` calls where the URL is partially or fully user-controlled without an allowlist | CRITICAL |
| **CSRF** | State-changing forms/endpoints without a CSRF token validated server-side | WARNING |

---

## Memory and Runtime

| Category | What to look for | Severity |
|---|---|---|
| **Secrets in source** | Hardcoded passwords, API keys, or database credentials in any `.php` file - including values labelled as examples; use environment variables or a gitignored config instead | CRITICAL |
| **Plaintext password storage** | Passwords stored as plain text or hashed with `md5()`/`sha1()` instead of `password_hash()` (bcrypt/Argon2) | CRITICAL |
| **Insecure randomness** | `rand()`/`mt_rand()` used to generate security tokens, session IDs, or CSRF values - use `random_bytes()`/`random_int()` | CRITICAL |
| **Session fixation** | Session ID not regenerated (`session_regenerate_id(true)`) after a privilege change (login, role escalation) | WARNING |
| **Sensitive data in logs** | `error_log`/`var_dump` calls left in code paths that could emit tokens, passwords, or PII in production | WARNING |
| **Dependency vulnerabilities** | `composer.json`/`composer.lock` modified in this spec - flag for a `composer audit` review | INFO |
| **Timing attack** | Token or password comparison using `==`/`===` instead of `hash_equals()` | WARNING |
