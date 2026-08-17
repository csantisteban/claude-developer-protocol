# Security — SQL

## Overview

SQL-specific security checks run during spec close security analysis.
Extends the generic checks in `security-network.md` and `security-surface.md`.
See `CLAUDE.md → Security Analysis` for how this file is used.

Applies to raw SQL files (queries, DDL, migrations, stored procedures).
For ORM or query-builder rules, create a companion file alongside this one.

Add new checks as they are discovered during project work.

---

## Network

| Category | What to look for | Severity |
|---|---|---|
| **SQL Injection** | Dynamic SQL constructed by concatenating application variables into a query string — always use parameterised queries or prepared statements; no user-controlled value may appear inline | CRITICAL |
| **Stored procedure injection** | Stored procedures that concatenate parameters into `EXEC` or `sp_executesql` calls — parameterise the inner statement, not just the outer call | CRITICAL |
| **Wildcard `SELECT *`** | `SELECT *` in views, stored procedures, or application queries — explicit column lists prevent unintended data exposure when schema changes | WARNING |
| **Overly permissive views** | Views that expose columns containing PII, credentials, or internal identifiers to roles that do not need them | WARNING |

---

## Memory and Runtime

| Category | What to look for | Severity |
|---|---|---|
| **Secrets in migration files** | Hardcoded passwords, API keys, or connection strings inserted as seed or default data in migration scripts | CRITICAL |
| **Plaintext credential storage** | Columns intended to store passwords, tokens, or secrets inserted as plain text — flag any `INSERT` or `UPDATE` that writes a credential column without a hashing function | CRITICAL |
| **Unbounded queries** | Queries with no `WHERE`, `LIMIT`, or `MAXROWS` clause applied to large or user-scoped tables — risk of full-table scans and data over-exposure | WARNING |
| **Implicit type coercion** | Predicates comparing columns of different types without an explicit `CAST` — silent coercion can bypass index use and, in some engines, produce incorrect row matches | WARNING |
| **Insecure default values** | Column defaults set to empty string or `0` for fields that should require explicit values (e.g. `is_admin`, `role`, `status`) — prefer `NOT NULL` with no default to force the caller to be explicit | WARNING |
| **Sensitive data in comments** | SQL comments containing sample PII, credentials, or internal account details left in committed migration or query files | WARNING |

---

## Schema and Permissions

| Category | What to look for | Severity |
|---|---|---|
| **Excessive role privileges** | `GRANT` statements that assign `ALL PRIVILEGES` or write permissions to roles that only need read access — follow least privilege | WARNING |
| **Public schema grants** | `GRANT ... TO PUBLIC` or equivalent — no privilege should be granted to the public role without explicit justification | CRITICAL |
| **Missing foreign key constraints** | Relationships between tables enforced only at the application layer, not at the database layer — orphaned rows can produce logic bypasses | INFO |
| **Missing `NOT NULL` constraints** | Columns that must always have a value left nullable — null coalescing in application logic can mask missing data and produce incorrect access decisions | INFO |
| **DDL in application query paths** | `DROP`, `TRUNCATE`, `ALTER`, or `CREATE` statements appearing in files that are executed at request time rather than in controlled migrations | CRITICAL |
