# Security — Python

## Overview

Python-specific security checks run during spec close security analysis.
Extends the generic checks in `security-network.md` and `security-surface.md`.
See `CLAUDE.md → Security Analysis` for how this file is used.

Add new checks as they are discovered during project work.

---

## Network

| Category | What to look for | Severity |
|---|---|---|
| **SQL injection** | User input interpolated into query strings via f-strings, `%`, or `.format()` instead of parameterised queries (`cursor.execute(query, params)`) | CRITICAL |
| **Command injection** | `os.system`, `subprocess.run`/`Popen` called with `shell=True` and user-controlled input, or unsanitised input passed as an argument list | CRITICAL |
| **Path traversal** | File paths built from user input with `os.path.join` without verifying the resolved path stays under an expected root (`os.path.realpath` + prefix check) | CRITICAL |
| **SSRF** | `requests`/`urllib`/`httpx` calls where the URL is partially or fully derived from user input, without validating scheme and host against an allowlist | CRITICAL |
| **Unvalidated deserialization** | `pickle.loads`, `yaml.load` (without `Loader=yaml.SafeLoader`), or `eval`/`exec` applied to untrusted input | CRITICAL |
| **TLS verification disabled** | `requests` calls with `verify=False`, or `ssl` contexts with `CERT_NONE` - acceptable only in local development and must never reach a committed file | CRITICAL |
| **Open redirect** | Redirect targets (Flask `redirect()`, Django `HttpResponseRedirect`) built from query parameters without an allowlist | WARNING |
| **CORS misconfiguration** | `Access-Control-Allow-Origin: *` set on endpoints that carry session cookies or sensitive data | WARNING |

---

## Memory and Runtime

| Category | What to look for | Severity |
|---|---|---|
| **Secrets in source** | Hardcoded passwords, API keys, connection strings, or tokens in any `.py` file or committed config - including values labelled as examples | CRITICAL |
| **Sensitive data in logs** | `logging`/`print` calls that emit tokens, passwords, PII, or full request bodies in code paths that run in production | WARNING |
| **Insecure randomness** | `random` module used to generate security tokens, nonces, session IDs, or CSRF values - use `secrets` exclusively | CRITICAL |
| **Insecure hashing for passwords** | `hashlib.md5`/`sha1`/`sha256` used directly to hash passwords instead of a dedicated password-hashing function (`bcrypt`, `argon2`, `passlib`) | CRITICAL |
| **Unvalidated template rendering** | `jinja2` `Template` constructed from user input, or `render_template_string` called with untrusted content - enables server-side template injection | CRITICAL |
| **Unbounded resource use** | Reading an entire uploaded file or request body into memory (`request.data`, `f.read()`) without a size limit | WARNING |
| **Dependency vulnerabilities** | `requirements.txt`, `pyproject.toml`, or a lockfile modified in this spec - flag for a `pip-audit` review | INFO |
| **Timing attack** | Token or secret comparison using `==` instead of `secrets.compare_digest` | WARNING |
