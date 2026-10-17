# Security — Rust

## Overview

Rust-specific security checks run during spec close security analysis.
Extends the generic checks in `security-network.md` and `security-surface.md`.
Rust's memory-safety guarantees hold only for safe code - this file focuses
on the places those guarantees can be broken or bypassed. See
`CLAUDE.md → Security Analysis` for how this file is used.

Add new checks as they are discovered during project work.

---

## `unsafe` and FFI

| Category | What to look for | Severity |
|---|---|---|
| **`unsafe` without justification** | An `unsafe` block or function with no `// SAFETY:` comment explaining which invariant makes it sound | CRITICAL |
| **Unsound FFI boundary** | `extern "C"` functions receiving raw pointers or lengths from external callers without validating them before dereferencing | CRITICAL |
| **Unchecked transmute** | `std::mem::transmute` used between types of different size or incompatible layout, or on data from an untrusted source | CRITICAL |
| **Raw pointer arithmetic** | Manual pointer offset calculations in `unsafe` blocks without a bounds check against the allocation's known size | CRITICAL |
| **Unvalidated slice from raw parts** | `slice::from_raw_parts` called with a length not provably matching the actual allocation | CRITICAL |
| **`unsafe impl Send`/`Sync`** | Manually implementing `Send`/`Sync` for a type without verifying the type is actually safe to share/move across threads | WARNING |

---

## Network and Input

| Category | What to look for | Severity |
|---|---|---|
| **SQL injection** | User input interpolated into query strings via `format!` instead of parameterised queries (`sqlx`/`diesel` bind parameters) | CRITICAL |
| **Command injection** | `std::process::Command` built with unsanitised user input as an argument, or shelling out via a format string | CRITICAL |
| **Path traversal** | File paths built from user input without canonicalizing (`std::fs::canonicalize`) and verifying the result stays under an expected root | CRITICAL |
| **SSRF** | HTTP client calls (`reqwest`, `hyper`) where the URL is partially or fully user-controlled without an allowlist | CRITICAL |
| **Unvalidated deserialization** | `serde` deserializing untrusted input into a type with no post-deserialization validation of business invariants | WARNING |

---

## Runtime

| Category | What to look for | Severity |
|---|---|---|
| **Secrets in source** | Hardcoded passwords, API keys, or tokens in any `.rs` file - including values labelled as examples | CRITICAL |
| **Insecure randomness** | `rand::random()`/`thread_rng()` used to generate security tokens, nonces, or session IDs - use a CSPRNG intended for security purposes (e.g. `rand::rngs::OsRng` or a dedicated crypto crate) | CRITICAL |
| **Panics on untrusted input** | `unwrap()`/`expect()`/array indexing that can panic when fed attacker-controlled input on a network-facing path - a panic in an async task can take down the whole worker | WARNING |
| **Sensitive data in logs** | `log`/`tracing` calls that emit tokens, passwords, or PII in code paths that run in production | WARNING |
| **Dependency vulnerabilities** | `Cargo.toml`/`Cargo.lock` modified in this spec - flag for a `cargo audit` review | INFO |
| **Timing attack** | Secret comparison using `==` instead of a constant-time comparison (`subtle::ConstantTimeEq` or equivalent) | WARNING |
