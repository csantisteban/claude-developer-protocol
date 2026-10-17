# WORKLOG-AUTHORING.md - Worklog Format and Procedures

Read this file when writing a worklog entry for the first time in a session,
or executing a Quick Action.

---

## File Shape

A worklog is a folder of files, one per session (or subagent), at each
scope - see `RECORDS.md` for folders, file names, and how a session finds its
own file again. Every worklog file is a single append-only markdown table:

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
- Rows are never edited or deleted - corrections are new rows in your own
  file
- Append only to your own session's file - never to another session's or
  subagent's file
- Worklog files are tracked in git and committed normally, like memory
  entries - they are not gitignored and are not ephemeral like `session.md`
  or `.last-hash`

---

## Scopes and Selection

See `CLAUDE.md` -> `## Worklog` -> `### Scopes` for the scope-selection table
(root / spec / one-off task) and how to choose between them.

Worklog folders and files are created on first use - the first row a
session logs at that scope - not pre-scaffolded.

---

## Quick Action

A Quick Action is a small, bounded action - code or non-code - the developer
will apply or commit themselves. No task file, no branch, no `.last-hash`.

Only available when no spec or one-off task currently has a `session.md` with
`Status: Active`. See `CLAUDE.md` -> `## Worklog` -> `### Quick Action` for
the full availability rule.

### Before the Action

1. Read root memory (`.claude/memory/`) for project-level context, tiered (see
   `RECORDS.md` -> **Reading Records**)
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

1. Create a new worklog file for this Quick Action at the appropriate scope
   (see **Scopes** above and `RECORDS.md`) with the `# Worklog` header and
   table, and add the row
2. If the action surfaced a cross-cutting decision or non-obvious constraint,
   write a memory entry (see `RECORDS.md`) in `.claude/memory/` if
   root-scoped, or `.claude/specs/<spec_name>/memory/` if spec-scoped
3. Do **not** write to any one-off task's `memory/` - that is for full
   one-off tasks only
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
similar - is appended as a row to this session's worklog file at that spec's or
task's scope (named in `session.md` as `**Worklog file:**`, see `RECORDS.md`)
as the action happens.

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

## Worklog Tracing for CLAUDE: Comments

Whenever Claude resolves an actionable `CLAUDE:` comment (`TODO`, `FIXME`,
`RESEARCH`, `DOCUMENT`, or `LEARN`) and that resolution is not already one of the
current task's listed deliverables - i.e. it happens as a Quick Action, as an
incidental side-effect during other work, or during a `HUMAN-HANDOFF.md` review -
append a row to this session's worklog file at the appropriate scope:

- `Action` = `` Resolved `CLAUDE: <TYPE>:` at `<file>:<line>`: <short description> ``
- `Outcome` = what was done or found
- `Follow-up` = `None`, or remaining work

This is in addition to, not instead of, the type's normal completion step
(extract to a knowledge file for `LEARN`, write to `.claude/docs/` for
`DOCUMENT`, etc.).

Resolving a `CLAUDE:` comment this way is subject to **Escalation** above - if it
turns out to require many files or a design decision, stop and ask before
proceeding instead of resolving it as a quick, traced action.
