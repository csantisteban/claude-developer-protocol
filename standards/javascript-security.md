# Security — JavaScript

## Overview

JavaScript-specific security checks run during spec close security analysis.
Extends the generic checks in `security-network.md` and `security-surface.md`.
See `CLAUDE.md → Security Analysis` for how this file is used.

Applies to vanilla JavaScript. For Vue 3 or Node-specific rules, create
`vue-security.md` or `node-security.md` alongside this file.

Add new checks as they are discovered during project work.

---

## Network

| Category | What to look for | Severity |
|---|---|---|
| **XSS via innerHTML / document.write** | User-controlled data assigned to `innerHTML`, `outerHTML`, `document.write`, or `insertAdjacentHTML` — use `textContent` or sanitise with DOMPurify | CRITICAL |
| **Prototype pollution** | User-supplied keys (e.g. from `JSON.parse`) merged into plain objects with `Object.assign({}, input)` or spread without stripping `__proto__`, `constructor`, or `prototype` | WARNING |
| **Open redirect** | `window.location` or `location.href` set from URL parameters or `postMessage` data without validating the target origin | WARNING |
| **postMessage origin check** | `window.addEventListener('message', ...)` handlers that do not validate `event.origin` before acting on the data | WARNING |
| **CSRF via fetch / XHR** | State-changing API calls that do not include a CSRF token or rely solely on cookies for authentication | WARNING |

---

## Memory and Runtime

| Category | What to look for | Severity |
|---|---|---|
| **Secrets in source** | API keys, tokens, or credentials hardcoded in `.js` files or committed `.env` files — even labelled as examples | CRITICAL |
| **Sensitive data in logs** | `console.log` or `console.error` calls that print tokens, passwords, full request bodies, or user PII in code paths that run in production | WARNING |
| **Insecure randomness** | `Math.random()` used to generate security tokens, nonces, or identifiers — use `crypto.getRandomValues()` or `crypto.randomUUID()` | WARNING |
| **ReDoS** | Regular expressions with nested quantifiers or alternation applied to user-controlled strings — test with a long adversarial input | INFO |
| **eval and equivalents** | `eval()`, `new Function()`, `setTimeout(string)`, or `setInterval(string)` called with user-controlled data | CRITICAL |
| **Dependency vulnerabilities** | `package.json` or `package-lock.json` modified in this spec — flag for an `npm audit` run | INFO |
