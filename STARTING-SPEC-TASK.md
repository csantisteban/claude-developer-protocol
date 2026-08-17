# STARTING-SPEC-TASK.md - Before Starting a Spec Task

Read this file at the start of every spec task, before writing any code.

---

Follow these steps in order before writing any code:

1. Read `**Status:**` in `.claude/specs/<spec_name>/spec.md`. If the status is `Hold`
   or `Obsolete`, stop immediately - do not create a branch or read any further files.
   Inform the human:
   > *"`<spec_name>` has status `<Hold|Obsolete>` and cannot be worked on. Change the
   > status to `Open` first."*
2. Check `.claude/specs/<spec_name>/session.md`. If it exists with `Status: Paused`,
   this is a resume - read `SESSION-FILES.md` and run the **Resume Procedure**
   before anything else, then continue with the remaining steps below.
3. Run the **Branch Safety Check** defined in `BRANCHING.md` - do not
   create a branch until this is complete
4. Run the **Sync Check** defined in `CLAUDE.md`'s `## Sync Check` for this spec's
   `.last-hash`
5. Read `DIRECTORY-REFERENCE.md` to know what directories and procedure
   files this project has available
6. Read `.claude/memory.md` for project-level context
7. Read `.claude/specs/<spec_name>/memory.md` for context from previous tasks in this spec
8. Read the task file from `.claude/specs/<spec_name>/tasks/<task_name>.md`
9. If `.claude/specs/<spec_name>/test-cases/overview.md` exists, read it to
   understand existing coverage and the status of any test case this task
   might affect
10. If `.claude/specs/<spec_name>/index.toml` exists, read it and trust it -
    see `INDEX-TOML.md`
11. Read the standards in `.claude/standards/` relevant to the files you will touch
12. Read `.claude/knowledge/app-glossary.md` if it exists - every task may involve
    implementation or code changes
13. Read `## Context Files` in `spec.md`. For each domain listed, read all `.md`
    files in `.claude/knowledge/<domain>/` (read `overview.md` first if present).
    Then run `ls .claude/knowledge/` and compare the folder names against the
    domains listed - if a folder exists that is not listed, flag it to the human
    as possibly relevant before proceeding
14. Read every file listed in `spec.md`'s `## Required Context` unconditionally -
    not filtered by whether the current task appears related
15. Run `PRIOR-ART-CHECK.md` in full and present its summary
16. Check the `## Changelog` in `spec.md` - if it contains entries newer than the latest
    entry in `.claude/specs/<spec_name>/memory.md`, flag the delta to the human before
    proceeding. Do not assume prior tasks are still valid against the updated spec.
17. Check `## Open Questions -> Blocking` in `spec.md` - if any unresolved blocking question
    affects the current task, stop and surface it before writing any code. Do not infer
    an answer or work around it.
18. Do not write to `.claude/memory.md` unless the task explicitly instructs it
19. If anything is ambiguous - **stop and ask**, do not assume
