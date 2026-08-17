# SPEC-AUTHORING.md — Spec and Task Authoring Procedure

Read this file when the human asks Claude to help write a spec or a task file.
No code or project files may be modified during this procedure.

---

## Overview

Spec and task authoring is a read-only, investigative mode. Claude's job is to
close the gap between the human's intent and an unambiguous, executable document.

The human starts with a brain dump -- free-form, imprecise, no file references
required. Claude does the research to ground it in the actual codebase, asks
only what cannot be inferred from code, and produces the first draft.

**At no point during authoring may Claude modify any source file, config file,
migration, or any file outside `.claude/specs/` or `.claude/tasks/`.**
This is a hard constraint, not a default. If Claude notices something broken or
improvable while researching, it notes it in the spec's `memory.md` or flags it
to the human -- it does not fix it.

---

## Authoring a Spec

### Step 1 -- Receive the brain dump

The human provides a free-form description of the goal. It may be vague, use
informal language, reference things by nickname, or omit file paths entirely.
Accept it as-is. Do not ask clarifying questions yet.

---

### Step 2 -- Read project context (read-only)

Before touching the codebase, read the project-level reference files:

1. `.claude/project.md` -- project overview and stack (if it exists)
2. `.claude/architecture/overview.md` -- then any architecture files relevant to
   the brain dump's domain (if the directory exists)
3. `.claude/standards/overview.md` -- to know which standards will apply
4. `.claude/memory.md` -- cross-spec decisions that may constrain this spec
5. `.claude/knowledge/app-glossary.md` -- to recognize domain terms in the brain dump

If any of these files are missing, skip silently.

---

### Step 3 -- Research the codebase (read-only)

Investigate the areas of the codebase the brain dump touches. The goal is to
replace guesswork in the spec with facts from the code.

Work through these steps:

1. **Find related implementations** -- read `.claude/architecture/project-structure.md`
   to identify the relevant source directories and file types for this project.
   Use those to scope the search -- do not hardcode extensions or paths:
   ```bash
   grep -rn "<key term from brain dump>" <directories from project-structure.md>
   ```

2. **Read the files surfaced** -- do not stop at file names. Read enough of each
   file to understand its structure, patterns, and conventions. Note line ranges
   where the relevant logic lives.

3. **Trace data and dependencies** -- follow the chain: if the brain dump mentions
   a table, find the migration and any files that read or write it. If it mentions
   a component, find what calls it and what it calls.

4. **Check existing specs** -- scan `.claude/specs/*/spec.md` for related work.
   A prior spec may define a pattern, a constraint, or a dependency that affects
   this one:
   ```bash
   grep -rn "<key term>" .claude/specs/*/spec.md 2>/dev/null
   ```

5. **Identify unknowns** -- list things the brain dump implies but does not define,
   things the code suggests but does not confirm, and anything that would require
   a product or architecture decision.

6. **Capture external references** -- note every file mentioned during research
   or the interview round that would not otherwise become a numbered
   requirement: design guides, `.claude/knowledge/` entries not already covered
   by `## Context Files`, related specs, or anything else the human references
   conversationally.

**Synthesize as you go:** if the research surfaces a pattern, term, or decision
that belongs in `.claude/knowledge/`, write or update that file now -- same rule
as post-task synthesis. Authoring research is real learning. See `DOMAIN-KNOWLEDGE.md`.

---

### Step 4 -- Interview the human

Present a structured summary of what the research found, then ask only the
questions that cannot be answered from code. Group questions logically. Ask
everything in one round -- do not drip questions one at a time.

Format the summary and questions like this:

> *"Here is what I found in the codebase:*
>
> - *`src/api/widgets/index.<ext>` -- existing endpoint of the same type; likely
>   the structural model for the new file*
> - *`sessions` table exists (`migrations/0014_sessions.sql`); relevant fields:
>   `token`, `user_id`, `expires_at`, `revoked_at`*
> - *No existing rate-limiting pattern found in the codebase*
>
> *Before I draft the spec, I need answers to the following:*
>
> 1. *Should the new endpoint reuse the `sessions` table, or does it need its own
>    token type?*
> 2. *Is rate limiting required? If so, what is the threshold?*
> 3. *Which HTTP methods should be accepted?*"*

Do not ask about things already clear from the code or the brain dump. If you
inferred something from the research, state it as an assumption for the human to
confirm or correct -- do not ask an open question about it.

---

### Step 5 -- Draft the spec

Use `.claude/specs/spec-template/spec-template.md` as the structure. Fill every section
that is relevant to this spec. Omit sections that do not apply -- do not leave
empty placeholder sections in the draft.

Key rules for the draft:

- **Background** -- populate with real file paths and line references from the
  research. The human should not need to add these.
- **Context Files** -- list `Domains:` based on which `.claude/knowledge/<domain>/`
  folders (per `DOMAIN-KNOWLEDGE.md`'s naming convention) are relevant to this
  spec. Use `Domains: none` if no existing folder applies.
- **Required Context** -- populate from everything captured in Step 3's
  "Capture external references" sub-step. Omit the section entirely (not an
  empty table) if nothing was captured, per `spec-template.md`'s own
  omission rule.
- **Assumptions** -- pre-populate with things inferred from code, each flagged
  explicitly so the human can confirm or correct them.
- **Open Questions - Blocking** -- seed with anything still unresolved after the
  interview. Do not invent answers.
- **Requirements** -- numbered, testable, RFC 2119 language (MUST / MUST NOT /
  SHOULD / MAY). Each requirement must be unambiguous enough that two developers
  would implement it the same way.
- **Acceptance Criteria** -- written from a tester's perspective, not a developer's.
  Each item is independently verifiable.
- **Scope** -- be explicit about what is out of scope. Anything the brain dump
  touched but the spec does not cover must appear here.

Save the draft to:
```
.claude/specs/<spec_name>/spec.md
```

Create the folder if it does not exist. Also create:
```
.claude/specs/<spec_name>/tasks/        (empty directory)
.claude/specs/<spec_name>/memory.md     (single entry noting this spec was authored on this date)
.claude/specs/<spec_name>/worklog.md    (header + empty table, see WORKLOG-AUTHORING.md)
```

---

### Step 6 -- Present and confirm

Summarize the draft for the human:

> *"Draft spec saved to `.claude/specs/<spec_name>/spec.md`.*
>
> *Summary:*
> - *Type: `<Feature | Bug Fix | ...>`*
> - *Files to be created or modified: `<list>`*
> - *Blocking open questions: `<count>` (listed in spec)*
> - *Assumptions requiring confirmation: `<count>` (listed in spec)*
>
> *Review the draft and let me know what to adjust. Once you are happy with it,
> set `Status: Open` and we can begin task authoring."*

Do not set `Status: Open` yourself. That is the human's signal that the spec
is ready for implementation.

---

## Authoring a Task File

Read this section when the human asks Claude to write one or more task files
for an existing spec.

### Prerequisites

The spec must already exist and have `Status: Open`. If the spec is not finalized,
return to **Authoring a Spec** above.

### Step 1 -- Read the spec in full

Read `.claude/specs/<spec_name>/spec.md` and `.claude/specs/<spec_name>/memory.md`.
Understand the full scope before writing any task.

### Step 2 -- Research the deliverable files (read-only)

For each file the task will create or modify, read the current state of that file
if it exists. Identify the exact lines where changes will be needed. Note any
patterns in the surrounding code that the task must follow.

If a task requires a new file, find an existing file of the same type to use as
a structural reference. Use `.claude/architecture/project-structure.md` to locate
a suitable example if the spec did not name one. Record the reference in the
task's `Context` section.

### Step 3 -- Draft the task file

Use `.claude/specs/spec-template/tasks/task.md` as the structure. Number tasks sequentially
within the spec's `tasks/` folder: `001-`, `002-`, etc.

Key rules for task drafts:

- **Goal** -- one sentence. Specific to this task, not a restatement of the spec goal.
- **Deliverables** -- every file to create or modify, listed explicitly with full
  paths relative to the project root.
- **Steps** -- include real file paths and line references where sequence matters
  or where the location of the change is non-obvious. Do not write generic steps
  like "implement the logic" -- name the file and the location within it.
- **Constraints** -- only rules not already covered by the spec or standards.
  Do not restate the spec.
- **Context** -- always include the structural reference file found in Step 2.

Save to:
```
.claude/specs/<spec_name>/tasks/<nnn>-<short-task-name>.md
```

### Step 4 -- Confirm and hand off

> *"Task file saved to `.claude/specs/<spec_name>/tasks/<nnn>-<short-task-name>.md`.*
>
> *Deliverables: `<list>`*
> *Depends on: `<prior task if any>`*
>
> *Review and let me know if anything needs adjusting before we start implementation."*

---

## What Claude Must Not Do During Authoring

- Do not modify any source file, config, migration, or test
- Do not create branches or make commits (spec and task files are saved directly
  to the working tree for the human to commit when ready)
- Do not set `Status: Open` on the spec -- that is the human's confirmation
- Do not skip the research phase and ask the human for file paths they should not
  need to provide
- Do not hardcode file extensions or directory paths in searches -- derive them
  from `.claude/architecture/project-structure.md`
- Do not write requirements that are ambiguous or that two developers could
  reasonably interpret differently
- Do not leave placeholder sections in the spec -- omit sections that do not apply
