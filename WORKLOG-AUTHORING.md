# WORKLOG-AUTHORING.md - Worklog Format and Procedures

Read this file when writing a worklog entry for the first time in a session,
executing a Quick Action, or archiving the root worklog.

---

## File Shape

Every `worklog.md`, at any scope, is a single append-only markdown table:

```markdown
# Worklog

| Date | Branch | Action | Outcome | Follow-up |
|------|--------|--------|---------|-----------|
| 2026-06-10 | dev/v1.2.7 | Fixed off-by-one in `src/api/foo.js:42` | Tests pass | None |
| 2026-06-10 | dev/v1.2.7 | `npm install lodash@4.17.21` | Added as dependency for date formatting | Update lockfile committed separately |
```

- `Action` describes what was done, embedding file paths, line numbers, or
  commands inline as needed - there is no separate "Files" column
- `Outcome` describes the result or effect of the action
- `Follow-up` is `None` if nothing is pending, otherwise a short description of
  what remains unresolved
- Rows are never edited or deleted - corrections are new rows
- `worklog.md` files are tracked in git and committed normally, like
  `memory.md` - they are not gitignored and are not ephemeral like `session.md`
  or `.last-hash`

---

## Scopes and Selection

See `CLAUDE.md` -> `## Worklog` -> `### Scopes` for the scope-selection table
(root / spec / one-off task) and how to choose between them.

The root `.claude/worklog.md` is created on first use - the first Quick Action
or the first cross-cutting log entry with no active spec or task - not
pre-scaffolded. Spec and one-off-task `worklog.md` files are created
proactively (spec authoring, and `STARTING-ONE-OFF-TASK.md`).

---

## Quick Action

A Quick Action is a small, bounded action - code or non-code - the developer
will apply or commit themselves. No task file, no branch, no `.last-hash`.

Only available when no spec or one-off task currently has a `session.md` with
`Status: Active`. See `CLAUDE.md` -> `## Worklog` -> `### Quick Action` for
the full availability rule.

### Before the Action

1. Read `.claude/memory.md` for project-level context
2. Read relevant standards in `.claude/standards/` only if the action touches a
   pattern defined there
3. Do **not** run a branch safety check - no branch will be created
4. Work on whatever branch is currently checked out, UNLESS that branch is
   `master`/`main` or a project-restricted branch (see `.claude/project.md` or
   `.claude/architecture/` for any project-specific restricted branches) - in
   that case, ask the human for a branch to use before making the change

### Making the Change

- Make the targeted edit, run the command, or apply the change
- For code edits, do **not** stage or commit anything - the developer handles
  the commit
- For non-code actions (installs, config changes, migrations), apply the change
  directly

### After the Action

1. Append a row to the worklog at the appropriate scope (see **Scopes** above).
   If that `worklog.md` does not exist yet, create it with the `# Worklog`
   header and the empty table first
2. If the action surfaced a cross-cutting decision or non-obvious constraint,
   append a note to the relevant `memory.md` (`.claude/memory.md` if
   root-scoped, or `.claude/specs/<spec_name>/memory.md` if spec-scoped)
3. Do **not** touch `.claude/tasks/memory.md` or any task's `memory.md` - those
   are for full one-off tasks only
4. Do **not** create a `.last-hash` file
5. Confirm to the developer:

   > *"Done. Files modified: `<list>` (if any). Logged to `<worklog path>`. The
   > change is not staged - commit when ready."*

   For non-code actions with nothing to commit, omit the "not staged" reminder.

---

## Cross-Cutting Logging

While a spec task or one-off task is in progress, any side-effect action that is
not part of the task's listed deliverables - installing a new dependency,
running a migration to test the feature, adjusting local environment config, and
similar - is appended as a row to that spec's or task's `worklog.md` as the
action happens.

This is independent of Quick Action above - it applies during formal task or
spec work and does not require "no active context".

This logging does not require human confirmation per entry - it is written
silently, the same way `.last-hash` is written silently.

---

## Escalation

See `CLAUDE.md` -> `## Worklog` -> `### Escalation`. If a Quick Action or
cross-cutting log entry grows beyond "quick and narrow" - many files,
cross-cutting logic, or something resembling a rewrite or new feature - stop and
ask whether to convert the work to a full task or spec, or continue as a worklog
entry. Do not proceed until the human responds.

---

## Root Worklog Archiving

Applies only to `.claude/worklog.md` (root). Spec-scope and one-off-task-scope
`worklog.md` files are never archived - they remain part of that spec's or
task's permanent record.

When writing a new entry to the root worklog, check for rows older than 30 days:

1. Group the stale rows by month (`YYYY-MM`, by `Date`)
2. For each month, append those rows to `.claude/worklog/archive/YYYY-MM.md`
   (create the file with the same `# Worklog` header and table if it does not
   exist), then remove them from `.claude/worklog.md`
3. For each month archived, add or update a pointer row in
   `.claude/worklog-index.md`:

   `| Resource/Topic | Date Range | Archive File | Summary |`

   - `Resource/Topic` - a short label summarizing what the archived rows relate to
   - `Date Range` - `YYYY-MM-DD to YYYY-MM-DD`
   - `Archive File` - `worklog/archive/YYYY-MM.md`
   - `Summary` - one sentence describing the archived activity

Create `.claude/worklog-index.md` (header + empty table) the first time an
archive pointer row is written, if it does not already exist.

---

## Worklog Tracing for CLAUDE: Comments

Whenever Claude resolves an actionable `CLAUDE:` comment (`TODO`, `FIXME`,
`RESEARCH`, `DOCUMENT`, or `LEARN`) and that resolution is not already one of the
current task's listed deliverables - i.e. it happens as a Quick Action, as an
incidental side-effect during other work, or during a `HUMAN-HANDOFF.md` review -
append a row to the appropriate-scope `worklog.md`:

- `Action` = `` Resolved `CLAUDE: <TYPE>:` at `<file>:<line>`: <short description> ``
- `Outcome` = what was done or found
- `Follow-up` = `None`, or remaining work

This is in addition to, not instead of, the type's normal completion step
(extract to a knowledge file for `LEARN`, write to `.claude/docs/` for
`DOCUMENT`, etc.).

Resolving a `CLAUDE:` comment this way is subject to **Escalation** above - if it
turns out to require many files or a design decision, stop and ask before
proceeding instead of resolving it as a quick, traced action.
