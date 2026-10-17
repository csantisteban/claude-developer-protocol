# OVERVIEW-AUTHORING.md - overview.md Template and Sync Rule

Read this file when creating a new `overview.md`, or when working in a folder
whose existing `overview.md` `Contents` table looks out of date.

---

## When This Applies

`overview.md` is never required - Claude does not create one unprompted. When
one is warranted (a human asks for it, or a folder has grown complex enough
that a map helps), use the template below.

**Exceptions - these already have an established, working format and are not
migrated to the template below:**

- `.claude/architecture/overview.md`
- `.claude/standards/overview.md`
- Any spec or task `test-cases/overview.md` (see `002-test-cases-protocol`,
  extended with `Notes`/`Restrictions` sections by `009-discovery-conventions`)

The template applies to `overview.md` files for folders that don't already
have one of these established shapes - e.g. a new `.claude/knowledge/<domain>/`
folder (per `DOMAIN-KNOWLEDGE.md`), or a project-specific folder created
during ordinary project work.

---

## Template

```markdown
# Overview - {folder name or purpose}

## Purpose

{1-3 sentences: what this directory is for and why it exists}

## Contents

| File / Subdir | Purpose |
|---|---|
| `{name}` | {one-line description} |

## Notes

{Free-form remarks or context that don't fit the table - known quirks,
historical reasons something looks the way it does, anything a human would
want to say out loud when handing this folder to someone else. Omit this
section if there's nothing to add.}

## Restrictions

{Scope fence - what Claude must NOT touch or change while working in this
folder, if anything. Omit this section if there are no restrictions.}
```

A folder with a more specialized need may append further sections after
`Restrictions` rather than replacing any of the four above.

---

## Keeping Contents in Sync

If Claude works in a folder that has an existing `overview.md` and finds a
file not reflected in its `Contents` table, Claude updates the `Contents`
table as part of the same piece of work - no separate confirmation step.
