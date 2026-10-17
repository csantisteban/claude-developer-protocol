# Security — Java

## Overview

Java-specific security checks run during spec close security analysis.
Extends the generic checks in `security-network.md` and `security-surface.md`.
See `CLAUDE.md → Security Analysis` for how this file is used.

Add new checks as they are discovered during project work.

---

## Network

| Category | What to look for | Severity |
|---|---|---|
| **SQL injection** | User input concatenated into a query string instead of using `PreparedStatement` with bound parameters, or JPA/Hibernate queries built with string concatenation instead of named parameters | CRITICAL |
| **Command injection** | `Runtime.exec()` or `ProcessBuilder` called with unsanitised user input as part of the command or arguments | CRITICAL |
| **XXE (XML External Entity)** | `DocumentBuilderFactory`, `SAXParserFactory`, or `XMLInputFactory` used without disabling external entity resolution (`setFeature` for `FEATURE_SECURE_PROCESSING`, disallowing DOCTYPE) | CRITICAL |
| **Path traversal** | File paths built from user input using `new File(base, userInput)` without verifying the resolved canonical path stays under `base` | CRITICAL |
| **SSRF** | `HttpClient`/`RestTemplate`/`URLConnection` calls where the URL is partially or fully user-controlled without an allowlist | CRITICAL |
| **Unvalidated deserialization** | `ObjectInputStream.readObject()` used on data from an untrusted source - Java native deserialization of untrusted input is a well-known RCE vector | CRITICAL |
| **CORS misconfiguration** | `Access-Control-Allow-Origin: *` set on endpoints carrying session cookies or sensitive data | WARNING |
| **TLS verification disabled** | A custom `TrustManager` that accepts all certificates, or `HostnameVerifier` returning `true` unconditionally | CRITICAL |

---

## Memory and Runtime

| Category | What to look for | Severity |
|---|---|---|
| **Secrets in source** | Hardcoded passwords, API keys, connection strings, or tokens in any `.java` file or committed config - including values labelled as examples | CRITICAL |
| **Sensitive data in logs** | `System.out`/`logger` calls that print tokens, passwords, PII, or full request/response bodies in production code paths | WARNING |
| **Insecure randomness** | `java.util.Random` used to generate security tokens, nonces, session IDs, or CSRF values - use `java.security.SecureRandom` exclusively | CRITICAL |
| **Weak cryptography** | `DES`, `MD5`, or `SHA1` used for anything security-sensitive (password hashing, signatures) - use a modern algorithm (`bcrypt`/`Argon2` for passwords, `SHA-256`+ for integrity) | CRITICAL |
| **Plaintext password storage** | Passwords stored as plain text or a fast general-purpose hash instead of a dedicated password-hashing algorithm (`BCrypt`, `Argon2`, `PBKDF2`) | CRITICAL |
| **Reflection on untrusted input** | `Class.forName()` or reflective instantiation driven by user-controlled class names | WARNING |
| **Dependency vulnerabilities** | `pom.xml`/`build.gradle` modified in this spec - flag for an OWASP Dependency-Check or equivalent CVE review | INFO |
| **Timing attack** | Token or secret comparison using `String.equals()`/`Arrays.equals()` instead of `MessageDigest.isEqual()` | WARNING |
