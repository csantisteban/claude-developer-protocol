# DIRECTORY-REFERENCE.md - Directory and Procedure File Reference

Read this file at the start of every task - it lists every directory and
on-demand procedure file this protocol uses.

---

The following directories contain all reference material Claude needs.
At the start of every task, read the files relevant to the current task — do not read everything blindly.

> If a directory contains an `overview.md`, always read it before reading any other file in that directory. See `OVERVIEW-AUTHORING.md` for the standard template used when creating a new `overview.md`, and for the rule on keeping its `Contents` table in sync.

| Directory                                        | Purpose                                                                                                           |
|--------------------------------------------------|-------------------------------------------------------------------------------------------------------------------|
| `.claude/project.md`                             | Project overview, stack, and operating notes - read in full at Session Start (`CLAUDE.md`), not on-demand         |
| `.claude/local/overview.md`                      | Developer's personal, project-scoped instructions for Claude - gitignored, operator-owned after first install. Read in full at Session Start (`CLAUDE.md`), not on-demand |
| `.claude/standards/`                             | Language and framework coding conventions                                                                         |
| `.claude/snippets/`                              | Reusable code patterns for this codebase                                                                          |
| `.claude/config/`                                | Configuration files reference                                                                                     |
| `.claude/design/`                                | UI and design guidelines                                                                                          |
| `.claude/architecture/`                          | System structure, folder layout, and database schema                                                              |
| `.claude/.triage/`                               | Global scratch intake - human drops files for Claude to read/process; delete each file once processed, keep the folder |
| `.claude/assets/`                                | Global operator-populated reference material (PDFs, manuals, specs, third-party docs) - source files are never deleted |
| `.claude/assets/glossary.md`                     | Claude-maintained, incrementally updated definitions/facts synthesized from `assets/` files, on demand           |
| `.claude/assets/index.toml`                      | Claude-maintained per-file pointer index for `assets/` - same schema as a spec's `index.toml`, see `INDEX-TOML.md` |
| `.claude/knowledge/app-glossary.md`              | Flat, cross-cutting glossary of app-specific terms - read every task start                                        |
| `.claude/knowledge/<domain>/`                    | Per-domain knowledge folder - read when listed in `## Context Files`                                              |
| `.claude/memory.md`                              | Persistent memory scoped to the project — cross-spec decisions and patterns                                       |
| `.claude/worklog.md`                             | Root-scope worklog - append-only Quick Action and cross-cutting log when no spec/task is active. Created on first use |
| `.claude/worklog-index.md`                       | Pointer index for archived root-worklog entries (Resource/Topic / Date Range / Archive File / Summary)            |
| `.claude/worklog/archive/`                       | Monthly archives of root worklog entries older than 30 days (`YYYY-MM.md`)                                        |
| `.claude/tasks/`                                 | One subdirectory per one-off task                                                                                 |
| `.claude/tasks/<task-name>/task.md`              | The task file                                                                                                     |
| `.claude/tasks/<task-name>/memory.md`            | Persistent memory scoped to this task only                                                                        |
| `.claude/tasks/<task-name>/worklog.md`           | Append-only worklog for this one-off task                                                                         |
| `.claude/tasks/<task-name>/session.md`           | Per-task session state - branch and pause/resume tracking, never committed                                        |
| `.claude/tasks/<task-name>/test-cases/`          | Optional verification suite for this task - same shape as the spec-level test-cases/, created only when warranted |
| `.claude/tasks/<task-name>/assets/`              | Optional task-scoped reference material, human-created on demand - same lifecycle as global `assets/`             |
| `.claude/tasks/memory.md`                        | Synthesized project-level learnings promoted from completed tasks                                                 |
| `.claude/specs/`                                 | One subdirectory per specification                                                                                |
| `.claude/specs/<spec_name>/spec.md`              | The specification document                                                                                        |
| `.claude/specs/<spec_name>/tasks/`               | Task files that implement this specification                                                                      |
| `.claude/specs/<spec_name>/memory.md`            | Persistent memory scoped to this specification                                                                    |
| `.claude/specs/<spec_name>/worklog.md`           | Append-only worklog for this spec                                                                                  |
| `.claude/specs/<spec_name>/session.md`           | Per-spec session state - branch and pause/resume tracking, never committed                                        |
| `.claude/specs/<spec_name>/test-cases/`          | Test suite for this spec - overview.md, memory.md, fixtures/, individual test-case files                          |
| `.claude/specs/<spec_name>/test-cases/fixtures/` | Test data used by this spec's test cases                                                                          |
| `.claude/specs/<spec_name>/assets/`              | Optional spec-scoped reference material, human-created on demand - same lifecycle as global `assets/`             |
| `.claude/docs/`                                  | Human-facing documentation — never read by Claude during task processing                                          |

**Procedure files** — read on demand, not at session start:

| File | Read when |
|---|---|
| `AUTOUPDATE.md` | Session-start autoupdate check and user-initiated update requests |
| `SESSION-FILES.md` | Creating a new spec or task (session.md setup), pausing or resuming a spec or task |
| `WORKLOG-AUTHORING.md` | Quick Action procedure, cross-cutting logging details, or archiving the root worklog |
| `OVERVIEW-AUTHORING.md` | Creating a new `overview.md`, or a folder's existing `overview.md` looks out of date against its contents |
| `DOCUMENTATION.md` | Organizing generated docs into category subfolders, or naming generated doc files |
| `PRIOR-ART-CHECK.md` | Before starting any spec task or one-off task - mandatory, every time |
| `INDEX-TOML.md` | Reading or writing a spec folder's `index.toml`, or an `assets/index.toml` |
| `BRANCHING.md` | Every spec/one-off task start (Branch Safety Check) and completion (branch naming reference); closing a spec (branch patterns); release-squash workflow |
| `STARTING-SPEC-TASK.md` | Every spec task - read before writing any code |
| `COMPLETING-SPEC-TASK.md` | Every spec task - read before committing |
| `STARTING-ONE-OFF-TASK.md` | Every one-off task - read before writing any code |
| `COMPLETING-ONE-OFF-TASK.md` | Every one-off task - read before committing |
| `CLAUDE-COMMENTS.md` | Encountering a `CLAUDE:` comment, or writing tasks from TODO/FIXME/RESEARCH/DOCUMENT comments |
| `CLOSING-SPEC.md` | Closing a spec — pre-close reconciliation steps |
| `SECURITY-ANALYSIS.md` | Closing a spec — security analysis |
| `FEATURE-FLOW-DOCGEN.md` | Closing a spec — human requests a flow document |
| `HUMAN-HANDOFF.md` | Human asks Claude to learn from direct changes |
| `DOMAIN-KNOWLEDGE.md` | Writing or updating `.claude/knowledge/` files |
| `SPEC-AUTHORING.md` | Human asks Claude to help write a spec or task file |

> If a directory does not exist, ignore it unless it is explicitly mentioned that it should be created if missing. A missing directory means that information is not relevant to this project.

> Ignore the directory `.claude/specs/spec-template`

> `test-cases/memory.md` holds test-execution-session detail only (results,
> blockers, fixture/script fixes, IDs/tokens used), newest first. Promote a
> one-line pointer to `.claude/specs/<spec_name>/memory.md` only if a future
> task or spec needs it without opening `test-cases/`, and promote further to
> `.claude/memory.md` only if it affects more than this spec - same promotion
> convention as `## After Completing a Spec Task` step 2.

> `.claude/.triage/` ships pre-created and empty (global scope only). A human
> may also create `.claude/specs/<spec_name>/.triage/` or
> `.claude/tasks/<task-name>/.triage/` for spec- or task-scoped intake - these
> are never scaffolded automatically, only created on demand. In every case,
> Claude reads and processes `.triage/` contents when directed to (most
> commonly during `SPEC-AUTHORING.md`), deletes each file once its content has
> been folded into a spec, task, or memory file, and never deletes the
> `.triage/` folder itself.

> `.claude/assets/` ships pre-created and empty (global scope only), same as
> `.claude/.triage/`. A human may also create `.claude/specs/<spec_name>/assets/`
> or `.claude/tasks/<task-name>/assets/` for spec- or task-scoped reference
> material - these are never scaffolded automatically, only created on demand.
> Unlike `.triage/`, source files placed in any `assets/` folder are reference
> material and are NEVER deleted after use. When Claude reads an asset file to
> find specific information, it appends or updates that file's entry in the
> same folder's `glossary.md` and `index.toml` - both are updated incrementally,
> on demand, not regenerated in full on a fixed cadence (unlike a spec's
> `index.toml` - see `INDEX-TOML.md`).

> `~/.claude/cdp/local/overview.md` is the machine-wide counterpart to
> `.claude/local/overview.md` - it lives in the developer's home directory,
> outside this (or any) project's `.claude/` entirely, and is read at the
> same Session Start point. See `CLAUDE.md` -> `## Personal Developer
> Overview`.
