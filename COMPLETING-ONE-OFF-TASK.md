# COMPLETING-ONE-OFF-TASK.md - After Completing a One-Off Task

Read this file after completing a one-off task, before committing.

---

1. Write a memory entry in `.claude/tasks/<task-name>/memory/` (see `RECORDS.md`) including:
   - What was done and why
   - Any decisions made during implementation
   - Edge cases or surprises encountered
   - Anything to remember if this task is ever revisited
2. If a human correction during this task revealed a file that should have
   been read but was not, add it to this task's own `## Required Context`
   in `task.md` immediately, in the same commit as the fix - a memory-entry-
   only note is not sufficient, since it is narrative and not treated as
   mandatory reading on a future cold session.
3. **Synthesize** - review the task memory and ask: what from this task is worth
   keeping beyond this task? Apply the following promotion rules:
   - Pattern or decision that affects a domain -> write or update the relevant file(s) in `.claude/knowledge/<domain>/`,
     filling in or refreshing each file's header - `applies-to` from the files
     this task touched, plus `summary` and `tags` (see `DOMAIN-KNOWLEDGE.md`
     -> **File Header**)
   - New or clarified app-specific term -> append to `.claude/knowledge/app-glossary.md`
   - Cross-cutting project decision -> write a memory entry in `.claude/memory/`
   - Long-lived fact every future task needs -> `.claude/knowledge/` or
     `.claude/project.md`, never kept alive in memory - memory entries age
     out of the full read, and there is no "pinned" memory entry (see
     `RECORDS.md` -> **Writing Rules**)
   - Everything else stays in the task's own `memory/` only
4. Make sure the step 1 entry's `summary:` names the task's outcome in one
   line, and its body says what (if anything) was promoted. There is no
   shared task index file to update - the list of completed tasks is
   produced on demand:
   ```bash
   grep "^summary:" .claude/tasks/*/memory/*.md
   ```
5. If this task changed verifiable behavior: create or update
   `.claude/tasks/<task-name>/test-cases/NNN-<test-name>.md`, add/update its
   row in `test-cases/overview.md`'s execution table (`Status: Not run` until
   executed), and add fixtures to `test-cases/fixtures/` if needed - no real
   PII, phone numbers, or email addresses (use placeholders), and no
   credentials. If a test case requires an executable script, write one
   script per test case rather than one script covering every case - MAY
   extract shared setup/teardown/fixture-loading logic into a shared helper
   script to avoid duplication - and maintain a single orchestrator script
   named `run-tests.js` that discovers and runs the independent per-test-case
   scripts and reports pass/fail per case; the orchestrator itself contains
   no test logic. If the environment allows, run the test and write a
   test-run entry in `test-cases/memory/` with the result (see `RECORDS.md`). If
   the test fails, set the test case's `Status` to `Failed - YYYY-MM-DD`, note
   the failure in a memory entry in this task's `memory/`, and stop - do not complete this
   task normally until the human authorizes a follow-up fix. Omit this step
   for pure refactors, doc updates, or other tasks with no verifiable
   behavior.
6. Verify you are on the correct `cdp/tasks/<task_number>/dev` branch before
   committing (see **Branch Naming** in `BRANCHING.md`) - one-off task branches
   are not auto-merged
7. Stage all changed files and commit them in the same step as step 8 below -
   never leave files staged-only between steps (see **Clean Working Tree
   Check** in `CLAUDE.md` for why this matters):
   ```bash
   git add .claude/tasks/<task-name>/task.md      # only if written in step 2
   git add .claude/tasks/<task-name>/memory/
   git add .claude/tasks/<task-name>/worklog/     # only if this session logged rows
   git add .claude/memory/                        # only if written in step 3
   git add .claude/knowledge/                     # only if written in step 3
   git add .claude/project.md                     # only if written in step 3
   git add .claude/tasks/<task-name>/test-cases/  # only if written in step 5
   git add <deliverable files>
   ```
8. Commit the code locally, immediately after staging in step 7
9. Run the **Clean Working Tree Check** defined in `CLAUDE.md`
10. Write the commit hash to `.claude/tasks/<task-name>/.last-hash` - do not stage or commit this file
11. Delete `.claude/tasks/<task-name>/session.md`
12. Remind the human:
    > *"Task complete and committed on `<branch>`. This branch has not been
    > merged yet - merge it before starting related work if you want it to
    > build on this."*
