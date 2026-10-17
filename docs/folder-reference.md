# Folder Reference

Every directory CDP creates or uses, what it's for, who or what writes to
it, and whether it's a **protocol** folder (fixed structure, don't edit by
hand) or **developer-editable** (yours to fill in). See
[Getting Started](index.md) for the broader distinction.

## Root files

| Path | Purpose | Written by | Kind |
|---|---|---|---|
| `CLAUDE.md` | The protocol itself - read at the start of every session | CDP updates | Protocol |
| `project.md` | Your project's own overview, stack, and operating notes | You | Developer-editable |
| `memory/` | Cross-spec decisions and patterns that apply project-wide, one entry file each | Claude | Protocol-managed |
| `worklog/` | Root-scope worklog, one file per session - see [Branching](branching.md) for when this scope applies | Claude | Protocol-managed |
| `test-cases/` | Optional project-wide regression suite, created by you - see [Test Cases](test-cases.md) | You / Claude | Developer-editable |
| `version.txt` | The installed CDP version | CDP install/update | Protocol |
| `autoupdate.sh`, `autoupdate.ps1` | The protocol's self-update scripts (bash, PowerShell) | CDP updates | Protocol |
| `manifest.txt` | The list of your own paths that an update never touches | CDP updates | Protocol |
| `settings.json` | Claude Code tool permissions - shipped once, then yours to adjust | You | Developer-editable |

CDP also ships a set of on-demand procedure files alongside `CLAUDE.md`
(covering things like branching, session handling, and closing a spec) -
these are read only when relevant to what's currently happening, not at
every session start, and are protocol files like `CLAUDE.md` itself.

To keep a project on its current CDP version, create an empty
`.pinned-version` file in the project root (next to `.claude/`, not inside
it); updates are skipped while it exists.

## `standards/`

Language and framework coding conventions Claude follows when writing code.
Once a standard exists for a situation, Claude follows it; where none
exists, it falls back to general best practice. This folder is
protocol-owned - every file in it is replaced on update. Adding a *new*
standards file (for a language or framework CDP doesn't already ship one
for) is safe and persists across updates; editing the *content* of a
standard CDP already ships is not - see [Customization](customization.md).

## `local/overview.md`

Your personal, project-scoped instructions for Claude - MCP connections,
personal tooling, workflow notes. Gitignored, never committed, additive only
(it can't override the protocol or your project's own conventions). See
[The Local Folder](local-folder.md) for the full picture, including its
machine-wide counterpart.

## `knowledge/`

Reference material Claude builds up about your specific application as it
works - domain terms, recurring patterns, decisions worth remembering beyond
a single spec. Starts empty; Claude writes to it as it learns things worth
keeping. Developer-editable in the sense that you can also add to it
directly, but its main writer is Claude itself over time.

Each knowledge file can start with a short header - a one-line `summary`,
the `applies-to` paths it is about, and `tags`. At task start Claude reads in
full only the files that match what the task touches (plus files a spec or
task names explicitly), and sees a one-line summary of everything else,
opening more when it needs to. Files without a header are read whenever
their domain is listed for the task, as before.

Once a `knowledge/<domain>/` folder's content grows past roughly 100 lines,
Claude splits it up and adds an `overview.md` - purpose, a table of what's
in the folder and why, and any notes or restrictions worth stating - without
needing to be asked, since Claude already has standing write access there.
Any other folder can get one too, though there it's not automatic - ask for
one, or Claude adds one once it's clear a folder has genuinely outgrown
being self-explanatory. **If a folder has an `overview.md`, Claude always
reads it first**, before anything else in that folder.

## `design/`, `snippets/`, `.triage/`, `assets/`

Ship empty (a `.gitkeep` placeholder only) and are never touched by an
update once populated:

- `design/` - UI and design guidelines
- `snippets/` - reusable code patterns specific to this codebase
- `.triage/` - a drop-zone: leave files here (proposals, notes, anything)
  for Claude to read and fold into a spec, task, or memory file on request;
  each file is deleted once processed, but the folder itself stays
- `assets/` - reference material Claude reads on demand (PDFs, manuals,
  third-party docs); unlike `.triage/`, source files here are never deleted

## `config/`, `architecture/`, `extensions/`

Seeded with a small starting stub on first install, then yours to fill in
and never touched by an update again:

- `config/` - configuration file reference
- `architecture/` - system structure, folder layout, and (if relevant)
  database schema; add a file here whenever a part of the system is complex
  enough that a map is worth having before touching it
- `extensions/` - overrides a specific protocol behavior a protocol file
  documents as overridable (see [Customization](customization.md));
  register each file you add in `overview.md`'s `Contents` table

## `specs/`

One subdirectory per specification - a body of work delivered through a
sequence of tasks. Each spec folder contains:

| File/folder | Purpose |
|---|---|
| `spec.md` | The specification itself - goal, requirements, scope, acceptance criteria |
| `tasks/` | The individual task files that implement the spec |
| `memory/` | Decisions and notes scoped to just this spec, one entry file each |
| `worklog/` | Logs of quick, in-scope side actions taken while this spec is active, one file per session |
| `test-cases/` | Optional verification suite for this spec - see [Test Cases](test-cases.md) |
| `assets/` | Optional spec-scoped reference material, created on demand |

`specs/spec-template/` is the one exception - a protocol-owned template, not
a real spec, ignored by every process that scans this directory.

See [Example Project](examples/example-project.md) for what a real spec
looks like end to end.

## `tasks/`

One subdirectory per **one-off task** - work that doesn't belong to any
spec. Each has a `task.md`, its own `memory/` and `worklog/`, and
optionally its own `test-cases/` and `assets/`, just not nested under a
spec. `tasks/nnn-task-template/` is the protocol-owned template, and
`tasks/000-sync-memory/` is a ready-made task for recording manual changes
made outside any task.

## Files you'll never see committed

A few files are deliberately gitignored - they track Claude's own working
state, not project content, and are recreated as needed:

- `session.md` (per spec or task) - tracks whether work is active or paused,
  and which branch it's on
- `.last-hash` (per spec or task) - Claude's local record of the last commit
  it made for that piece of work, used to detect drift from manual edits
- `local/overview.md` - your personal instructions for Claude
- `.last-update-check` and `old-versions/` - the update script's own
  timestamp and its backup of the previous templates
