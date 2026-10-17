# Security — Go

## Overview

Go-specific security checks run during spec close security analysis.
Extends the generic checks in `security-network.md` and `security-surface.md`.
See `CLAUDE.md → Security Analysis` for how this file is used.

Add new checks as they are discovered during project work.

---

## Network

| Category | What to look for | Severity |
|---|---|---|
| **SQL injection** | User input interpolated into query strings via `fmt.Sprintf` or string concatenation instead of parameterised queries (`db.QueryContext` with `?` or `$N` placeholders) | CRITICAL |
| **Command injection** | User-controlled values passed to `exec.Command` or `exec.CommandContext` — validate against an allowlist and never pass raw strings as shell arguments | CRITICAL |
| **Path traversal** | File paths constructed from user input using `filepath.Join` without verifying the result starts with the expected prefix via `filepath.Clean` | CRITICAL |
| **SSRF** | Outbound HTTP calls where the URL is partially or fully derived from user input — validate scheme and host against an allowlist before dialing | CRITICAL |
| **Open redirect** | `http.Redirect` targets built from query parameters or form values without an allowlist | WARNING |
| **CORS misconfiguration** | `Access-Control-Allow-Origin: *` set on endpoints that carry session cookies or sensitive data, or origins reflected from the `Origin` request header without validation | WARNING |
| **TLS verification disabled** | `InsecureSkipVerify: true` in any `tls.Config` — acceptable only in local development and must never reach a committed file | CRITICAL |
| **HTTP method enforcement** | Handlers registered on `http.DefaultServeMux` or a router without an explicit method check — use method-specific helpers (`r.Method`, `chi.Get`, etc.) and return `405` for unexpected verbs | WARNING |

---

## Memory and Runtime

| Category | What to look for | Severity |
|---|---|---|
| **Secrets in source** | Hardcoded passwords, API keys, connection strings, or tokens in any `.go` file or committed config — including values labelled as examples | CRITICAL |
| **Sensitive data in logs** | `log.Printf`, `slog`, `zap`, or similar calls that print tokens, passwords, PII, or full request bodies in code paths that run in production | WARNING |
| **Insecure randomness** | `math/rand` used to generate security tokens, nonces, session IDs, or CSRF values — use `crypto/rand` exclusively | CRITICAL |
| **Goroutine leak** | Goroutines started without a defined exit path or without being bounded by a `context.Context` — causes unbounded memory growth under load | WARNING |
| **Unbounded request body** | `http.Request.Body` read without wrapping in `io.LimitReader` — enables memory exhaustion via oversized payloads | WARNING |
| **Nil pointer dereference in error paths** | Returning a non-nil interface wrapping a nil concrete pointer — callers check `err != nil` but the interface is non-nil; use a plain `error` return or an explicit nil check | WARNING |
| **Unvalidated deserialization** | `json.Unmarshal`, `xml.Unmarshal`, or `gob.Decode` applied to user-supplied data without schema or type validation after decoding | WARNING |
| **Race condition** | Shared mutable state accessed from multiple goroutines without synchronization (`sync.Mutex`, `sync.RWMutex`, atomic operations, or channels) | CRITICAL |
| **Dependency vulnerabilities** | `go.mod` or `go.sum` modified in this spec — flag for a `govulncheck ./...` run | INFO |
| **Timing attack** | Token or secret comparison using `==` or `bytes.Equal` — use `subtle.ConstantTimeCompare` from `crypto/subtle` | WARNING |
