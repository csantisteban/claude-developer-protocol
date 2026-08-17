# Glossary

Precise definitions of CDP-specific terms. If you hit a term elsewhere in
these docs that isn't defined here, treat that as a documentation bug.

### Spec

A feature or body of work delivered through a sequence of **tasks**. Lives in
its own folder under `specs/<spec_name>/`, containing `spec.md` (the
specification itself), a `tasks/` folder, and its own `memory.md`. A spec has
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
Each entry is a row in a `worklog.md` table: date, branch, what was done,
the outcome, and any follow-up still pending. Rows are never edited or
deleted - a correction is a new row. Which `worklog.md` a given action logs
to depends on what's currently active: the root one if nothing is, a spec's
own if that spec is being worked on, a task's own if that task is in
progress.

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

### `index.toml`

A per-spec, Claude-maintained pointer file listing every file inside that
spec's folder with tags and a one-line summary, so a known-relevant spec can
be navigated without opening every file inside it or re-running a full
search. Regenerated in full on every spec task's completion.

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
