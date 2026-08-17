# Security — Swift

## Overview

Swift-specific security checks run during spec close security analysis.
Extends the generic checks in `security-network.md` and `security-surface.md`.
Covers both app-level (Keychain, network) and language-level (force-unwrap
as a crash/DoS vector) concerns. See `CLAUDE.md → Security Analysis` for how
this file is used.

Add new checks as they are discovered during project work.

---

## Network

| Category | What to look for | Severity |
|---|---|---|
| **TLS verification disabled** | A custom `URLSessionDelegate` that accepts any server certificate (`didReceive challenge` calling the completion handler with `.useCredential` unconditionally) | CRITICAL |
| **SSRF** | `URLSession`/`URLRequest` calls where the URL is partially or fully user-controlled without an allowlist | CRITICAL |
| **Unvalidated deserialization** | `NSKeyedUnarchiver` used without `requiringSecureCoding = true`, or `JSONDecoder` output used without validating business invariants afterward | WARNING |
| **App Transport Security exceptions** | `NSAllowsArbitraryLoads` or per-domain ATS exceptions in `Info.plist` broader than a specific, justified domain | WARNING |
| **Sensitive data in URL** | Tokens or credentials passed as URL query parameters instead of headers or a request body - visible in logs, browser history, and server logs | WARNING |

---

## Data Storage and Runtime

| Category | What to look for | Severity |
|---|---|---|
| **Secrets in source** | Hardcoded API keys, passwords, or tokens in any `.swift` file or `Info.plist` - including values labelled as examples | CRITICAL |
| **Sensitive data outside Keychain** | Passwords, tokens, or credentials stored in `UserDefaults`, plain files, or `NSCoding` archives instead of the Keychain | CRITICAL |
| **Force-unwrap on external input** | `!` used to unwrap a value derived from network responses, user input, or file contents - a crash on attacker-influenced input is a denial-of-service vector, not just a bug | WARNING |
| **Insecure randomness** | `arc4random()`'s raw form or `Int.random(in:)` used to generate security tokens or session IDs - use `SecRandomCopyBytes` or a CryptoKit-backed generator | CRITICAL |
| **Weak cryptography** | `CC_MD5`/`CC_SHA1` or ECB-mode encryption used for anything security-sensitive - use CryptoKit's modern primitives (`SHA256`, `AES.GCM`) | CRITICAL |
| **Biometric/passcode bypass** | `LAContext` evaluation results not checked before granting access to protected content | CRITICAL |
| **Sensitive data in logs** | `print`/`os_log` calls that emit tokens, passwords, or PII in code paths that ship to production | WARNING |
| **Dependency vulnerabilities** | `Package.swift`/`Podfile.lock` modified in this spec - flag for a CVE review of updated dependencies | INFO |
