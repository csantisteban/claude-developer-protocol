# Security — C#

## Overview

C#-specific security checks run during spec close security analysis.
Extends the generic checks in `security-network.md` and `security-surface.md`.
See `CLAUDE.md → Security Analysis` for how this file is used.

Applies to C# and ASP.NET Web API on .NET Framework 4.6.2. For Razor view
rendering, also apply the XSS checks below to `.cshtml` files.

Add new checks as they are discovered during project work.

---

## Network

| Category | What to look for | Severity |
|---|---|---|
| **SQL injection** | Raw SQL strings built by concatenating variables or user input — with PetaPoco all parameters must use the `@0, @1` placeholder syntax, never string interpolation or `+` concatenation | CRITICAL |
| **XSS via unencoded output** | Controller actions or Razor views writing user-controlled strings directly to the response without `HttpUtility.HtmlEncode()` or the Razor `@` encoder — check `Content()`, `Json()`, and any `HttpResponseMessage` with a string body | CRITICAL |
| **Missing `[Authorize]`** | API controller actions or controllers that mutate or expose user data but have no `[Authorize]` attribute and no equivalent filter registered globally | CRITICAL |
| **CSRF** | State-changing API endpoints (POST, PUT, PATCH, DELETE) that do not validate an anti-forgery token or check the `Origin` / `Referer` header | WARNING |
| **Mass assignment** | Model binding that accepts a full object from the request body without an explicit allowlist of bindable properties — use a dedicated DTO or `[Bind(Include = "...")]` | WARNING |
| **Open redirect** | `Redirect()` or `RedirectPermanent()` targets derived from query string or form values without validating against an allowlist of known safe URLs | WARNING |
| **Path traversal** | `File.ReadAllText`, `File.WriteAllText`, `Path.Combine`, or `Directory` calls whose path components include user-supplied values without normalisation and a strict prefix check | CRITICAL |
| **XXE in XML parsing** | `XmlDocument`, `XmlReader`, or `XDocument` loading user-supplied XML without explicitly disabling external entity resolution — set `XmlResolver = null` and `DtdProcessing = DtdProcessing.Prohibit` | CRITICAL |
| **Overly permissive CORS** | `Access-Control-Allow-Origin: *` on endpoints that return user-specific data, or CORS policy that mirrors the request `Origin` header without an explicit allowlist | WARNING |
| **Verbose error responses** | `Exception.Message`, `Exception.StackTrace`, or inner exception details written into an API response body or JSON error envelope — return a generic message to the caller and log the detail server-side | WARNING |

---

## Memory and Runtime

| Category | What to look for | Severity |
|---|---|---|
| **Insecure deserialization** | `BinaryFormatter`, `NetDataContractSerializer`, or `JsonConvert.DeserializeObject` with `TypeNameHandling` set to anything other than `None` applied to user-controlled input — these allow arbitrary type instantiation | CRITICAL |
| **Secrets in source** | Connection strings, API keys, passwords, or tokens hardcoded in `.cs` files, `Web.config`, or `App.config` committed to source control — use environment-specific config transforms or a secrets store | CRITICAL |
| **Sensitive data in logs** | `Envest.Logging` calls (or any logger) that write passwords, tokens, full request bodies, or PII — log only the fields needed to diagnose the problem | WARNING |
| **Insecure randomness** | `System.Random` used to generate security tokens, nonces, session identifiers, or anything security-sensitive — use `System.Security.Cryptography.RNGCryptoServiceProvider` instead | WARNING |
| **Plaintext credential storage** | Passwords inserted or updated in the database as plain text — must be stored as a salted hash (bcrypt or PBKDF2) | CRITICAL |
| **Unvalidated input passed to services** | Controller actions forwarding raw request values to service or database calls without first validating type, length, and format at the controller boundary | WARNING |
| **ReDoS** | `Regex` instances applied to user-controlled strings using patterns with nested quantifiers or alternation — test with a long adversarial input or use a timeout via `Regex(pattern, options, matchTimeout)` | INFO |
| **Timing attack on secrets** | Token or password comparison using `==` or `string.Equals` — use a constant-time comparison to prevent timing oracle attacks | INFO |
| **Dependency vulnerabilities** | `.csproj` or `packages.config` modified in this spec — flag for a NuGet vulnerability audit | INFO |
