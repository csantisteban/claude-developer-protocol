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
6. Read root memory (`.claude/memory/`) for project-level context, tiered -
   the 10 newest entries in full plus a headline list of the rest (see
   `RECORDS.md` -> **Reading Records**)
7. Read every live entry in `.claude/specs/<spec_name>/memory/` in full for
   context from previous tasks in this spec (see `RECORDS.md`)
8. Read the task file from `.claude/specs/<spec_name>/tasks/<task_name>.md`
9. If `.claude/specs/<spec_name>/test-cases/overview.md` exists, read it to
   understand existing coverage and the status of any test case this task
   might affect, then load its test-run notes in
   `.claude/specs/<spec_name>/test-cases/memory/` tiered - the 10 newest
   entries in full plus a headline list of the rest (see `RECORDS.md` ->
   **Test-run notes - tiered**)
10. Read the standards in `.claude/standards/` relevant to the files you will touch
11. Read `.claude/knowledge/app-glossary.md` if it exists - every task may involve
    implementation or code changes
12. Load knowledge by relevance, using `## Context Files` in `spec.md` and this
    task's deliverables - follow `DOMAIN-KNOWLEDGE.md` -> **Loading Knowledge
    at Task Start**: listed domains' overviews and headerless files, files
    whose `applies-to` matches a deliverable, and files named as
    `Knowledge: <domain>/<file>.md` are read in full; every other file is
    listed as a one-line headline. Flag any domain folder not listed in
    `Domains:` to the human as possibly relevant before proceeding
13. Read every file listed in `spec.md`'s `## Required Context` unconditionally -
    not filtered by whether the current task appears related
14. Run `PRIOR-ART-CHECK.md` in full and present its summary
15. Check the `## Changelog` in `spec.md` - if it contains entries newer than the newest
    entry in `.claude/specs/<spec_name>/memory/` (by file name - see `RECORDS.md` ->
    **Newest entry**), flag the delta to the human before
    proceeding. Do not assume prior tasks are still valid against the updated spec.
16. Check `## Open Questions -> Blocking` in `spec.md` - if any unresolved blocking question
    affects the current task, stop and surface it before writing any code. Do not infer
    an answer or work around it.
17. Do not write root memory entries (`.claude/memory/`) unless the task explicitly instructs it
18. If anything is ambiguous - **stop and ask**, do not assume
