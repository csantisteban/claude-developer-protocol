# DOMAIN-KNOWLEDGE.md — Knowledge File Rules

Read this file when writing or updating anything in `.claude/knowledge/`, and
at the start of every spec or one-off task for **Loading Knowledge at Task
Start** below.

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
- Every knowledge file Claude creates or updates gets the header below

---

## File Header

A knowledge file starts with a YAML front-matter block that tells Claude when
the file is relevant:

```markdown
---
summary: How refresh tokens rotate and when a session is revoked
applies-to: [src/auth/**, src/api/session/*.ts]
tags: [auth, tokens, session]
---
```

| Field | Meaning |
|---|---|
| `summary` | One line that stands alone as a headline - it is all Claude sees of the file when the file is not loaded |
| `applies-to` | Flow list of path globs, relative to the project root. A task whose deliverables match one is given the whole file. `*` matches any characters, including `/`, so `src/auth/*` covers everything below `src/auth/` |
| `tags` | Flow list of short lowercase terms, matched against the task's key terms |

Each field stays on one line, so plain `grep` reads it. The header is
optional: a file without one (or without `applies-to`) keeps the old
behavior - it is read in full whenever its domain is listed in `Domains:`.

**When Claude writes or updates a knowledge file** (task-completion synthesis,
spec close, handoff review), it fills in or refreshes all three fields:
`applies-to` from the files the task touched that the knowledge is about,
`summary` and `tags` from the content. Adding a header to an existing
headerless file is the normal way it moves to relevance loading.

`app-glossary.md` takes no header - it is always read in full.

---

## Loading Knowledge at Task Start

Run by step 12 of `STARTING-SPEC-TASK.md` / `STARTING-ONE-OFF-TASK.md`, after
`app-glossary.md` has been read (step 11). Every knowledge file ends up either
read in full or listed as a one-line headline - none is skipped silently.

1. **Domain overviews** - for each domain in `## Context Files` `Domains:`,
   read `.claude/knowledge/<domain>/overview.md` first if it exists.
2. **Headerless files in listed domains** - read in full every file in a
   listed domain that has no `applies-to` line (today's behavior).
3. **`applies-to` match** - read in full every knowledge file, in any domain,
   with a glob that matches a deliverable of the current task:
   ```bash
   # Deliverables of the current task, one path per line, relative to the project root
   deliverables='src/auth/login.js
   src/api/session/refresh.ts'
   grep -rl --include='*.md' '^applies-to:' .claude/knowledge | while read -r k; do
     grep -m1 '^applies-to:' "$k" | sed 's/^applies-to://' | tr -d '[] ' | tr ',' '\n' \
     | while read -r g; do
         echo "$deliverables" | while read -r f; do
           [[ -n "$g" && "$f" == $g ]] && echo "$k"
         done
       done
   done | sort -u
   ```
4. **Named files** - read in full every file named in `## Context Files` with
   the file-level form `Knowledge: <domain>/<file>.md`.
5. **Headlines for the rest** - list every knowledge file not read above
   (except `app-glossary.md`) as one line: its `summary:`, or its first `# `
   heading if it has no header:
   ```bash
   find .claude/knowledge -name '*.md' ! -name app-glossary.md | LC_ALL=C sort \
   | while read -r k; do
       h=$(grep -m1 '^summary:' "$k" | sed 's/^summary:[[:space:]]*//')
       [ -z "$h" ] && h=$(grep -m1 '^# ' "$k" | sed 's/^# //')
       printf '%s: %s\n' "$k" "${h:-(no summary)}"
     done
   ```
   Skip the lines for files already read.
6. **Unlisted domains** - run `ls .claude/knowledge/` and flag to the human,
   as possibly relevant, any domain folder not listed in `Domains:`.

Two more ways a file gets read in full later in the task:

- **Term match** - when `PRIOR-ART-CHECK.md` Layer 1 runs, any knowledge file
  whose `summary` or `tags` match one of the task's key terms is read in full.
- **Claude's judgment** - Claude MAY open any headline-listed file at any
  point in the task when it looks relevant.

---

## When to Write

- After any task that establishes a new pattern, reveals an edge case, or changes how a
  domain behaves — via the synthesis step in `CLAUDE.md → After Completing a Task`
- When a fact in memory turns out to be long-lived - every future task needs
  it - promote it here instead of keeping it alive in memory (see `RECORDS.md`)
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
