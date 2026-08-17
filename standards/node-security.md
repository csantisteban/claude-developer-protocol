# Security — Node.js

## Overview

Node.js-specific security checks run during spec close security analysis.
Extends the generic checks in `security-network.md`, `security-surface.md`,
and `javascript-security.md` (browser-oriented JS checks still apply to
Node code sharing that syntax). This file covers what is specific to
Node's server runtime and npm ecosystem. See `CLAUDE.md → Security
Analysis` for how this file is used.

Add new checks as they are discovered during project work.

---

## Network and Process

| Category | What to look for | Severity |
|---|---|---|
| **Command injection** | `child_process.exec`/`execSync` called with a command string built from unsanitised input - use `execFile`/`spawn` with an argument array instead, which does not go through a shell | CRITICAL |
| **Path traversal** | File paths built from user input with `path.join` without verifying the resolved path (`path.resolve` + prefix check) stays under an expected root | CRITICAL |
| **Prototype pollution** | Deep-merge or recursive-assignment utilities (including hand-rolled ones) operating on user-controlled JSON without guarding against `__proto__`/`constructor.prototype` keys | CRITICAL |
| **SSRF** | `http`/`https`/`fetch`/`axios` calls where the URL is partially or fully user-controlled without an allowlist | CRITICAL |
| **ReDoS (event-loop DoS)** | A regex with nested quantifiers applied to user-controlled input on a request-handling path - catastrophic backtracking blocks the single-threaded event loop for every concurrent request, not just the attacker's | CRITICAL |
| **Unbounded body/upload size** | Request body or file upload parsing with no configured size limit | WARNING |
| **Unvalidated deserialization** | `JSON.parse` output used to drive privileged logic (e.g. as an object key controlling behavior) without validating against an expected schema | WARNING |

---

## Supply Chain and Runtime

| Category | What to look for | Severity |
|---|---|---|
| **Secrets in source** | Hardcoded passwords, API keys, or tokens in any `.js`/`.ts`/`.json` file - including values labelled as examples; use `process.env` instead | CRITICAL |
| **Dependency vulnerabilities** | `package.json`/lockfile modified in this spec, or a new dependency added - flag for `npm audit` and a check of the package's maintenance status/download count before trusting it | WARNING |
| **Postinstall script risk** | A newly added dependency with a `postinstall`/`preinstall` script - a common supply-chain attack vector, flag for review before trusting | INFO |
| **Insecure randomness** | `Math.random()` used to generate security tokens, session IDs, or CSRF values - use `node:crypto`'s `randomBytes`/`randomUUID` | CRITICAL |
| **Sensitive data in logs** | `console.log`/logger calls that emit tokens, passwords, or PII in code paths that run in production | WARNING |
| **Timing attack** | Token or secret comparison using `===` instead of `node:crypto`'s `timingSafeEqual` | WARNING |
