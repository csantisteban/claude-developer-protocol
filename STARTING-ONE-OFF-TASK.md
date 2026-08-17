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
5. If `.claude/tasks/<task-name>/worklog.md` does not exist, create it with the
   `# Worklog` header and empty table (see `WORKLOG-AUTHORING.md`)
6. Read `.claude/memory.md` for project-level context
7. Read `.claude/tasks/memory.md` for synthesized learnings from prior tasks
8. Read the task file from `.claude/tasks/<task-name>/task.md`
9. If this task has a pre-existing `memory.md` (task was paused and resumed), read it
10. Read the standards in `.claude/standards/` relevant to the files you will touch
11. Read `.claude/knowledge/app-glossary.md` if it exists - every task may involve
    implementation or code changes
12. Read `## Context Files` in the task file. For each domain listed, read all
    `.md` files in `.claude/knowledge/<domain>/` (read `overview.md` first if
    present). Then run `ls .claude/knowledge/` and compare the folder names
    against the domains listed - if a folder exists that is not listed, flag it
    to the human as possibly relevant before proceeding
13. Read every file listed in the task file's `## Required Context`
    unconditionally
14. Run `PRIOR-ART-CHECK.md` in full and present its summary
15. The task file is the full scope - do not infer beyond it
16. If anything is ambiguous - **stop and ask**, do not assume
