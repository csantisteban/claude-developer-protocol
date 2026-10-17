# Security — Ruby

## Overview

Ruby-specific security checks run during spec close security analysis.
Extends the generic checks in `security-network.md` and `security-surface.md`.
Many of these checks apply directly to Rails-class web frameworks, but are
written generically since not every Ruby project uses Rails. See
`CLAUDE.md → Security Analysis` for how this file is used.

Add new checks as they are discovered during project work.

---

## Network

| Category | What to look for | Severity |
|---|---|---|
| **SQL injection** | User input interpolated into a query string via string interpolation instead of parameterised queries (ActiveRecord's `where(id: params[:id])`, not `where("id = #{params[:id]}")`) | CRITICAL |
| **Command injection** | `` `backticks` ``, `system`, `exec`, or `IO.popen` called with unsanitised user input | CRITICAL |
| **Unsafe deserialization** | `Marshal.load` or `YAML.load` (not `YAML.safe_load`) applied to untrusted input - both can instantiate arbitrary Ruby objects | CRITICAL |
| **`eval` on untrusted input** | `eval`, `instance_eval`, `class_eval`, or `send` with a method name derived from user input | CRITICAL |
| **Mass assignment** | ActiveRecord models updated via `update`/`new` with a raw, unfiltered `params` hash instead of Strong Parameters (`params.require(...).permit(...)`) | CRITICAL |
| **XSS** | User input rendered in a view without escaping - `raw`/`html_safe` called on unsanitised user content | CRITICAL |
| **Path traversal** | File paths built from user input without `File.expand_path` + a prefix check against an expected root | CRITICAL |
| **SSRF** | `Net::HTTP`/`open-uri`/`Faraday` calls where the URL is partially or fully user-controlled without an allowlist | CRITICAL |
| **CSRF protection disabled** | `protect_from_forgery`/`skip_before_action :verify_authenticity_token` disabling CSRF protection on a state-changing controller action | WARNING |

---

## Memory and Runtime

| Category | What to look for | Severity |
|---|---|---|
| **Secrets in source** | Hardcoded passwords, API keys, or credentials in any `.rb` file - including values labelled as examples; use `Rails.application.credentials` or environment variables instead | CRITICAL |
| **Plaintext password storage** | Passwords stored as plain text or a fast general-purpose hash instead of `has_secure_password`/bcrypt | CRITICAL |
| **Insecure randomness** | `Random.rand`/`Kernel#rand` used to generate security tokens, nonces, or session IDs - use `SecureRandom` | CRITICAL |
| **Sensitive data in logs** | `Rails.logger`/`puts` calls that emit tokens, passwords, or PII in code paths that run in production | WARNING |
| **Regular expression denial of service (ReDoS)** | A regex with nested quantifiers (`(a+)+`) applied to user-controlled input - can cause catastrophic backtracking | WARNING |
| **Dependency vulnerabilities** | `Gemfile`/`Gemfile.lock` modified in this spec - flag for a `bundle audit` review | INFO |
| **Timing attack** | Token or password comparison using `==` instead of `ActiveSupport::SecurityUtils.secure_compare` | WARNING |
