# HUMAN-HANDOFF.md — Reviewing Human-Made Changes

Read this file when the human asks Claude to learn from changes made directly
outside a formal spec or task. Also read this file during any handoff review
triggered from `CLOSING-SPEC.md → Step 4`.

---

## Overview

Used when the human has made changes directly — without a spec or task — and
wants Claude to learn from them. This is a retroactive handoff, not an
implementation task. Hand-off is meant to work like ongoing pairing: the
human does not need to supply git coordinates for the everyday case - Claude
inspects the working tree itself.

**How to trigger (everyday case):**
- A conversational trigger phrase: "check my changes", "verify my update",
  "continue with my changes", "continue with my code", "continue with my
  update", "check my changes validity", or similar recognizable phrasing. If
  the phrasing itself is ambiguous given the current context, ask - do not
  assume what the human wants reviewed
- A `CLAUDE: HAND-OFF:`, `CLAUDE: CONTINUE:`, or `CLAUDE: VERIFY:` comment
  left in a changed file - all three are synonyms for the same procedure,
  the human's word choice rather than a signal for different behavior

See `## Trigger Types` below for how Claude determines what to diff, and
`## Explicit Commit-Range Review` for the narrow, separate path used only
when a hash/range/branch is explicitly supplied.

---

## Trigger Types

Once a general trigger fires, Claude determines the diff itself - the human
never needs to supply git coordinates for this path:

| Working tree state | Step 1 | Step 7 |
|---|---|---|
| Uncommitted changes present | `git diff` / `git diff --name-only` (working tree vs `HEAD`) - any number of files, not limited to one | One normal commit combining the human's file change(s) with Claude's memory/knowledge/worklog updates |
| Working tree clean (already committed) | `git diff HEAD~1 HEAD` (auto-derived, no range supplied) | Standalone `handoff: learn from human changes in <from>..<to>` commit (plus `cdp/spec:<n>` footer if spec-scoped), memory/knowledge files only |

Steps 2-5 are shared - read the changed file(s), scan for `CLAUDE:` comments, run
the `CLAUDE: LEARN:` lifecycle, and determine memory/knowledge updates - unchanged
regardless of which row applies.

**If no `CLAUDE:` instruction is found** among the changed files for either row,
ask the human what they want reviewed or continued - do not guess at intent from
the diff alone.

**Escalation for the uncommitted-changes row:** if the uncommitted diff spans
more than the Quick Action threshold (`CLAUDE.md` -> `## Conversational Task
Entry` -> Quick Action: 1-3 files, one bounded action), apply the Escalation rule
(`CLAUDE.md` -> `## Worklog` -> `### Escalation`) - ask whether to (a) bundle
everything into one commit anyway, or (b) have the human commit first so the
already-committed row applies instead.

---

## Explicit Commit-Range Review

A separate, narrow path - not a conversational trigger a human reaches for
casually. Used only when a commit hash, range, or branch is explicitly
supplied:
- The human directly names one ("review commits a1b2c3..d4e5f6")
- Another protocol procedure calls for it - e.g. `CLOSING-SPEC.md` Step 4's
  Pre-Close Reconciliation, which asks the human to point at a commit range
  covering out-of-band changes before a spec closes

Mechanics are otherwise identical to the already-committed row above:
`git diff <from> <to> --name-only` / `git diff <from> <to>`, shared Steps 2-5,
standalone `handoff: learn from human changes in <from>..<to>` commit
(memory/knowledge files only).

---

## Steps

1. Determine which case applies and run the matching diff (see `## Trigger
   Types` and `## Explicit Commit-Range Review` above):
   - **Uncommitted changes present:**
     ```bash
     git diff --name-only                      # files changed
     git diff                                  # full diff, working tree vs HEAD
     ```
   - **Working tree clean (already committed):**
     ```bash
     git diff HEAD~1 HEAD --name-only
     git diff HEAD~1 HEAD
     ```
   - **Explicit commit-range review** (hash/range/branch was supplied):
     ```bash
     git diff <from> <to> --name-only
     git diff <from> <to>
     ```
2. Read each changed file in full — the diff shows what moved, the file shows the context
3. Scan all changed files for `CLAUDE:` comments — these are the human's direct
   explanations of intent and take priority over inferred meaning. This includes
   `CLAUDE: HAND-OFF:` / `CLAUDE: CONTINUE:` / `CLAUDE: VERIFY:` markers, which
   are what triggered this review in the first place if one is present
4. For each `CLAUDE: LEARN:` comment found, run the **CLAUDE: LEARN: Lifecycle**
   procedure below
5. For each changed file, determine:
   - Does this establish or change a pattern in a domain? → write or update `.claude/knowledge/<domain>.md`
   - Does this introduce or clarify an app-specific term? → append to `.claude/knowledge/app-glossary.md`
   - Does this affect an open spec? → append to `.claude/specs/<spec_name>/memory.md`
   - Is this a cross-cutting project decision? → append to `.claude/memory.md`
   - **If no `CLAUDE:` instruction was found anywhere in the diff**, stop here and
     ask the human what they want reviewed or continued, rather than guessing
6. For the uncommitted-changes case only, append a row to the
   appropriate-scope `worklog.md` (see `WORKLOG-AUTHORING.md` for scope selection):
   - `Action` = `` Learned from uncommitted change(s) to `<file(s)>`: <short description> ``
   - `Outcome` = what was updated (memory/knowledge files)
   - `Follow-up` = `None`, or remaining work
7. Commit the memory and knowledge files written in steps 4-5 (and the
   worklog row from step 6, for the uncommitted-changes case). The form of
   the commit depends on the case (see `## Trigger Types` /
   `## Explicit Commit-Range Review` above):
   - **Already committed, or explicit commit-range review:** stage and commit
     only the memory/knowledge files, as a standalone commit:
     ```bash
     git add .claude/memory.md
     git add .claude/knowledge/
     git add .claude/specs/<spec_name>/memory.md   # only if an open spec is affected
     git commit -m "handoff: learn from human changes in <from>..<to>

     cdp/spec:<n>"
     # omit the "cdp/spec:<n>" footer line entirely if this is root-scoped (no open spec affected)
     ```
   - **Uncommitted changes:** stage and commit the human's file change(s)
     together with Claude's memory/knowledge/worklog updates from steps 4-6
     in **one** commit, using a normal conventional-commit message describing the
     human's change - not the `handoff:` prefix, which remains reserved for the
     already-committed and explicit-range forms above:
     ```bash
     git add <file(s)>
     git add .claude/memory.md
     git add .claude/knowledge/
     git add .claude/specs/<spec_name>/worklog.md   # or .claude/worklog.md / task worklog
     git commit -m "<type>: <description of the human's change>

     cdp/spec:<n>"
     # omit the "cdp/spec:<n>" footer line entirely if this is root-scoped
     ```
   - Run the **Clean Working Tree Check** defined in `CLAUDE.md` before
     proceeding to step 8 - applies to all three cases
8. Report back to the human with a brief summary of what was learned and where it was stored

---

## What Claude Must Not Do

- Do not modify any of the changed source files — read only, except for replacing
  `CLAUDE: LEARN:` comments per the lifecycle below
- Do not infer intent beyond what the code and `CLAUDE:` comments make clear — if
  something is ambiguous, ask
- Do not create new specs or tasks unless the human explicitly asks

---

## CLAUDE: LEARN: Lifecycle

When Claude encounters a `CLAUDE: LEARN:` comment during a handoff review:

1. Extract the decision into the appropriate `.claude/knowledge/` file — append to an
   existing domain file if one applies, or create a new one
2. Replace the verbose comment with a one-liner referencing the knowledge file:
   ```cfml
   <!--- CLAUDE: 410 not 404 — browser caller; see knowledge/http-error-codes.md --->
   ```
3. Remove the `LEARN:` marker — the comment is now a standard `CLAUDE:` context comment
   and will not be reprocessed

**Rules:**
- Never extract a `CLAUDE: LEARN:` during a normal task — only during a handoff review
- Never remove the comment without first writing the knowledge file entry
- If the learning touches a domain that already has a knowledge file, append to it rather
  than creating a new one
- If the caller type or other key detail is ambiguous in the comment, ask before writing
  the knowledge entry
