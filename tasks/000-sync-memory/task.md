# Task

**Name:** 000-sync-memory

## What to Do

Manual changes were made to the project outside of a Claude task.
Read all project files and update `.claude/memory.md` to reflect the current state.


## What to Read
1. Read `.claude/memory.md` to find the commit hash recorded in the last entry
2. Run `git diff <last-recorded-commit> HEAD --name-only` to get the list of changed files
3. Only read the full content of files that appear in that list
4. Do not read any file not returned by step 2
5. If more than 20 files appear in the diff, stop and report the list — do not proceed without explicit instruction

## Acceptance Criteria
- [ ] `.claude/memory.md` reflects the actual current state of the repo
- [ ] Any resolved gaps are removed from the Open Questions section
- [ ] Any new gaps noticed are added to the Open Questions section

### Out of Scope
- Changes to any file other than `.claude/memory.md`