# SECURITY-ANALYSIS.md — Security Analysis Procedure

Read this file when running the security analysis at spec close.
See `CLAUDE.md → Closing a Spec` for when this is triggered.

---

## Overview

Claude reviews all files delivered by the spec and produces a structured report
saved to:

```
.claude/docs/security-reports/security-<spec_name>-<YYYY-MM-DD>.md
```

Create `.claude/docs/security-reports/` if it does not exist. Add an entry to
`.claude/docs/security-reports/README.md` (create it if missing) following
the Linked Index Rule in `DOCUMENTATION.md`. Ensure
`.claude/docs/README.md` has exactly one entry for `security-reports/`,
linking to `security-reports/README.md` (create the top-level README too if
it does not exist).

---

## What to Review

Before starting the analysis, read the following files from `.claude/standards/`:

1. `security-network.md` — generic network and API checks
2. `security-surface.md` — generic memory, runtime, and data exposure checks
3. Every file matching `*-security.md` that exists in `.claude/standards/` — these are
   stack-specific checks (e.g. `coldfusion-security.md`, `javascript-security.md`)

If a file does not exist, skip it silently — do not invent checks that have not been
defined for this project. Do not look for a `## Security` section in other standards
files — all security checks live in the security files above.

Inspect every file touched by the spec against the combined set of checks from all
files read. All findings map to the same report table regardless of which file the
check came from.

---

## Report Format

```markdown
# Security Analysis — <spec_name>
**Date:** YYYY-MM-DD
**Spec:** .claude/specs/<spec_name>/spec.md
**Files Reviewed:** <list of files touched by the spec>

---

## Findings

| # | Severity | Category | File | Line(s) | Description |
|---|----------|----------|------|---------|-------------|
| 1 | CRITICAL  | SQL Injection | src/api/index.aspx | 42 | … |
| 2 | WARNING   | Sensitive data in error response | src/api/index.aspx | 87 | … |
| 3 | INFO      | Missing security header | src/api/index.aspx | — | … |

---

## Finding Detail

### 1 — CRITICAL: SQL Injection

**File:** `src/api/index.aspx`, line 42
**Description:** User input interpolated directly into a query string without
parameterisation. An attacker can manipulate the query to read or modify any table.
**Remediation:** Use parameterised queries or prepared statements.

…

---

## Accepted Findings

Findings the human has explicitly accepted. Each entry records the original finding
number, the rationale, and the date accepted.

| # | Original Finding | Accepted By | Date | Rationale |
|---|-----------------|-------------|------|-----------|
```

---

## Severity Levels

| Level | Meaning |
|---|---|
| `CRITICAL` | Directly exploitable — must be resolved or explicitly accepted before the spec is closed |
| `WARNING` | Increases attack surface or violates a defence-in-depth principle — should be resolved or explicitly accepted |
| `INFO` | Hardening opportunity — low urgency, acceptable to defer |

---

## Human Sign-Off

After producing the report, present a summary:

> *"Security analysis complete for `<spec_name>`. Found: X CRITICAL, Y WARNING, Z INFO.
> Report saved to `.claude/docs/security-reports/security-<spec_name>-<YYYY-MM-DD>.md`.
> CRITICAL and WARNING findings must be resolved or explicitly accepted before this spec is closed."*

Do not mark the spec as closed until the human responds with one of:

- **"Resolved"** — findings were fixed; Claude re-reviews affected files and updates the report
- **"Accepted"** — human acknowledges a finding and provides a written rationale; Claude appends it to the `## Accepted Findings` table in the report
- **"Create tasks"** — Claude generates task files in `.claude/specs/<spec_name>/tasks/` for each open finding; spec close is deferred until those tasks are complete
