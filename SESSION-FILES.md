# SESSION-FILES.md - Session File Shape, Context-Switch, and Resume

Read this file when creating a new spec or one-off task session, pausing work,
or resuming a paused spec or task.

---

## File Shape

```markdown
# Session - <spec_name or task_name>
**Status:** Active
**Base branch:** dev/v1.2.7
**Last branch:** cdp/specs/012/tasks/003
**Paused:** null
**Paused at:** null

## Where we were
One paragraph - exact file, exact line, what was mid-flight.

## Next action
The single concrete next step - file, line range, operation. Not "continue
implementation".

## Open threads
- Items flagged but not yet raised with the human
- Deferred decisions to revisit when this spec/task resumes
```

---

## Context-Switch Procedure

When the human switches context away from this spec/task before it is finished
(e.g. *"let's pause this and switch to..."*):

1. Update `session.md`:
   - `**Status:**` -> `Paused`
   - `**Paused:**` -> current timestamp
   - `**Paused at:**` -> current branch name
   - Fill in `## Where we were`, `## Next action`, and `## Open threads` with the
     current state
2. Confirm to the human:
   > *"Paused `<spec_name or task_name>` on `<branch>`. Safe to switch context."*

---

## Resume Procedure

Triggered when `session.md` has `Status: Paused` (surfaced by the **Paused Session
Check** at Session Start, or when the human returns to a spec/task directly):

1. Read `session.md`
2. Run the **Sync Check** defined in `CLAUDE.md`'s `## Sync Check` on `.last-hash`
   for this spec/task
3. Checkout `Last branch` if it is not already checked out
4. Update `session.md`: set `**Status:**` to `Active`, clear `**Paused:**` and
   `**Paused at:**`
5. Present a resume summary before doing anything else:
   > *"Resuming `<spec_name or task_name>` on `<branch>`.*
   >
   > *Where we were: <summary>*
   > *Next action: <summary>*
   > *Open threads: <list, or "none">*
   >
   > *Ready to continue - did anything change while I was out?"*
