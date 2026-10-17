# STARTING-ONE-OFF-TASK.md - Before Starting a One-Off Task

Read this file at the start of every one-off task, before writing any code.

---

Follow these steps in order before writing any code:

1. Check `.claude/tasks/<task-name>/session.md`. If it exists with `Status: Paused`,
   this is a resume - read `SESSION-FILES.md` and run the **Resume Procedure**
   before anything else, then continue with the remaining steps below.
2. Run the **Branch Safety Check** defined in `BRANCHING.md`
3. Run the **Sync Check** defined in `CLAUDE.md`'s `## Sync Check` for this task's
   `.last-hash` at `.claude/tasks/<task-name>/.last-hash` - same three-case logic
   as spec tasks (missing, found, orphaned)
4. Read `DIRECTORY-REFERENCE.md` to know what directories and procedure
   files this project has available
5. Do not pre-create a worklog file - this session's file in
   `.claude/tasks/<task-name>/worklog/` is created when the first row is
   logged, and named in `session.md` as `**Worklog file:**` (see `RECORDS.md`)
6. Read root memory (`.claude/memory/`) for project-level context, tiered -
   the 10 newest entries in full plus a headline list of the rest (see
   `RECORDS.md` -> **Reading Records**)
7. List prior one-off tasks' headlines for synthesized learnings, and open any
   entry that looks relevant:
   ```bash
   grep "^summary:" .claude/tasks/*/memory/*.md 2>/dev/null | grep -v "/nnn-task-template/"
   ```
   If the retired `.claude/tasks/memory.md` index still exists, read it too
   (legacy, read-only)
8. Read the task file from `.claude/tasks/<task-name>/task.md`
9. If this task already has memory entries (task was paused and resumed), read every live entry in `.claude/tasks/<task-name>/memory/` in full (see `RECORDS.md`).
   If `.claude/tasks/<task-name>/test-cases/overview.md` exists, read it, then
   load the test-run notes in `.claude/tasks/<task-name>/test-cases/memory/`
   tiered - the 10 newest entries in full plus a headline list of the rest
   (see `RECORDS.md` -> **Test-run notes - tiered**)
10. Read the standards in `.claude/standards/` relevant to the files you will touch
11. Read `.claude/knowledge/app-glossary.md` if it exists - every task may involve
    implementation or code changes
12. Load knowledge by relevance, using `## Context Files` in the task file and
    this task's deliverables - follow `DOMAIN-KNOWLEDGE.md` -> **Loading
    Knowledge at Task Start**: listed domains' overviews and headerless files,
    files whose `applies-to` matches a deliverable, and files named as
    `Knowledge: <domain>/<file>.md` are read in full; every other file is
    listed as a one-line headline. Flag any domain folder not listed in
    `Domains:` to the human as possibly relevant before proceeding
13. Read every file listed in the task file's `## Required Context`
    unconditionally
14. Run `PRIOR-ART-CHECK.md` in full and present its summary
15. The task file is the full scope - do not infer beyond it
16. If anything is ambiguous - **stop and ask**, do not assume
