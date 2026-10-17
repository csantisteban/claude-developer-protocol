# Customization

CDP ships with a working baseline, but it's meant to be adapted to your
project and your team, not used unchanged. These are the same folders
[Getting Started](index.md) labeled "developer-editable" - this
page goes into what actually belongs in each one.

## `project.md`

Your project's overview and stack. If this file doesn't exist, Claude falls
back to whatever a spec itself defines - but for any real project, this is
the first thing worth filling in: what the project is, what technologies it
uses, and any operating notes specific to how your team works (commit
message conventions, where source vs. generated content lives, anything a
new contributor - human or AI - would need to know up front).

**Worked example**, for the fictional Lighthouse Notes app from
[Example Project](examples/example-project.md):

```markdown
# Project Overview

Lighthouse Notes is a note-taking app - users write short notes and tag
them for later filtering. This project is a small React + TypeScript
single-page app with a lightweight Node API.

---

## Stack

| Layer    | Technology       |
| -------- | ---------------- |
| Frontend | React, TypeScript |
| API      | Node.js, Express |
| Storage  | SQLite           |

---

## Standards & References

- See `.claude/standards/typescript.md` and `.claude/standards/javascript.md`
  for coding conventions
- See `.claude/standards/git.md` for commit message format

## Notes

- Views live in `src/views/`, shared types in `src/models/`
- No generated/build output is committed - `dist/` is gitignored
```

Short and specific beats exhaustive - this example covers exactly what the
next contributor (human or Claude) needs before touching the codebase, and
nothing else.

**Copyright headers.** A `## Copyright` section in `project.md` sets the
copyright header for new source files, for any standard that has a header
rule (the C# standard does). Give the holder, or the full header text, or
write `This project does not enforce copyright headers.` to turn the rule
off. If the section is missing, Claude asks once the first time it needs a
header and records your answer there.

## `standards/`

CDP ships a baseline set of language and framework conventions, and this
folder is protocol-owned - every update replaces its shipped files. The safe
customization point is **adding** a new standards file for a language or
framework CDP doesn't already cover; that file will never be touched by an
update, since the update only replaces files it ships itself. Editing the
*content* of a standard CDP already ships (to change a naming convention or
add a team-specific rule) will be silently overwritten the next time CDP
updates - that's not a safe place to make a lasting change. Once a standard
exists for a given language or situation, Claude follows it; where none
exists, it falls back to general industry best practice.

## `local/overview.md` and its machine-wide counterpart

Personal instructions for Claude that should never be committed - a personal
MCP connection, your own tracking setup, workflow preferences specific to
you rather than the project or team. Two versions exist: a project-scoped
one (this file) and a machine-wide one that applies to every project on your
machine. Both are strictly additive - they can give Claude extra context and
capabilities, but can never override the project's own conventions or the
protocol itself. See [The Local Folder](local-folder.md) for the full detail.

## `knowledge/`

Starts empty. As Claude works on your project, it writes domain terms,
recurring patterns, and decisions worth remembering here - but you can also
seed it directly with anything you already know is worth having on hand
before Claude encounters it organically. Give a file an `applies-to` header
listing the paths it is about, and Claude loads it whenever a task touches
those paths - see [Folder Reference](folder-reference.md#knowledge).

## `design/`, `snippets/`

Empty by default, yours to populate, never touched by an update:

- Drop UI/design guidelines into `design/` if visual consistency matters for
  your project.
- Add reusable code patterns to `snippets/` as they emerge.

## `config/`, `architecture/`

Seeded with a small stub on first install, then yours - also never touched
by an update again after that:

- Document configuration file structure in `config/` if your project has
  config that isn't self-explanatory.
- Add a file to `architecture/` whenever a part of the system is complex
  enough that a map is worth having before touching it - this is the one
  most worth investing in early, since Claude treats a missing architecture
  file as a reason to stop and ask rather than guess at system structure.

## `extensions/`

Also seeded on first install, then yours - but unlike `architecture/` and
`config/`, this folder isn't for describing your project. It's for
overriding a specific protocol *behavior* that a protocol file explicitly
says can be overridden - starting with the commit-message format used when
squashing a release (see [Branching](branching.md)). Add a file here with
whatever name you like, then register it in `extensions/overview.md`'s
`Contents` table so Claude knows what it overrides. If nothing is
registered, or the folder is empty, Claude follows the protocol's built-in
default - nothing changes until you add an override.

If `project.md` says something that contradicts a registered override,
Claude stops and asks which one to follow rather than guessing.

## What you don't customize

`CLAUDE.md` itself and its on-demand companion files are the protocol -
fixed structure, updated by CDP's own update mechanism, not by hand. The
one documented exception is `extensions/`, above - for anything else, if a
protocol behavior doesn't fit your team, that's worth raising as feedback
rather than editing directly - a hand-edited protocol file will just get
overwritten by the next update.
