# Task: {nnn}-{short-task-name}

> **Type:** <!-- Implementation | Bug Fix | Research | Investigation | Migration | Refactor | Config | Analysis -->
> **Author:** <!-- Name -->
> **Last Updated:** <!-- YYYY-MM-DD -->

> **If this is a one-off task** (no parent spec): the task file must be
> self-contained. Include all background, relevant file references, and
> acceptance criteria here — there is no `spec.md` to fill the gaps.
>
> **If this is a spec task**: the task file covers only the current step.
> Background and requirements live in `spec.md` — do not duplicate them here.

---

## Goal

One sentence. What does this task accomplish within the context of the spec?

> This task file is the full scope — do not infer or implement beyond what is
> written here. If anything is ambiguous, stop and ask.

**Example:**
> Create the API endpoint at `src/api/orders/index.aspx` that validates the access
> token and returns the order summary as JSON.

---

## Deliverables

What this task must produce. Be explicit — list every file to create or modify.

**Example:**
```
- Create:  `src/api/orders/index.aspx`
- Modify:  `src/api/orders/helpers/token_validator.aspx`
```

---

## Steps

Ordered implementation steps. Use this section when sequence matters or when
the task is complex enough that a wrong order would cause problems.

> Skip this section for straightforward tasks where the deliverables are
> self-explanatory.

**Example:**
```
1. Read the token table schema in `migrations/0005_api_tokens.sql`
2. Implement token validation logic
3. Implement the JSON response using the schema in the spec
4. Implement error responses for all failure cases
5. Verify the file structure matches the standard in `coldfusion.md`
```

---

## Constraints

Rules specific to this task that are not already covered by the spec or standards.

> Only include constraints that would not be obvious from reading the spec.
> Do not restate spec requirements here.

**Example:**
```
- Do not create new database tables — use `api_tokens` only
- Do not introduce any new ColdFusion includes not already in the codebase
- Response time must stay under 300ms — avoid N+1 queries
```

---

## Notes

Anything that does not fit above — decisions made during implementation,
references consulted, or things to remember if this task is revisited.

> If a decision surfaces that affects the broader architecture, stop and flag
> it for an ADR — do not resolve it here unilaterally.

---

## Optional Sections

> Include these only when the information is **not already in the spec**.
> If the spec covers it, Claude will read it there — do not duplicate it here.

### Context

Additional files to read before starting — structural examples, related
implementations, or references not mentioned in the spec.

```
- **Similar implementation:** `src/api/invoices/index.aspx`
  — Use as a structural reference for the new API file.
```

### Inputs

Files, parameters, or data this task depends on that are not defined in the spec.

```
- `migrations/0005_api_tokens.sql` — existing token table schema
```

### Acceptance Criteria

Task-level checks not already covered by the spec's acceptance criteria.

```
- [ ] File passes ColdFusion syntax check with no errors
```

### Test Coverage

Which `test-cases/NNN-*.md` file(s) this task creates or extends, and what new
row(s) to add to `test-cases/overview.md`'s execution table. Include only when
this task adds or changes verifiable behavior - omit for pure refactors, doc
updates, etc.

```
- **New:** `test-cases/003-token-refresh.md` - add row `003 | 003-token-refresh.md | req 12 | HTTP | Not run`
```

---
---

# Section Reference

> **This section is for authoring only. Remove it before Claude works this
> task — it adds no task-relevant context and consumes token budget.**

The tables below list additional sections for specific task types.
Add only what is relevant — do not include empty sections.

---

## Research & Analysis

Used for standalone read-only investigation — understanding how something works,
tracing a query, mapping a data flow. Produces a findings report for the human.
No code is changed. No branch is created.

| Section | Purpose |
|---|---|
| Research Questions | The exact questions this task must answer — specific enough that a code path or a yes/no is a complete answer |
| Sources | Files, directories, or git history ranges to read; start narrow, expand if needed |
| Output Format | How findings are structured — annotated query, code path trace, decision table, or prose summary |
| Output Location | `.claude/tasks/<task-name>/memory.md` for standalone; `.claude/specs/<spec_name>/memory.md` if spec-scoped. Promote to `.claude/knowledge/<domain>.md` if the finding is reusable across specs |
| Constraints | Read-only — do not modify any source file; do not create a branch; commit only the report |

**Example:**

```
Task type: Research

Research Questions:
- What query retrieves the overdue invoices shown on the dashboard?
- What filters are applied — user scope, date range, status — and where:
  in SQL or in ColdFusion after the query returns?

Sources:
- src/dashboard/index.aspx
- Any cfinclude files it references

Output Format:
1. The full query, annotated line by line
2. Plain-English summary of each filter condition and where it is enforced
3. Any edge cases found — nulls, fallback values, scope leakage

Output Location: .claude/tasks/trace-overdue-invoices/memory.md

Constraints: Read-only. No source file changes. No branch.
```

---

## Investigation / Triage

Used mid-spec when a manual test produces an unexpected result and the cause is
unknown. Produces a verdict report for the human. No code is changed until the
human authorizes the next step.

Claude is never authorized to create a fix or amendment branch as a direct
result of this task — the human reads the verdict and decides.

| Section | Purpose |
|---|---|
| Symptom | What was observed — exact input used, expected output, actual output |
| Hypotheses | Candidate causes to evaluate — always include: result is correct, test assumption is wrong, implementation has a bug |
| Inspection Scope | Files, queries, or data paths to read |
| Verdict | Filled in by Claude — which hypothesis is confirmed, or that root cause remains unclear |
| Evidence | The specific lines, query results, or logic paths that support the verdict |
| Recommended Next Step | What the human should authorize next — see table below |

| Verdict | Recommended Next Step |
|---|---|
| Result is correct, test assumption was wrong | Human adjusts test case — no branch needed |
| Spec requirement was ambiguous or wrong | Human authorizes `amend/<spec_name>/<short-description>` |
| Implementation has a bug | Human authorizes `fix/<spec_name>/<short-description>` |
| Root cause unclear after inspection | Claude lists what was ruled out and what still needs checking — human decides next inspection scope |

**Example:**

```
Task type: Investigation

Symptom:
- Input: invoice ID 10042, user session uid=5
- Expected: invoice appears in the overdue list
- Actual: invoice is absent from the list with no error shown

Hypotheses:
1. The invoice does not meet the overdue criteria — result is correct
2. The test assumption about the overdue threshold is wrong
3. A filter in the query or post-query ColdFusion logic is incorrectly excluding it

Inspection Scope:
- src/dashboard/index.aspx — query and post-query filter logic
- The invoices table record for ID 10042 — status, due date, user ID
- spec.md req #4 — the definition of overdue for this spec

Verdict: (filled in by Claude after inspection)

Evidence: (filled in by Claude — specific lines, values, logic paths)

Recommended Next Step: (filled in by Claude)
```

---

## Bug Fix

| Section | Purpose |
|---|---|
| Bug Description | What is wrong and how it was observed |
| Reproduction Steps | Exact steps to trigger the bug |
| Expected Behavior | What should happen |
| Actual Behavior | What is currently happening |
| Suspected Cause | Known or suspected root cause |
| Regression Risk | Areas that might be affected by the fix |

---

## Migration

| Section | Purpose |
|---|---|
| Migration Type | Schema change, data backfill, file move, config update, etc. |
| Pre-Migration State | What exists before the migration runs |
| Post-Migration State | What must exist after the migration completes |
| Rollback Plan | How to undo this migration if something goes wrong |
| Data Risk | Records that could be affected or lost |
| Run Order | Whether this migration depends on another running first |

---

## Refactor

| Section | Purpose |
|---|---|
| Behaviour Contract | What must remain unchanged after the refactor |
| Files in Scope | Explicit list of files that may be changed |
| Files Out of Scope | Files that must not be touched |
| Verification | How to confirm behaviour is preserved |

---

## Configuration

| Section | Purpose |
|---|---|
| Config Target | The file, service, or environment being configured |
| Current State | What the config looks like before this task |
| Desired State | What the config must look like after this task |
| Secrets Handling | Where secrets live — never hardcode credentials |
| Environment | Which environment(s) this applies to (dev, staging, prod) |

---

## Document / Data Extraction

| Section | Purpose |
|---|---|
| Source Documents | Files to read and extract from |
| Extraction Rules | What to extract and how to identify it |
| Output Schema | Structure of the extracted output (table, JSON, etc.) |
| Ambiguity Handling | What to do when a field is unclear or missing |