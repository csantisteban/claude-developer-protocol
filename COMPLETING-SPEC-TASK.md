# COMPLETING-SPEC-TASK.md - After Completing a Spec Task

Read this file after completing a spec task, before committing.

---

1. Append a brief summary to `.claude/specs/<spec_name>/memory.md` including:
   - What was done
   - Any decisions made
   - Anything to remember for the next task in this spec
2. If a human correction during this task revealed a file that should have
   been read but was not, add it to `spec.md`'s `## Required Context`
   immediately, in the same commit as the fix - a `memory.md`-only note is
   not sufficient, since it is narrative and not treated as mandatory
   reading on a future cold session. This applies on `fix/` and `amend/`
   branches working against a spec regardless of whether that spec's
   `Status` is `Closed`.
3. If the task surfaces a decision that affects the project beyond this spec, append it to `.claude/memory.md` as well
4. If the task introduced or changed knowledge about a domain, update the relevant file(s) in `.claude/knowledge/<domain>/` - see **Domain Knowledge** in `CLAUDE.md`
5. If this task changed verifiable behavior: create or update
   `test-cases/NNN-<test-name>.md`, add/update its row in
   `test-cases/overview.md`'s execution table (`Status: Not run` until
   executed), and add fixtures to `test-cases/fixtures/` if needed - no real
   PII, phone numbers, or email addresses (use placeholders), and no
   credentials (those stay in the project's gitignored secrets location, e.g.
   `.claude/.env`). If a test case requires an executable script, write one
   script per test case rather than one script covering every case - MAY
   extract shared setup/teardown/fixture-loading logic into a shared helper
   script to avoid duplication - and maintain a single orchestrator script
   named `run-tests.js` that discovers and runs the independent per-test-case
   scripts and reports pass/fail per case; the orchestrator itself contains
   no test logic. If the environment allows, run the test and append a
   newest-first session entry to `test-cases/memory.md` with the result. If
   the test fails, follow the **Bug Workflow** below instead of completing
   this task normally.
6. Regenerate `.claude/specs/<spec_name>/index.toml` in full - re-scan
   `spec.md`, `memory.md`, and every file in `tasks/`, per the **Full
   Regeneration** rule in `INDEX-TOML.md`. Create it if it does not exist yet.
7. Verify you are on the correct branch before committing - see **Branch Naming** in `BRANCHING.md`
8. Stage all changed files, including memory and knowledge, and commit them in
   the same step as step 9 below - never leave files staged-only between
   steps (see **Clean Working Tree Check** in `CLAUDE.md` for why this matters):
   ```bash
   git add .claude/specs/<spec_name>/spec.md      # only if written in step 2
   git add .claude/specs/<spec_name>/memory.md
   git add .claude/memory.md                      # only if written in step 3
   git add .claude/knowledge/                     # only if written in step 4
   git add .claude/specs/<spec_name>/test-cases/  # only if written in step 5
   git add .claude/specs/<spec_name>/index.toml   # regenerated in step 6
   git add <deliverable files>
   ```
9. Commit the code locally, immediately after staging in step 8
10. Run the **Clean Working Tree Check** defined in `CLAUDE.md`
11. Write the commit hash to `.claude/specs/<spec_name>/.last-hash` - do not stage or commit this file
12. Merge the task branch into `cdp/specs/<spec_number>/main` automatically - no
    human confirmation required (see **Branch Naming** in `BRANCHING.md`):
    ```bash
    git checkout cdp/specs/<spec_number>/main
    git merge --ff-only cdp/specs/<spec_number>/tasks/<task_number>
    git branch -d cdp/specs/<spec_number>/tasks/<task_number>
    ```
    If the merge is not fast-forwardable (`cdp/specs/<spec_number>/main` has
    diverged), use a regular merge instead and re-run the **Clean Working Tree
    Check** after the merge commit.
13. Remind the human:
   > *"Task complete, committed, and merged into `cdp/specs/<spec_number>/main`."*

If the task type is `Amendment`, also do the following before committing:

14. Append a summary to `.claude/specs/<spec_name>/memory.md` stating which requirements
    changed and what the previous behaviour was
15. If the amendment changes something cross-cutting, append it to `.claude/memory.md` as well
16. Review all remaining task files in `.claude/specs/<spec_name>/tasks/` - if any reference
    requirements that were changed, flag them to the human before committing

---

## Bug Workflow

If a test case run during step 5 fails:

1. Update the test case's `Status` to `Failed - YYYY-MM-DD` in both
   `test-cases/overview.md`'s execution table and the individual
   `test-cases/NNN-<test-name>.md` file
2. Append a session entry to `test-cases/memory.md` documenting the failure
3. Append a matching entry to `.claude/specs/<spec_name>/memory.md` so the
   failure is visible without opening `test-cases/`
4. Draft a `cdp/specs/<spec_number>/fix/<short-description>` task per **Branch Naming** in `BRANCHING.md`
   and **Conversational Task Entry** - present it to the human before creating any
   branch or writing any files. The test case's `Status` stays
   `Failed - YYYY-MM-DD` until the fix task lands and the test is re-run.
