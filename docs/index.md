# Getting Started

CDP (Claude Developer Protocol) is a structured way for Claude Code to work
on a software project: instead of freeform back-and-forth, work is organized
into **specs** and **tasks**, tracked with a **worklog**, and backed by
**persistent memory** so decisions survive across sessions. This page
explains how to install it, how a session actually flows once it's
installed, and which parts of it you're expected to touch versus leave alone.

If you haven't seen any of CDP's terms before, keep [Glossary](glossary.md)
open alongside this page.

## Installing CDP

Run the install script from your project's root directory - the same
directory that will contain the `.claude/` folder CDP creates. See this
repository's own `README.md` for the exact install command for your platform.

Installing creates a `.claude/` directory containing the protocol itself
(`CLAUDE.md` and its on-demand companion files), coding standards, templates
for new specs and tasks, and a handful of empty directories you'll populate
as you use the project.

## What happens at the start of every session

Every time Claude starts working in a project with CDP installed, it runs a
fixed sequence of checks before responding to anything:

1. Read your personal instructions, if you've set any (machine-wide and/or
   project-scoped - see [The Local Folder](local-folder.md)).
2. Read the project's own overview and stack (`project.md`), if present.
3. Check whether a previous spec or task was left paused, and offer to resume it.
4. Check whether any spec is still `Open` (started but not formally closed),
   and mention it.
5. Check whether a protocol update is available.

None of this requires you to do anything - it's context-gathering. You only
get prompted if there's something genuinely worth flagging (a paused session,
an open spec).

## How work gets organized

Not every request becomes a formal spec or task. Claude decides based on two
questions:

- **Does answering require reading files?** If yes, it's at least worth a
  quick investigation.
- **Could the answer change what gets built next?** If yes, it needs to be
  written down, not just answered in passing.

If the answer to both is no, Claude just answers you directly - nothing gets
created. If either is yes, Claude drafts a task file and shows it to you
before writing anything to disk or touching any other files. Small, bounded
changes (a config tweak, a dependency bump, a one-line fix) skip the task
file entirely and go through the lighter-weight **worklog** instead - see
[Branching](branching.md) for how that interacts with git, and
[Glossary](glossary.md) for what "spec" and "one-off task" actually mean.

## Three kinds of folders

Everything CDP creates falls into one of three categories, based on how
CDP's own update mechanism treats it - knowing which is which matters before
you start changing things:

**Protocol-owned - replaced on every update, don't hand-edit:**

- `CLAUDE.md` and its on-demand companion files (the procedure files it
  references, like the ones covering branching or session handling)
- `standards/` - you can safely *add* a new file here for a language or
  framework CDP doesn't already cover, but editing the *content* of a
  standard CDP already ships will be overwritten the next time it updates
- `specs/spec-template/`, `tasks/nnn-task-template/` - templates for new work

**Seeded once, then yours forever - the update mechanism never touches these
again after first install:**

- `project.md`, `memory.md` - your project's own overview and cross-spec memory
- `local/overview.md` (and its machine-wide counterpart) - your personal
  instructions, never committed
- `architecture/`, `config/` - start as a small stub, then you fill them in
- Every real spec and task you create under `specs/` and `tasks/` (matched
  by number, not by name)

**Shipped empty, yours to populate, also never touched by an update:**

- `knowledge/` - builds up over time, mostly written by Claude as it learns
  things about your project
- `design/`, `snippets/`, `.triage/`, `assets/` - reference material and
  drop-zones you populate as needed

See [Folder Reference](folder-reference.md) for the full breakdown, and
[Customization](customization.md) for what you're expected to fill in first.

## Where to go next

- [Folder Reference](folder-reference.md) - what every directory is for
- [Branching](branching.md) - how CDP's branch naming and merging works
- [Customization](customization.md) - what to adapt for your own project
- [Example Project](examples/example-project.md) - a worked example showing
  a spec, a task, and a worklog entry in use
