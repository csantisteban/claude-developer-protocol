# Security — Network Attack Surface

## Overview

Checks for network-facing vulnerabilities run during spec close security analysis.
See `CLAUDE.md → Security Analysis` for how this file is used.

Stack-specific checks live in the named language files (e.g. `coldfusion-security.md`, `javascript-security.md`).

---

## Checks

| Category | What to look for | Default Severity |
|---|---|---|
| **Injection** | User-controlled input concatenated into queries, shell commands, or eval calls without parameterisation or escaping | CRITICAL |
| **Cross-Site Scripting (XSS)** | Unescaped user input rendered into an HTML response | CRITICAL |
| **Cross-Site Request Forgery (CSRF)** | State-changing endpoints (POST, PUT, PATCH, DELETE) that do not validate a CSRF token or `Origin` / `Referer` header | WARNING |
| **Insecure Direct Object Reference (IDOR)** | URLs or parameters that accept a raw record ID without verifying the authenticated user owns that record | CRITICAL |
| **Authentication bypass** | Endpoints reachable without a valid session, or that rely on client-side flags or URL obscurity instead of server-side checks | CRITICAL |
| **Token and session handling** | Tokens stored in `localStorage`, returned in query strings, not expiring, or not invalidated after logout or single use | WARNING |
| **HTTP method enforcement** | Endpoints that accept `GET` for state-changing operations, or do not reject unexpected verbs with `405` | WARNING |
| **Security response headers** | Responses missing `Content-Security-Policy`, `X-Content-Type-Options`, `X-Frame-Options`, or `Strict-Transport-Security` | INFO |
| **Open redirect** | Redirect targets derived from user input without an allowlist | WARNING |
| **Path traversal** | File paths constructed from user input without normalisation and a strict prefix check | CRITICAL |
| **SSRF** | Outbound HTTP calls whose URL is partially or fully user-controlled | CRITICAL |
| **Verbose errors** | Error responses that leak stack traces, internal paths, SQL, or field names to the client | WARNING |
| **Insecure file upload** | File upload endpoints that do not validate type, size, or storage path | WARNING |
| **Mass assignment** | API endpoints that bind request bodies directly to data models without an explicit allowlist of accepted fields | WARNING |


