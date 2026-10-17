# Security - ColdFusion

## Overview

ColdFusion-specific security checks run during spec close security analysis.
Extends the generic checks in `security-network.md` and `security-surface.md`.
See `CLAUDE.md -> Security Analysis` for how this file is used.

Applies to CFML on Adobe ColdFusion and Lucee, in both tag syntax and
cfscript. Where the safe function differs between engines or versions, the
check names the general approach and an example.

The baseline is the OWASP Top 10 and the security guidance published for
Adobe ColdFusion and Lucee.

Add new checks as they are discovered during project work.

---

## Network and Web

| Category | What to look for | Severity |
|---|---|---|
| **SQL injection** | `url`, `form`, `cgi`, `cookie`, or any other variable interpolated into `<cfquery>` or `queryExecute()` SQL - use `<cfqueryparam>` with the correct `cfsqltype`, or `queryExecute()` with a params struct or array. Values that cannot be parameterised (`ORDER BY` columns, table names) must come from an allowlist | CRITICAL |
| **XSS** | `<cfoutput>` or `writeOutput()` rendering request or database values without the encoder for the output context: `encodeForHTML()`, `encodeForHTMLAttribute()`, `encodeForJavaScript()`, `encodeForURL()`, `encodeForCSS()`. `this.scriptProtect` is a partial filter, not a substitute | CRITICAL |
| **Unprotected remote methods** | CFC functions with `access="remote"` that read or change data without an authentication and authorization check inside the function - they can be called directly by URL (`?method=`) | CRITICAL |
| **Code injection** | User input reaching `Evaluate()`, `IIf()`, `DE()`, `PrecisionEvaluate()`, dynamic variable names (`setVariable()`, `<cfset "#name#" = ...>`), or `<cfinclude>`/`<cfmodule>` template paths | CRITICAL |
| **Command injection** | `<cfexecute>` or `cfexecute()` with user input in `name` or `arguments` - validate against an allowlist | CRITICAL |
| **Insecure file upload** | `<cffile action="upload">` or `fileUpload()` without an `accept` list and `strict="true"` (or the engine's allowed-extensions setting), saving inside the web root, or keeping the client file name - an uploaded `.cfm` file in the web root can be executed | CRITICAL |
| **Path traversal** | `<cffile>`, `fileRead()`, `fileWrite()`, `<cfdirectory>`, `<cfinclude>`, or `expandPath()` with user-controlled path parts, without `getCanonicalPath()` and a prefix check against the expected root | CRITICAL |
| **SSRF** | `<cfhttp>` or `cfhttp()` whose URL is partly or fully user-controlled, without validating scheme and host against an allowlist | CRITICAL |
| **XXE** | `xmlParse()` or `xmlSearch()` on untrusted XML without disabling DTDs and external entities (e.g. `this.xmlFeatures` in `Application.cfc`, or the parse options the engine provides) | CRITICAL |
| **CSRF** | State-changing forms or endpoints without a token checked server-side - `CSRFGenerateToken()` / `CSRFVerifyToken()` or an equivalent | WARNING |
| **HTTP method enforcement** | Pages or remote methods that change data without checking `cgi.request_method` (or the method restriction of the framework in use) and rejecting non-POST requests | WARNING |
| **Open redirect** | `<cflocation>` or `location()` targets derived from `url` or `form` values without an allowlist | WARNING |
| **Verbose errors** | `<cfcatch>` blocks writing `cfcatch.detail`, `cfcatch.tagContext`, `cfcatch.stackTrace`, or `cfcatch.sql` to the response, `<cfdump>`/`writeDump()` of errors or scopes reachable in production, or a site-wide error handler that shows engine error pages - these expose file paths, line numbers, and SQL | WARNING |

---

## Session and Authentication

| Category | What to look for | Severity |
|---|---|---|
| **Weak password storage** | Passwords stored as plain text, encrypted reversibly with `encrypt()`, or hashed with `hash()` (MD5 or SHA, salted or not) - use a password-hashing function such as `generatePBKDFKey()`, or the bcrypt/Argon2 functions where the engine provides them | CRITICAL |
| **Insecure session cookies** | `this.sessionCookie` without `httpOnly`, `secure`, and an explicit `sameSite`, or session tokens (`CFID`/`CFTOKEN`, `jsessionid`) placed in URLs via `addToken="true"` or `URLSessionFormat()` | WARNING |
| **Session fixation** | No `sessionRotate()` (or an equivalent new session) after login or another privilege change | WARNING |
| **Timing attack** | Tokens or secrets compared with `==`, `EQ`, or `compare()` - use a constant-time comparison, e.g. Java's `MessageDigest.isEqual()` | WARNING |

---

## Memory and Runtime

| Category | What to look for | Severity |
|---|---|---|
| **Scope leakage** | Function-local values left unscoped or written to `variables` inside a CFC that is cached in `application` or `session` scope - they bleed across concurrent requests. Declare them with `var` or use `local.` | WARNING |
| **Insecure deserialization** | `objectLoad()`, `<cfwddx action="wddx2cfml">`, or Java deserialization applied to data from an untrusted source | CRITICAL |
| **Insecure randomness** | `rand()` or `randRange()` with the default algorithm used for tokens, session IDs, or reset codes - pass `"SHA1PRNG"` as the algorithm or use `generateSecretKey()`. `createUUID()` is unique, not unpredictable, and must not be used as a secret | CRITICAL |
| **Sensitive data in logs** | `<cflog>`, `writeLog()`, or `<cfdump>` to a file that writes whole `form`, `url`, `session`, or `cgi` scopes, passwords, or tokens - log only the fields needed | WARNING |
| **Secrets in source** | Datasource passwords, API keys, or SMTP credentials in `.cfm`/`.cfc` files or `Application.cfc` (`this.datasources`) - use datasources defined in the engine administrator, environment variables, or a secrets store | CRITICAL |
| **Debug and admin exposure** | Debug output, robust exception information, or RDS enabled in committed engine configuration (e.g. `.cfconfig.json`), or the administrator path reachable from the public site | INFO |
| **Dependency vulnerabilities** | `box.json` modified in this spec, or a new engine or extension version required - flag for a review of security bulletins for the engine and packages | INFO |
