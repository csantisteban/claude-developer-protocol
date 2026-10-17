# Task

**Name:** 000-sync-memory

## What to Do

Manual changes were made to the project outside of a Claude task.
Read the changed project files and record the current state as a new root
memory entry in `.claude/memory/` (see `RECORDS.md`).


## What to Read
1. Take the `commit:` field of the newest live entry in `.claude/memory/`
   that has one (newest by file name - see `RECORDS.md` -> **Newest
   entry**). If no entry has a `commit:` yet, use the last commit hash
   recorded in the legacy `memory.md`
2. Run `git diff <last-recorded-commit> HEAD --name-only` to get the list of changed files
3. Only read the full content of files that appear in that list
4. Do not read any file not returned by step 2
5. If more than 20 files appear in the diff, stop and report the list — do not proceed without explicit instruction

## Acceptance Criteria
- [ ] A new entry in `.claude/memory/` reflects the actual current state of
      the repo, with `commit:` set to the current `HEAD`
- [ ] Entries whose content is now wrong or resolved are named in the new
      entry's `supersedes:` - existing entries are never edited
- [ ] Any new gaps noticed are recorded in the new entry

### Out of Scope
- Changes to any file other than the new entry in `.claude/memory/`