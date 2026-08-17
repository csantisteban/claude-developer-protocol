# CLOSING-SPEC.md — Spec Close Procedure

Read this file when the human instructs you to close a spec.
See `CLAUDE.md → Closing a Spec` for the entry-point steps.

---

## Overview

Before a spec can be marked `Closed`, Claude reconciles everything that
touched it - formal tasks, amendments, one-off fixes, and any direct edits -
so the security analysis and final summary reflect the complete picture.

---

## Pre-Close Reconciliation

Before closing a spec, Claude must build a complete picture of everything that
touched it — not just formal spec tasks. Work frequently arrives via handoff
reviews, one-off FIXME tasks, amendment branches, and Claude Code sessions that
bypass normal branch and memory conventions.

Run this reconciliation before the security analysis. Do not skip it even if
the spec appears clean.

---

### Step 1 — Find all branches that touched this spec

```bash
git log --all --oneline | grep -i "<spec_name>"
```

Also check amendment and fix patterns:

```bash
git branch -a | grep -E "cdp/specs/<spec_number>/(amend|fix)/"
```

List every branch found. For each one that is not yet merged into the current
branch, note it — these are candidates for unincorporated work.

---

### Step 2 — Find related one-off tasks

```bash
grep -rn "<spec_name>" .claude/tasks/*/memory.md 2>/dev/null
grep -rn "<spec_name>" .claude/tasks/*/task.md 2>/dev/null
```

One-off FIXME and handoff tasks that were spun off mid-spec write their memory
to `.claude/tasks/*/memory.md`, not to the spec memory. Any findings here must
be merged into `.claude/specs/<spec_name>/memory.md` before close.

---

### Step 3 — Check for unresolved inline work items

```bash
grep -rn "CLAUDE: TODO:\|CLAUDE: FIXME:" <spec_deliverable_paths>
```

Replace `<spec_deliverable_paths>` with the files listed in the spec's
deliverables. Any hit here means work was left incomplete. Surface each one to
the human before proceeding — do not silently skip them.

---

### Step 4 — Identify Claude Code or direct edits

Ask the human explicitly:

> *"Before I close this spec — were any deliverable files modified directly,
> in Claude Code, or outside a formal task branch? If so, point me to the
> commit range and I'll run a handoff review before continuing."*

If the human confirms out-of-band changes, run the **Reviewing Human-Made
Changes** procedure in `HUMAN-HANDOFF.md` against that commit range before
proceeding. This ensures those changes are reflected in memory and knowledge
files and are included in the security analysis file list.

---

### Step 5 - Reconcile `session.md`

```bash
test -f .claude/specs/<spec_name>/session.md && echo "found" || echo "none"
```

If `.claude/specs/<spec_name>/session.md` exists, review its `Where we were`,
`Next action`, and `Open threads` fields. Fold anything not already captured
into `.claude/specs/<spec_name>/memory.md` before continuing - `## Closing a
Spec` deletes this file once the spec status is set to `Closed`.

---

### Step 6 — Consolidate and confirm

If `.claude/specs/<spec_name>/test-cases/overview.md` exists, check its
execution table: every row must be `Passed - YYYY-MM-DD`. If any row is not
`Passed`, flag it explicitly to the human as a deferred/known gap before
proceeding - do not close the spec with an unflagged non-`Passed` row.

Present a reconciliation summary to the human:

> *"Here is everything I found that contributed to `<spec_name>`:*
>
> **Formal spec tasks:**
> - `cdp/specs/<n>/tasks/001` — merged
> - `cdp/specs/<n>/tasks/002` — merged
>
> **Amendments:**
> - `cdp/specs/<n>/amend/email-copy-change` — merged
>
> **Related one-off tasks:**
> - `cdp/tasks/<m>/dev` — memory incorporated
>
> **Handoff / direct edits:**
> - Commit range `a4f93bc..d91e2f0` — handoff review complete
>
> **Test Coverage:**
> - `test-cases/001-example.md` - Passed - 2026-04-19
> - `test-cases/002-edge-case.md` - Failed - 2026-04-18 (deferred - known gap, see memory.md)
>
> **Unresolved TODOs / FIXMEs:** none
>
> *Does this look complete? If anything is missing, point me to it before I
> proceed to security analysis."*

Do not proceed to closing until the human confirms the picture is complete,
including any flagged test-case gaps.
