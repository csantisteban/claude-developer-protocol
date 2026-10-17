# Security - C#

## Overview

C#-specific security checks run during spec close security analysis.
Extends the generic checks in `security-network.md` and `security-surface.md`.
See `CLAUDE.md -> Security Analysis` for how this file is used.

Applies to C# on modern .NET and .NET Framework - ASP.NET Core (controllers
and minimal APIs), ASP.NET MVC / Web API, Razor views, and Blazor. Where the
safe API differs between runtimes, the check names both. Apply the XSS
checks to `.cshtml` and `.razor` files as well as `.cs`.

The baseline is Microsoft's ASP.NET Core security documentation and the
OWASP .NET Security Cheat Sheet.

Add new checks as they are discovered during project work.

---

## Network and Web

| Category | What to look for | Severity |
|---|---|---|
| **SQL injection** | SQL built by concatenation or string interpolation and passed to ADO.NET (`SqlCommand.CommandText`), Dapper, or EF Core's `FromSqlRaw`/`ExecuteSqlRaw` - use bound parameters (`SqlParameter`, Dapper's parameter object, or EF Core's `FromSql`/`FromSqlInterpolated`, which parameterise interpolated values) | CRITICAL |
| **Command injection** | `Process.Start` or `ProcessStartInfo` with user input in `FileName` or `Arguments` - validate against an allowlist and pass arguments through `ArgumentList`; never combine user input with `UseShellExecute = true` | CRITICAL |
| **XSS** | User-controlled strings written without encoding: `Html.Raw`, `HtmlString`, Blazor `MarkupString`, or `Content(...)` returned as `text/html` - Razor's `@` output is encoded and safe | CRITICAL |
| **Missing authorization** | Controllers, actions, or minimal API endpoints that read or change user data with no `[Authorize]` / `RequireAuthorization()` and no global fallback policy, or with `[AllowAnonymous]` | CRITICAL |
| **Insecure direct object reference** | A record loaded by an ID from the route or query without checking that the current user may access it (an ownership check or resource-based authorization via `IAuthorizationService`) | CRITICAL |
| **CSRF** | Cookie-authenticated state-changing endpoints without antiforgery validation (`[ValidateAntiForgeryToken]`, `AutoValidateAntiforgeryToken`, or the antiforgery middleware for minimal APIs), or with `[IgnoreAntiforgeryToken]` | WARNING |
| **Over-posting** | Request bodies bound directly to persistence entities - bind to a dedicated input model (DTO) that exposes only the editable fields | WARNING |
| **Open redirect** | `Redirect()` targets taken from query or form values - use `LocalRedirect()` or check `Url.IsLocalUrl()` first | WARNING |
| **Path traversal** | File paths built from user input with `Path.Combine` (which returns the second argument unchanged when it is rooted) without `Path.GetFullPath` and a prefix check against the expected root, or uploads saved under the client-supplied `IFormFile.FileName` | CRITICAL |
| **SSRF** | `HttpClient` requests whose URL is partly or fully user-controlled, without validating scheme and host against an allowlist | CRITICAL |
| **XXE** | `XmlReaderSettings.DtdProcessing = DtdProcessing.Parse`, or a non-null `XmlResolver` on `XmlDocument`/`XmlTextReader` (the unsafe default on older .NET Framework) when parsing untrusted XML - use `DtdProcessing.Prohibit` and `XmlResolver = null` | CRITICAL |
| **Overly permissive CORS** | `AllowAnyOrigin()`, or `SetIsOriginAllowed(_ => true)` combined with `AllowCredentials()`, on endpoints that return user data | WARNING |
| **TLS validation disabled** | `ServerCertificateCustomValidationCallback` returning `true`, `HttpClientHandler.DangerousAcceptAnyServerCertificateValidator`, or `ServicePointManager.ServerCertificateValidationCallback` returning `true` outside an explicitly documented test context | CRITICAL |
| **Verbose errors** | `UseDeveloperExceptionPage()` reachable outside the Development environment, `customErrors mode="Off"` in `Web.config`, or `Exception.Message`/`StackTrace` returned in a response body - return a generic error (e.g. `ProblemDetails`) and log the detail | WARNING |
| **HTTPS not enforced** | Production pipeline without `UseHttpsRedirection()` and `UseHsts()` (or the hosting equivalent) | INFO |

---

## Authentication and Session

| Category | What to look for | Severity |
|---|---|---|
| **Weakened token validation** | `TokenValidationParameters` with `ValidateIssuer`, `ValidateAudience`, `ValidateLifetime`, or `ValidateIssuerSigningKey` set to `false`, or `RequireSignedTokens = false` | CRITICAL |
| **Insecure auth cookies** | Authentication or session cookies without `HttpOnly`, `SecurePolicy = CookieSecurePolicy.Always`, and an explicit `SameSite` mode | WARNING |
| **Weak password storage** | Passwords stored as plain text, or hashed with `MD5`/`SHA1`/`SHA256` directly - use ASP.NET Core Identity's `PasswordHasher<TUser>`, `Rfc2898DeriveBytes.Pbkdf2` with a high iteration count, or a bcrypt/Argon2 library | CRITICAL |
| **Timing attack** | Secrets, tokens, or MACs compared with `==`, `string.Equals`, or `SequenceEqual` - use `CryptographicOperations.FixedTimeEquals` | WARNING |

---

## Memory and Runtime

| Category | What to look for | Severity |
|---|---|---|
| **Insecure deserialization** | `BinaryFormatter`, `SoapFormatter`, `NetDataContractSerializer`, `LosFormatter`, or `ObjectStateFormatter` on any input, or Json.NET with `TypeNameHandling` other than `None` on untrusted input - these allow arbitrary type instantiation | CRITICAL |
| **Secrets in source** | Connection strings, API keys, passwords, or tokens in `.cs` files, `appsettings*.json`, `Web.config`/`App.config`, or `launchSettings.json` committed to source control - use user secrets in development and environment variables or a secrets store in production | CRITICAL |
| **Sensitive data in logs** | `ILogger` (or any logger) calls that write passwords, tokens, full request bodies, or PII, including whole objects captured by structured-logging destructuring - log only the fields needed to diagnose the problem | WARNING |
| **Insecure randomness** | `System.Random` or `Random.Shared` used for security tokens, nonces, session IDs, or reset codes - use `RandomNumberGenerator` (`GetBytes`, `GetInt32`) | CRITICAL |
| **Weak cryptography** | `MD5`, `SHA1`, `DES`, `TripleDES`, or `RC2` for anything security-sensitive, ECB mode, or hardcoded keys and IVs - use `AesGcm` and SHA-256 or stronger | CRITICAL |
| **ReDoS** | `Regex` applied to user-controlled input without a `matchTimeout`, using patterns with nested quantifiers or alternation - set a timeout, or use `RegexOptions.NonBacktracking` where available | WARNING |
| **Model validation bypassed** | Request values forwarded to services or the database without validation, or automatic `[ApiController]` model validation turned off (`SuppressModelStateInvalidFilter = true`) without an equivalent check | WARNING |
| **Unbounded request size** | `[DisableRequestSizeLimit]`, or a raised `RequestSizeLimit`/`MaxRequestBodySize`, on endpoints accepting uploads or bodies without a documented reason | WARNING |
| **Unsafe code** | `unsafe` blocks, `stackalloc`, `Marshal` copies, or P/Invoke calls whose sizes or offsets come from external input without bounds checks | WARNING |
| **Dependency vulnerabilities** | `.csproj`, `Directory.Packages.props`, `packages.config`, or `packages.lock.json` modified in this spec - flag for a `dotnet list package --vulnerable` review | INFO |
