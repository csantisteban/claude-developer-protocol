# CLAUDE-COMMENTS.md - CLAUDE: Comment Syntax and Handling

Read this file when encountering a `CLAUDE:` comment, or when writing a one-off
task from `CLAUDE: TODO:` / `FIXME:` / `RESEARCH:` / `DOCUMENT:` comments.

---

## Comment Types

| Type | Purpose |
|---|---|
| `CLAUDE:` | Context, intent, or a decision the human wants Claude to remember |
| `CLAUDE: TODO:` | Work the human started but needs Claude to finish |
| `CLAUDE: FIXME:` | Something broken or incomplete that Claude needs to correct |
| `CLAUDE: RESEARCH:` | A read-only investigation request. Claude answers it by either replacing the comment with a `CLAUDE:` context note containing the finding, or, for larger findings, recording the finding in the relevant `memory.md` / `knowledge/` file and replacing the comment with a one-line pointer |
| `CLAUDE: DOCUMENT:` | A request for human-facing documentation about the referenced code, scoped to this comment. Triggers the existing `## Documentation` flow (file under `.claude/docs/`, `README.md` entry); once written, the comment is removed or replaced with a `CLAUDE:` pointer note to the doc |
| `CLAUDE: LEARN:` | A verbose explanation left by the human while fixing code. Claude extracts the decision into the appropriate knowledge file during a handoff review, replaces the comment with a one-liner referencing the knowledge file, and removes the `LEARN:` marker. |
| `CLAUDE: HAND-OFF:` / `CLAUDE: CONTINUE:` / `CLAUDE: VERIFY:` | Marks work the human wants Claude to review or continue right now. All three are synonyms for the same hand-off procedure in `HUMAN-HANDOFF.md` - the human's word choice, not a signal for different Claude behavior. |
| `` [spec:<name>/<nnn>] `` / `` [task:<name>/<nnn>] `` | An optional pointer tag inside any `CLAUDE:` comment, linking the comment back to the spec or task that produced it. See `## Spec / Task Pointer Tags` below for syntax and staleness rules. |

`TODO:` and `FIXME:` comments always include enough context for Claude to act
without guessing — what the work is, why it matters, and a spec reference if
one exists.

---

## Syntax by language

```cfml
<!--- CLAUDE: token reuse is intentional here - single-use was rejected, see spec user-auth --->
<!--- CLAUDE: TODO: expiry check not implemented - see spec user-auth req #7 for invalidation rules --->
<!--- CLAUDE: LEARN: Use 410 Gone instead of 404 for browser-called endpoints -
      404 triggers server-level redirects that kick the user from the session.
      Only use 404 for Vue3 or non-browser clients that handle it directly.
      Ask which client type if not clear from the spec.
--->
```
```js
// CLAUDE: this bypass exists because the upstream API doesn't support batch - revisit in Q3
// CLAUDE: TODO: handle 204 with no body - expected behaviour defined in spec user-auth req #7
// CLAUDE: RESEARCH: confirm whether the rate limiter is per-user or per-IP, then replace this comment with the finding
// CLAUDE: HAND-OFF: rewrote the retry logic by hand, please verify it matches spec user-auth req #7
```
```sql
-- CLAUDE: null is valid here, it means the record predates the feature
-- CLAUDE: FIXME: missing index on user_id - causes full scan on large tables
```
```bash
# CLAUDE: intentional fallback - upstream returns 404 on missing keys, not an error
# CLAUDE: TODO: add retry logic for 503 - spec defines max 3 attempts with backoff
# CLAUDE: DOCUMENT: explain this script's rollback steps for the ops runbook
```

---

## Spec / Task Pointer Tags

`[spec:<name>/<nnn>]` and `[task:<name>/<nnn>]` are optional tags usable
inside any `CLAUDE:` comment, linking the comment back to the spec or task
that produced the code. `<name>` is the spec or task folder name, `<nnn>` is
the task number (e.g. `[spec:005-prior-art-check/003]` points to
`.claude/specs/005-prior-art-check/tasks/003-*.md`).

```cfml
<!--- CLAUDE: token reuse is intentional here [spec:user-auth/002] --->
```
```js
// CLAUDE: batching added for the nightly import job [task:import-batching]
```
```sql
-- CLAUDE: null is valid here, predates this column [spec:invoicing/004]
```
```bash
# CLAUDE: retry logic matches the backoff table [spec:user-auth/007]
```

**Use sparingly** - the same bar as `CLAUDE: LEARN:`. A pointer tag is for
code where knowing *which spec or task* produced it materially helps a future
reader; it is not a habit to add to every `CLAUDE:` comment.

**Staleness** - a pointer tag referencing a spec or task that is later
closed, renamed, or superseded is left in place untouched. It becomes
historical, not invalid. Claude MUST NOT remove or rewrite a pointer tag
automatically as a side effect of closing, renaming, or superseding the spec
or task it references.

---

## When Claude encounters a `CLAUDE:` comment

- **During a task** - read it as a constraint or decision that affects this work; never remove or alter it
- **During a handoff review** - treat it as the human's explanation of intent; extract any decisions, patterns, or glossary terms and store them in the appropriate memory or knowledge file
- **`CLAUDE: TODO:` and `CLAUDE: FIXME:`** - these are work items; do not act on them unless the current task or a one-off task explicitly covers them. Never silently skip them - if one falls inside the scope of the current task, complete it and remove the comment. If it is out of scope, leave it untouched.
- **`CLAUDE: RESEARCH:` and `CLAUDE: DOCUMENT:`** - act on them when the work is quick and bounded, per the completion step in the `## Comment Types` table above; if resolving one would be substantial, follow "Writing a one-off task from comments" below instead of resolving it inline
- **`CLAUDE: LEARN:`** - never process during a normal task; only during a handoff review. See `HUMAN-HANDOFF.md` for the full lifecycle.
- **`CLAUDE: HAND-OFF:` / `CLAUDE: CONTINUE:` / `CLAUDE: VERIFY:`** - these trigger a handoff review immediately, the same as a conversational trigger phrase. See `HUMAN-HANDOFF.md` for the full procedure.
- **Never remove a `CLAUDE:` comment** unless the work it describes has been completed as part of the current task - only the human may remove context-only comments

---

## Worklog Tracing for CLAUDE: Comments

Whenever Claude resolves an actionable `CLAUDE:` comment (`TODO`, `FIXME`, `RESEARCH`,
`DOCUMENT`, or `LEARN`) and that resolution is not already a listed deliverable of the
current task - i.e. it happens as a Quick Action, as an incidental side-effect during
other work, or during a `HUMAN-HANDOFF.md` review - append a row to the
appropriate-scope `worklog.md`:

- `Action` = `` Resolved `CLAUDE: <TYPE>:` at `<file>:<line>`: <short description> ``
- `Outcome` = what was done or found
- `Follow-up` = `None`, or remaining work

This is in addition to, not instead of, the type's normal completion step (extract to a
knowledge file for `LEARN`, write to `.claude/docs/` for `DOCUMENT`, etc.). See
`WORKLOG-AUTHORING.md` -> `## Worklog Tracing for CLAUDE: Comments` for the full
worklog format.

Resolving a `CLAUDE:` comment this way is subject to the Escalation rule in `CLAUDE.md`'s
`## Worklog` -> `### Escalation` - if it turns out to require many files or a design
decision, stop and ask before proceeding instead of resolving it as a quick, traced action.

---

## Writing a one-off task from CLAUDE: TODO: / FIXME: / RESEARCH: / DOCUMENT: comments

When the human asks Claude to write a one-off task (or says "pick up where I left off",
"finish what I started", or similar):

1. Scan the relevant files - or the full codebase if no files are specified - for
   `CLAUDE: TODO:`, `CLAUDE: FIXME:`, `CLAUDE: RESEARCH:`, and `CLAUDE: DOCUMENT:` comments:
   ```bash
   grep -rn "CLAUDE: TODO:\|CLAUDE: FIXME:\|CLAUDE: RESEARCH:\|CLAUDE: DOCUMENT:" <path>
   ```
2. Group findings by file and present them to the human before writing anything:
   > *"I found the following items:*
   > - *`src/api/orders/index.aspx:42` - TODO: expiry check*
   > - *`src/api/orders/index.aspx:87` - FIXME: missing index*
   >
   > *Should I write a single task covering all of these, or separate tasks?"*
3. Write the task file(s) per the template in `.claude/tasks/nnn-task-template/task.md` - the `CLAUDE: TODO:`,
   `FIXME:`, `RESEARCH:`, and `DOCUMENT:` comments become the basis for the **Goal**, **Deliverables**, and **Steps**
4. Once a task is complete and the work is done, remove the corresponding `CLAUDE: TODO:`,
   `FIXME:`, `RESEARCH:`, or `DOCUMENT:` comment from the source file
