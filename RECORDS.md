# RECORDS.md - Memory, Worklog, and Test-Run Records

Read this file whenever writing or reading a memory entry, a worklog file,
or a test-run entry, at any scope.

---

## Overview

Memory, worklog, and test-run notes are append-only records. Each one is a
folder of small dated files, not a single shared file. Every writer - a
session, a parallel task, a subagent, another developer - creates its own
files, so two writers never edit the same file and never cause a merge
conflict on a record.

Other procedure files say *what* to record and *when*. This file is the only
place that defines *how*: folders, file names, the entry header, and the
writing and reading rules. Do not restate these rules elsewhere - point here.

---

## Folders

| Record | Root | Spec | One-off task |
|---|---|---|---|
| Memory | `.claude/memory/` | `.claude/specs/<spec_name>/memory/` | `.claude/tasks/<task-name>/memory/` |
| Worklog | `.claude/worklog/` | `.claude/specs/<spec_name>/worklog/` | `.claude/tasks/<task-name>/worklog/` |
| Test-run notes | - | `.claude/specs/<spec_name>/test-cases/memory/` | `.claude/tasks/<task-name>/test-cases/memory/` |

Which scope to write to is unchanged: see `CLAUDE.md` -> `## Worklog` ->
`### Scopes` for worklogs, and the procedure file that asks for the entry
for memory and test-run notes.

A folder is created on first use, when its first file is written. Record
folders are tracked in git and committed normally. They are never
gitignored.

---

## File Names

Every record file is named:

```
<YYYYMMDDHHMMSS>-<slug>.md
```

- **Timestamp** - UTC, at the moment the file is created:
  `date -u +%Y%m%d%H%M%S` (PowerShell:
  `(Get-Date).ToUniversalTime().ToString('yyyyMMddHHmmss')`). Because the
  timestamp leads, sorting file names sorts by age - no index file is needed.
- **Slug** - a short, descriptive kebab-case phrase, chosen so an agent
  searching by file name finds the entry, e.g.
  `20261013143022-autoupdate-dirty-tree-refused.md`. Name the subject, not
  the author: no developer name unless the person is the subject of the
  entry.
- **Collision** - if the name already exists in the folder, append `-2`,
  `-3`, ... to the slug (`...-dirty-tree-refused-2.md`).

The collision check only sees the current branch. Two writers on different
branches creating the same timestamp and slug in the same second would
produce a git add/add conflict. This risk is accepted - no random suffix is
added, because it would make names harder to search.

---

## Memory Entries

One file per entry. An entry is what used to be one dated `## ` section of a
`memory.md` file: a decision, a constraint, a non-obvious finding.

Every entry starts with a YAML front-matter block:

```markdown
---
date: 2026-10-13T14:30:22Z
summary: Autoupdate refuses a dirty tree instead of snapshot-committing
tags: [autoupdate, git]
supersedes: [20260901101500-autoupdate-snapshot-commit.md]
commit: efa8491
---

The snapshot commit was removed because ...
```

| Field | Required | Meaning |
|---|---|---|
| `date` | Yes | ISO 8601 UTC timestamp - matches the file name |
| `summary` | Yes | One line, written to stand alone as a headline. It is the only part of an older entry Claude sees at task start, so make it specific enough to judge relevance |
| `tags` | Yes | Flow list of short lowercase terms (`[]` if none) |
| `supersedes` | No | Flow list of file names of older entries **in the same folder** that this entry replaces |
| `commit` | No | Short hash of the commit the entry describes |

Each field stays on one line, so plain `grep "^summary:"` reads it - no YAML
parser is needed.

The body is free markdown, as long as the entry needs.

---

## Worklog Files

One file per session (or per subagent), not per row. The file holds the
`# Worklog` table defined in `WORKLOG-AUTHORING.md` and has no front matter.
The slug names the session's work, e.g.
`20261016091500-spec-014-task-001-records-format.md`.

- **During a spec task or one-off task** - the first time the session logs
  a row, create the file and record its name in that scope's `session.md`
  as `**Worklog file:**` (see `SESSION-FILES.md`). Later rows in the same
  session, including after context compaction, go to the file named there.
  A new session creates a new file and updates `**Worklog file:**`.
- **A root Quick Action** - there is no `session.md`, so each Quick Action
  creates its own new file in `.claude/worklog/`.
- **A subagent** - creates its own file at the scope it works in and never
  writes to `session.md`. It names its file in its final report.

---

## Test-Run Entries

One entry per test run, in the scope's `test-cases/memory/` folder. It uses
the same front matter as a memory entry, with the result in `summary:`:

```markdown
---
date: 2026-10-16T10:02:11Z
summary: Login suite 14/15 pass, TC-07 flaky on CI
tags: [login, ci]
commit: 3fa21bd
---

Ran against fixtures `users-basic`. TC-07 timed out twice on the token
refresh step ...
```

The body holds the same detail `test-cases/memory.md` held before: results,
blockers, fixture or script fixes, and the test record IDs used. Never
record credentials, API keys, or auth or session tokens - entries are
committed and kept forever. Those stay in the project's gitignored secrets
location (e.g. `.claude/.env`).

---

## Writing Rules

1. **Never edit or delete another file.** A writer only creates new files,
   and only appends rows to its own worklog file.
2. **Corrections are new entries.** Memory or test-run: write a new entry
   whose `supersedes:` names the old one. Worklog: add a new row to your own
   file.
3. **Do not keep long-lived facts alive in memory.** A fact every future task
   needs belongs in `.claude/knowledge/` or `.claude/project.md` - promote it
   at task completion. There is no "pinned" memory entry.
4. **Commit records with the work they describe** - new entry files are
   staged by folder (e.g. `git add .claude/specs/<spec_name>/memory/`) in the
   same commit as the task, exactly as `memory.md` was before.
5. **Migrate on first write.** Before the first write of a record kind at a
   scope, check for that scope's legacy single file and move it first - see
   **Legacy Files and Migration** below.

---

## Reading Records

### Which entries are live

An entry is **superseded** when any entry in the same folder names it in
`supersedes:`. Superseded entries are skipped in every read below - they
are not shown in full and not shown as headlines. They stay on disk and can
still be opened by name or found by `grep` when history matters.

### Root memory - tiered

At task start, `.claude/memory/` is read in three tiers (test-run notes use
the same tiers - see **Test-run notes - tiered** below):

1. **The 10 newest live entries, in full.**
2. **A headline list for every other live entry** - its file name and
   `summary:` line, nothing more.
3. **The `## ` headings of the legacy file**, if one exists (see **Legacy
   Files and Migration** below).

```bash
D=.claude/memory           # memory folder
OLD=.claude/memory.md      # legacy single file, if not moved yet
sup=$(grep -h '^supersedes:' "$D"/*.md 2>/dev/null | sed 's/^supersedes://' | tr -d '[] ' | tr ',' '\n')
live=$(ls "$D" 2>/dev/null | grep '^[0-9]\{14\}-.*\.md$' | grep -v '^00000000000000-' \
  | grep -vxF -e "${sup:-/}" | LC_ALL=C sort -r)
echo "## Read in full:"
echo "$live" | head -n 10
echo "## Headlines:"
echo "$live" | tail -n +11 | while read -r f; do
  [ -n "$f" ] && printf '%s: %s\n' "$f" "$(grep -m1 '^summary:' "$D/$f" | sed 's/^summary:[[:space:]]*//')"
done
for L in "$D"/00000000000000-legacy-*.md "$OLD"; do
  [ -f "$L" ] && { echo "## Legacy $L:"; grep '^## ' "$L"; }
done
```

Then read each file listed under "Read in full". Only `ls`, `grep`, `sed`,
`tr`, `sort`, `head`, and `tail` are used, so the block runs unchanged in
bash on Linux, macOS, and Git Bash.

### Opening older entries

An older entry (a headline, or a legacy section) is opened in full when:

- its headline or heading is relevant to the current task, or
- the `PRIOR-ART-CHECK.md` Layer 1 term grep matches it.

Claude MAY also read more older entries at any point in a task whenever it
decides the task needs them - the tiers set what is loaded up front, not a
limit on what may be read.

### Spec and one-off task memory - in full

A spec's or one-off task's memory is bounded and entirely relevant to its
own work, so every live entry is read in full: run the block above with `D`
and `OLD` set to that scope (e.g. `D=.claude/specs/<spec_name>/memory`,
`OLD=.claude/specs/<spec_name>/memory.md`), then read every file it lists,
not only the first 10, plus the legacy file in full.

### Test-run notes - tiered

A suite's test-run notes grow with every run, and older runs rarely matter,
so they are read in the same three tiers as root memory: run the block above
with `D` and `OLD` set to the scope's test-run folder (e.g.
`D=.claude/specs/<spec_name>/test-cases/memory`,
`OLD=.claude/specs/<spec_name>/test-cases/memory.md`), read the 10 newest
live entries in full, and keep the headlines and legacy headings for
opening older runs when relevant.

### Newest entry

When a procedure needs "the latest memory entry" (e.g. its date, or the
`commit:` it recorded), use the first file of `$live` above - the newest
live entry by file name - and its `date:` / `commit:` fields. If the folder
has no entries yet, fall back to the legacy file's newest `## ` section.

### Worklogs

Worklogs are not read at task start. When one is needed, list its folder
newest first (`ls <scope>/worklog/ | LC_ALL=C sort -r`) and open files from
the top until the answer is found.

### Excluding the templates

Searches that glob across `.claude/specs/*/` or `.claude/tasks/*/` MUST skip
`spec-template` and `nnn-task-template` - the spec template ships an example
test-run entry that is not a real record.

---

## Legacy Files and Migration

Projects that used CDP before 1.5.0 have single record files. They are never
split, edited, or rewritten - at most they are moved, unchanged.

| Legacy file (any scope) | Moved to |
|---|---|
| `memory.md` | `memory/00000000000000-legacy-memory.md` |
| `worklog.md` | `worklog/00000000000000-legacy-worklog.md` |
| `test-cases/memory.md` | `test-cases/memory/00000000000000-legacy-memory.md` |

The all-zero timestamp sorts the legacy file before every real entry, so it
is always the oldest file in the folder.

**Migration is lazy.** Nothing is migrated up front. The first time Claude
writes a record of one kind at a scope that still has the legacy file for
that kind, it:

1. Moves the file unchanged with `git mv` (e.g.
   `git mv .claude/memory.md .claude/memory/00000000000000-legacy-memory.md`)
2. Writes the new entry or worklog file in the same folder
3. Logs the move as a row in its own worklog file
4. Commits the move together with the new record - the same commit, never a
   separate one. In a Quick Action, where the developer commits, Claude
   tells the developer the move is staged.

If two branches migrate the same legacy file, both make the identical
rename and git merges them cleanly.

**Readers handle both states.** Until a scope is migrated, its legacy file
sits at the old path; afterwards it sits in the folder. Every read in
**Reading Records** checks both places (`OLD` and
`00000000000000-legacy-*.md`) and treats either one as the legacy file.

**Files that are never moved:**

- `.claude/tasks/memory.md` - the retired one-off task index. It stays where
  it is, read-only; `STARTING-ONE-OFF-TASK.md` still reads it if present.
- `.claude/worklog-index.md` and `.claude/worklog/archive/` - the retired
  root-worklog archive. They stay where they are, read-only, and are opened
  only when an old worklog row is needed.
