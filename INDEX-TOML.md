# INDEX-TOML.md - Per-Spec Index (`index.toml`)

Read this file when reading or writing a spec folder's `index.toml`.

---

## Overview

`index.toml` is a Claude-maintained, per-spec pointer file listing every file
inside a spec folder with tags and a one-line summary. It lets Claude find
the right file inside a *known-relevant* spec without opening every file or
re-running a full prior-art search.

**Pilot scope:** `.claude/specs/<spec_name>/index.toml` only. Claude MUST NOT
create `index.toml` files anywhere else - including
`.claude/tasks/<task-name>/` - without explicit human instruction to extend
the pilot.

**Location:** `.claude/specs/<spec_name>/index.toml`

Unlike `.last-hash` and `session.md`, `index.toml` is committed normally - it
is meant to be discoverable by anyone reading the repo, not just Claude's
local working state.

---

## Schema

```toml
generated_at = "YYYY-MM-DDTHH:MM:SS"

[[entry]]
file = "spec.md"
tags = ["goal", "requirements", "scope"]
summary = "One line describing what this file contains."

[[entry]]
file = "tasks/001-example-task.md"
tags = ["implementation"]
summary = "One line describing what this task did."
```

- `generated_at` - timestamp of the regeneration that produced this file.
  Informational only - nothing is compared against it.
- `[[entry]]` - one per file in the spec folder: `spec.md`, every file in
  `tasks/`, and `memory.md`. Do not add entries for `session.md`,
  `.last-hash`, `worklog.md`, `test-cases/`, or `index.toml` itself.
- `tags` - short lowercase keywords describing the file's content, not its
  filename
- `summary` - one line, factual, describing what the file contains - not why
  it was written

---

## Trusting an Existing `index.toml`

There is no separate staleness check. `index.toml` is regenerated in full,
unconditionally, on every spec task completion (see **Full Regeneration**
below) - so by the time any task starts, it is guaranteed accurate as of the
last completed task. If it exists, read it and trust it.

The only way it could go stale is via something outside the normal task
flow - a direct edit, a handoff review, a hand-authored change to `spec.md`.
Those are already caught elsewhere and do not need a second mechanism here:
the Sync Check on `.last-hash` (`STARTING-SPEC-TASK.md` step 4) surfaces
drift since the last known task commit, and Pre-Close Reconciliation
(`CLOSING-SPEC.md`) explicitly checks for out-of-band edits before a spec
closes.

A commit-hash-based staleness check was considered and dropped for two
reasons: `index.toml` lives inside the folder it tracks, so the commit that
regenerates it is itself the newest touch to that folder - the recorded
hash can never equal "the folder's current latest commit" by construction,
making the check misfire on every regeneration. It would also inherit the
same fragility documented for `.last-hash`'s orphaned-hash case - a
`git merge --squash` can discard the commit a stored hash points into
entirely.

---

## Full Regeneration

`index.toml` is always regenerated in full, never patched. On every spec task
completion (see `COMPLETING-SPEC-TASK.md`):

1. Re-scan `spec.md`, `memory.md`, and every file in `tasks/`
2. Rewrite `[[entry]]` for each, replacing the entire file content
3. Set `generated_at` to the current timestamp

If the spec folder has no `index.toml` yet, create it the same way - full
regeneration is identical whether the file is new or being refreshed.

---

## What Claude Must Not Do

- Do not hand-edit `index.toml` - always regenerate in full, even for a
  one-line change
- Do not synthesize "why" content in a `summary` - state what the file
  contains, not the reasoning behind it (that belongs in `memory.md`)
- Do not expand the pilot scope beyond `.claude/specs/<spec_name>/` and
  `assets/` (see below) without explicit human instruction, even if the same
  routing problem seems to apply elsewhere (e.g. `.claude/tasks/<task-name>/`
  outside of its own `assets/` subfolder)

---

## Assets Index (`assets/index.toml`)

The pilot scope is explicitly extended to any populated `assets/` folder:
`.claude/assets/`, `.claude/specs/<spec_name>/assets/`, and
`.claude/tasks/<task-name>/assets/`. Same `file` / `tags` / `summary` schema
as above - one `[[entry]]` per file placed in that `assets/` folder.

**This does not extend the pilot to `.claude/tasks/<task-name>/index.toml`
itself** - only to an `assets/` subfolder if one exists under a task or spec.

### Different lifecycle from a spec's `index.toml`

A spec's `index.toml` is regenerated in full on every spec task completion,
because the spec folder's contents are fully known and rewritten at that
cadence. `assets/index.toml` has no such cadence - files accumulate whenever
the human drops them in, and are read whenever a task needs them, independent
of any task completion. So `assets/index.toml` is updated **incrementally**:

- When Claude reads an asset file in that folder to find specific
  information, append a new `[[entry]]` if the file has none yet, or update
  the existing one if the file's content or relevant tags have changed
- Do not touch entries for files Claude has not read
- Update `generated_at` to the current timestamp on every incremental update,
  same meaning as the spec-level file (informational only)

### `glossary.md`

Alongside `index.toml`, each populated `assets/` folder also gets a
Claude-maintained `glossary.md` - synthesized definitions or facts extracted
from the asset files, updated the same way (incrementally, on demand):

```markdown
# Assets Glossary

## <Term or Fact>
<One or two sentence definition or fact, synthesized from the source asset.>
Source: `assets/<file>`
```

Unlike `.triage/`, source files in `assets/` are reference material and are
**never deleted** after their content is synthesized into `glossary.md` /
`index.toml` - only the derived files are written or updated.
