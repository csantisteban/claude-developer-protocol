# PRIOR-ART-CHECK.md - Prior-Art Check

Read this file before writing any code for a spec task or a one-off task -
run in full, every time, immediately after the `## Required Context` read in
`STARTING-SPEC-TASK.md` / `STARTING-ONE-OFF-TASK.md`.

---

## Overview

Prior art gets missed when Claude only searches for what it happens to guess
is relevant. This check makes discovery unconditional instead: it does not
depend on Claude judging that something looks related before it decides to
look. It runs the same three layers every time, for every task, and always
reports what it found - including an explicit "nothing found" when all three
come back empty.

---

## Layer 0 - Required Context

Confirm `## Required Context` was read:

- **Spec task** - read from `.claude/specs/<spec_name>/spec.md`
- **One-off task** - read from `.claude/tasks/<task-name>/task.md`

If the section is absent from that file, do not skip this layer silently -
report it explicitly: *"`## Required Context` not defined for this
spec/task."*

---

## Layer 1 - Term-expanded grep

Expand the task's key terms (feature name, domain nouns, file names involved)
with obvious synonyms and abbreviations, then grep across:

```bash
grep -rl "<term>" .claude/knowledge/ \
  .claude/memory.md \
  .claude/specs/*/memory.md \
  .claude/specs/*/spec.md \
  .claude/tasks/*/memory.md \
  .claude/tasks/memory.md
```

- `.claude/knowledge/` uses the current per-domain folder structure
  (`.claude/knowledge/<domain>/`) - search every domain folder, not a flat
  `.claude/knowledge/*.md` glob.
- Include closed specs - `.claude/specs/*/spec.md` and
  `.claude/specs/*/memory.md` are not filtered by `Status`.

---

## Layer 2 - Git history and `CLAUDE:` comments

For every file listed in the task's deliverables:

```bash
git log --oneline --all -- <file>
grep -n "CLAUDE:" <file>
```

This surfaces prior commits that touched the same file and any `CLAUDE:`
comments already left there - both are prior art even when never written
down in memory or a spec.

---

## Reporting

Combine the findings from all three layers into a single summary presented
to the human before any code is written. If a layer found nothing, say so -
never omit a layer from the summary because it came back empty. An explicit
"nothing found" across all three layers is a valid, complete result - state
it plainly rather than skipping the report.
