# Standards

This document lists all standards files available in this project.
It is the reference Claude uses to locate the standards. If no standard exists for a given
situation, follow industry best practices.

> Before reading any file listed here, verify it exists on disk.
> If a file is missing, skip it silently — its absence means that language or
> technology is not present in this project. Do not report missing files.

---

## Standards Files

| File | Purpose |
|------|---------|
| `./standards/git.md` | Git commit and branch conventions |
| `./standards/csharp.md` | C# language  |
| `./standards/javascript.md` | Vanilla JavaScript |
| `./standards/typescript.md` | Typescript language |
| `./standards/vue3.md` | Defines the standards for Vue3 framework |
| `./standards/sql.md` | SQL queries, DDL, and migrations |
| `./standards/coldfusion.md` | ColdFusion language |
| `./standards/bash.md` | Bash scripts |
| `./standards/yaml.md` | YAML files |
| `./standards/docker-compose.md` | Docker Compose files — depends on `yaml.md` |
| `./standards/go.md` | Go language |
| `./standards/security-network.md` | Network and API attack surface (used at spec close) |
| `./standards/security-surface.md` | Memory, runtime, and data exposure (used at spec close) |
| `./standards/coldfusion-security.md` | ColdFusion-specific security checks (used at spec close) |
| `./standards/javascript-security.md` | JavaScript-specific security checks (used at spec close) |
| `./standards/sql-security.md` | SQL-specific security checks (used at spec close) |
| `./standards/go-security.md` | Go-specific security checks (used at spec close) |
| `./standards/powershell.md` | PowerShell scripts |
| `./standards/powershell-security.md` | PowerShell-specific security checks (used at spec close) |
| `./standards/changelog.md` | CHANGELOG.md writing conventions (Keep a Changelog) |
| `./standards/python.md` | Python language |
| `./standards/python-security.md` | Python-specific security checks (used at spec close) |
| `./standards/lua.md` | Lua language |
| `./standards/c.md` | C language (C17 baseline) |
| `./standards/c-security.md` | C-specific security checks, CERT C Secure Coding framework (used at spec close) |
| `./standards/rust.md` | Rust language (defers to rustfmt for formatting, Rust API Guidelines for API design) |
| `./standards/rust-security.md` | Rust-specific security checks, focused on unsafe/FFI (used at spec close) |
| `./standards/java.md` | Java language (Google Java Style Guide baseline) |
| `./standards/java-security.md` | Java-specific security checks (used at spec close) |
| `./standards/cpp.md` | C++ language (Google C++ Style Guide baseline) |
| `./standards/cpp-security.md` | C++-specific security checks (used at spec close) |
| `./standards/html.md` | HTML markup (semantic HTML5, WCAG 2.1/2.2 AA, Google HTML Style Guide) |
| `./standards/xml.md` | XML documents (Google XML Document Format Style Guide) |
| `./standards/css.md` | Vanilla CSS (ITCSS architecture, BEM naming) |
| `./standards/php.md` | PHP language (PSR-12 formatting, PSR-4 autoloading) |
| `./standards/php-security.md` | PHP-specific security checks (used at spec close) |
| `./standards/vb.md` | Visual Basic language (VB.NET primary baseline, VB6 legacy compatibility) |
| `./standards/vb-security.md` | Visual Basic-specific security checks, VB.NET and VB6 (used at spec close) |
| `./standards/ruby.md` | Ruby language (The Ruby Style Guide) |
| `./standards/ruby-security.md` | Ruby-specific security checks (used at spec close) |
| `./standards/swift.md` | Swift language (Swift API Design Guidelines, Google Swift Style Guide) |
| `./standards/swift-security.md` | Swift-specific security checks (used at spec close) |
| `./standards/angular.md` | Angular framework (official Angular Style Guide, current conventions) |
| `./standards/node.md` | Node.js runtime (Airbnb JS baseline via javascript.md, plus Node-specific module/stream/event-loop conventions) |
| `./standards/node-security.md` | Node.js-specific security checks - supply chain, prototype pollution, event-loop DoS (used at spec close) |

New `*-security.md` files are added as new stacks are introduced. Claude reads every
`*-security.md` file that exists during spec close — adding or removing a file is all
that is needed to include or exclude a stack's checks.