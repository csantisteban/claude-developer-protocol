# Glossary

Precise definitions of CDP-specific terms. If you hit a term elsewhere in
these docs that isn't defined here, treat that as a documentation bug.

### Spec

A feature or body of work delivered through a sequence of **tasks**. Lives in
its own folder under `specs/<spec_name>/`, containing `spec.md` (the
specification itself), a `tasks/` folder, and its own `memory/` folder. A spec has
a `Status` - `Open` (ready to work on), `Hold` (paused), `Obsolete` (won't be
implemented, kept for reference), or `Closed` (all tasks complete, security
review done).

### Task (spec task)

A single, scoped unit of implementation work that belongs to a spec. Task
files live under `specs/<spec_name>/tasks/`, numbered sequentially
(`001-`, `002-`, ...). A task file covers only its own step - the
background and requirements it implements live in the parent spec, not
repeated in the task file.

### One-off task

Like a spec task, but not tied to any spec - a standalone piece of work with
its own folder under `tasks/<task-name>/`. Used when work doesn't belong to
a larger body of work, or when a spec hasn't been (and doesn't need to be)
written for it.

### Worklog

An append-only record of quick, narrow-scope actions - code edits,
troubleshooting commands, dependency installs, config changes, and similar.
Each entry is a row in a worklog table: date, branch, what was done, the
outcome, and any follow-up still pending. Every session writes its own file
in a `worklog/` folder, so parallel sessions never edit the same file. Rows
are never edited or deleted - a correction is a new row. Which `worklog/`
folder a given action logs to depends on what's currently active: the root
one if nothing is, a spec's own if that spec is being worked on, a task's
own if that task is in progress.

### Memory

Decisions and non-obvious findings Claude records as it works, at three
scopes: the project (`memory/`), a spec (`specs/<spec_name>/memory/`), and a
one-off task (`tasks/<task-name>/memory/`). Each entry is its own small file,
named by its UTC timestamp and a descriptive slug, with a one-line
`summary:` header. At task start Claude reads the 10 newest project entries
in full and only the summary line of older ones, opening an older entry when
it is relevant. A spec's or task's own memory is read in full. Entries are
never edited: a correction is a new entry that names the old one in
`supersedes:`, which hides the old one from future reads. Facts every task
needs are promoted to `knowledge/` instead of being kept alive in memory.

### Records

The append-only logs Claude keeps as it works: **memory**, **worklogs**, and
test-run notes (`test-cases/memory/`). Each is a folder of small files, one
per entry or per session, named `<YYYYMMDDHHMMSS>-<slug>.md` so they sort by
age and are easy to search by name. Because every writer creates its own
files, parallel tasks and sessions never conflict on a record. Projects that
used CDP before 1.5.0 keep their old single `memory.md` / `worklog.md` files;
Claude moves each one, unchanged, into its folder the first time it records
something at that scope.

### Knowledge

Curated reference material about your application, under
`knowledge/<domain>/`, plus the flat `knowledge/app-glossary.md`. Unlike
memory, a knowledge file is kept up to date rather than appended to. A file
can start with a header - `summary`, `applies-to` (the paths it is about),
and `tags` - and Claude reads it in full when a task touches one of those
paths, when a spec or task names it, or when its summary or tags match the
task; otherwise Claude sees only its one-line summary. Files without a header
are read whenever their domain is listed for the task.

### Task draft

A task file Claude has written but you haven't approved yet. It carries a
`> **Status:** Draft` line until you approve it (the line is removed),
request changes (the file is edited in place), or reject it (the file is
deleted). Drafts left over from an earlier session are listed at the next
session start.

### Quick Action

A small, bounded change - code or non-code - that the developer will apply
or commit themselves, logged to a worklog rather than going through a full
task file. Only available when no spec or one-off task currently has an
active session; otherwise the work belongs to whatever is already active.

### `session.md`

A gitignored, per-spec or per-task file tracking whether that piece of work
is currently active or paused, which branch it's on, and (if paused) a
summary of where things were left off and what to do next. Never committed -
it's local working state, not project content.

### `.last-hash`

A gitignored, per-spec or per-task file recording the hash of the last
commit Claude made for that work. Used at the start of the next session
touching that spec/task to detect drift - manual edits, direct commits, or a
squash merge that orphaned the recorded commit - before continuing.

### `extensions/`

A seeded-once, operator-owned folder for overriding a specific protocol
behavior that a protocol file explicitly documents as overridable, without
editing a protocol-owned file that would be overwritten on the next
update. Its `overview.md` is the registry of every override you've
registered - see [Customization](customization.md).

### Prior Art Check

A mandatory check run before writing any code for a task: search existing
project memory and knowledge for anything relevant that was already decided
or already tried, and check the git history of every file the task will
touch. Runs the same way every time, including reporting an explicit
"nothing found" - it doesn't rely on Claude guessing something looks related
before deciding to look.

### Human Handoff

The procedure for Claude to learn from changes a human made directly,
outside of any spec or task - reviewing what changed and folding the
relevant context into memory so future work accounts for it.

### `CLAUDE:` comment

A reserved comment prefix for leaving notes directly for Claude inside
source files - a first-class input that gets read and acted on, not just
regular code commentary.

### Amendment (`amend`)

A task that changes a spec's own requirements, as opposed to a task that
implements requirements as originally written. Used when a spec turns out to
need correcting rather than just building.

### Investigation

Mid-spec triage of an unexpected result - what a test or a manual check
found versus what was expected, worked through to a verdict, with no code
changed until the verdict is reviewed and a next step is authorized.

### Research

A standalone, read-only look into how something works or how a system
behaves, producing a findings report. No code is changed.

### Ad-hoc change

A small, well-understood change that's Quick-Action-sized in scope but still
needs its own git branch - typically because it will later be folded into a
release branch, or because the branch that's currently checked out is
off-limits for new commits.
