# DOMAIN-KNOWLEDGE.md — Knowledge File Rules

Read this file when writing or updating anything in `.claude/knowledge/`.

---

## Overview

`.claude/knowledge/` contains synthesized summaries Claude uses as a reference
during future tasks. It is written by Claude and read by Claude — it is not
human documentation.

Each domain gets its own folder: `.claude/knowledge/<domain>/`. The single
exception is `app-glossary.md`, which stays flat directly under
`.claude/knowledge/` - see **App Glossary** below.

---

## Rules

- Each domain gets a folder: `.claude/knowledge/<domain>/` (e.g. `auth/`,
  `document-lifecycle/`, `signing/`)
- Folder names are chosen by Claude based on the domain - lowercase kebab-case.
  This folder name is the domain tag used in a spec or task's `## Context Files`
- If a domain folder contains `overview.md`, Claude reads it first, before any
  other file in that folder - same rule as `DIRECTORY-REFERENCE.md`. When
  creating one for a domain folder (e.g. once it exceeds ~100 lines - see
  below), use the standard template in `OVERVIEW-AUTHORING.md`
- Claude may create and update files within a domain folder freely
- Claude may not delete files or folders from `.claude/knowledge/` - flag for
  human review instead
- Write for density: what does a future Claude instance need to know to work correctly
  in this domain? Omit anything already covered by the standards or spec files
- Keep each file short - if a domain folder's content grows beyond ~100 lines,
  split it into multiple files (e.g. `overview.md` plus sub-domain files)

---

## When to Write

- After any task that establishes a new pattern, reveals an edge case, or changes how a
  domain behaves — via the synthesis step in `CLAUDE.md → After Completing a Task`
- When closing a spec — review whether anything from spec memory should be promoted here
- During a handoff review — see `HUMAN-HANDOFF.md`

---

## App Glossary

`.claude/knowledge/app-glossary.md` is a reserved file for app-specific terms,
identifiers, and conventions that recur across specs and tasks. Unlike domain
folders, which each cover a single feature area, the glossary is a single flat
file directly under `.claude/knowledge/` - it is cross-cutting and is never
moved into a domain folder.

Each entry must include:
- What the term is and what it represents
- Where it originates or is generated
- A reference file that shows the canonical usage

**Example entry:**
```
#### `request_id`
A UUID generated per-request via `createUUID()`. Used as the unique identifier
for each API transaction and included in all log entries for traceability.
Reference: `src/api/orders/index.aspx`
```

Claude reads `app-glossary.md` whenever a task references an identifier or
variable that is not defined in the spec or standards. If a term is missing
from the glossary and cannot be resolved from the reference files, stop and
ask — do not invent a definition.

Claude appends new entries to the glossary whenever a task introduces or
clarifies an app-specific term that is likely to recur.
