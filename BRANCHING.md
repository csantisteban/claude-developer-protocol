# BRANCHING.md - Branch Naming, Safety Check, and Release-Squash Workflow

Read this file before creating any branch for a spec task or one-off task
(Branch Safety Check), when verifying a branch name at task completion, and
when the human asks to move a spec or task into the release/testing
pipeline (Release Squash Workflow).

---

## Branch Naming

All CDP-created branches are `cdp/`-prefixed - this makes them identifiable at
a glance in a repo that also has non-CDP branches. `<spec_number>` /
`<task_number>` are the bare numeric prefix only (e.g. `005`), not the full
`005-prior-art-check` folder name.

| Type | Pattern | When to use |
|---|---|---|
| Spec main | `cdp/specs/<spec_number>/main` | Persistent integration branch for a spec - created from the spec's base branch the first time any task branch is created for that spec |
| Spec task | `cdp/specs/<spec_number>/tasks/<task_number>` | Normal implementation task - branches from `cdp/specs/<spec_number>/main`'s current tip |
| Bug fix | `cdp/specs/<spec_number>/fix/<short-description>` | Spec is correct, implementation was wrong |
| Spec amendment | `cdp/specs/<spec_number>/amend/<short-description>` | Spec changed, implementing the delta |
| One-off task | `cdp/tasks/<task_number>/dev` | Work not tied to a spec |
| Ad-hoc change | `cdp/adhoc/<short-description>` | Quick, known change that still needs its own branch - see `## Ad-Hoc Changes` below |

Spec task, bug-fix, and amendment branches auto-merge into
`cdp/specs/<spec_number>/main` on completion (see `COMPLETING-SPEC-TASK.md`) -
no human confirmation required. One-off task branches (`cdp/tasks/<n>/dev`)
are NOT auto-merged - they keep today's human-gated merge model, since there
is no persistent "main" integration branch for one-off tasks.

---

## Ad-Hoc Changes

For a quick, well-understood change that is otherwise Quick-Action-sized (see
`CLAUDE.md`'s `## Worklog` -> `### Quick Action`) but still needs its own
branch - because it must be squash-merged into a release branch later, or
because the currently checked-out branch is off-limits (e.g. already tagged
for release) - without the full ceremony of a one-off task. No `task.md`, no
`session.md`, no `.last-hash` - there is no task folder to hold them.

Recognized when the human explicitly asks for an ad-hoc branch, or when
Claude proposes one as a lighter-weight alternative to a full one-off task
for a change that is Quick-Action-sized but needs a discardable/squashable
branch.

1. Ask the human for the base branch if it is not already obvious from
   context (e.g. the branch the human just said this work targets)
2. Create `cdp/adhoc/<short-description>` from that base
3. Make the change(s) and commit normally (standard commit format from
   `standards/git.md`) - omit the footer trailer, since there is no
   spec/task number to reference
4. Append one entry to the currently-relevant worklog (root
   `.claude/worklog.md` if no spec/task is active, per the scope rule in
   `CLAUDE.md`'s `## Worklog`) - branch name, what was done, and where it's
   headed
5. When ready, fold it into the release using `## Release Squash Workflow`
   below, unchanged - an ad-hoc branch is a valid source branch for that
   workflow, the same as a spec's or task's own branch

---

## Branch Safety Check

Before creating any branch for a spec task or one-off task, resolve
`<base_branch>` and check for unmerged work already sitting on it.

**Resolve `<base_branch>`:**
- Spec task: read `Base branch` from `.claude/specs/<spec_name>/session.md`.
  If `cdp/specs/<spec_number>/main` does not exist yet, create it from
  `<base_branch>` now, before creating the task branch.
- One-off task: read `Base branch` from `.claude/tasks/<task-name>/session.md`
- If `session.md` does not exist yet, ask the human for the base branch, then
  create `session.md` with `Status: Active` and that `Base branch` value (see
  `SESSION-FILES.md`) before creating any branch

**Spec tasks - silent pre-flight, no interactive prompt.** Task branches
always branch from `cdp/specs/<spec_number>/main`'s current tip and auto-merge
back into it on completion, so under normal operation there is never a
sibling task branch left unmerged. Run the scan anyway as a backstop for
abnormal cases (an abandoned task, parallel work outside the normal flow):

```bash
git branch --no-merged cdp/specs/<spec_number>/main | grep "cdp/specs/<spec_number>/"
```

- **Empty result** - the normal case. Proceed silently, branching from
  `cdp/specs/<spec_number>/main`'s current tip.
- **Anything found** - do not block. Surface a brief warning (e.g. *"Found an
  unmerged branch `<branch>` against `cdp/specs/<n>/main` - may be an
  abandoned task or parallel work. Continuing to branch from
  `cdp/specs/<n>/main`'s current tip; let me know if that branch needs
  attention first."*), then proceed.

**One-off tasks - unchanged, full interactive check:**

```bash
git branch --no-merged <base_branch> | grep "cdp/tasks/<task_number>/"
```

**If the result is empty** - create the branch from `<base_branch>` and update
`session.md`'s `Last branch` to the new branch name.

**If unmerged branches are found** - stop and present them:

> *"Before I branch, I found the following branches not yet merged into
> `<base_branch>`:*
> - *`<branch>`*
>
> *Should I:*
> **(a)** Branch from one of these*
> **(b)** Branch from `<base_branch>` anyway - I understand the merge order*
> **(c)** Stop so you can merge first"*

Do not create the branch until the human responds. If the human picks (a) or
(b), update `session.md`'s `Last branch` to the new branch name once it is
created.

---

## Release Squash Workflow

Used when a spec (which may still be `Open` if large), a one-off task, or an
ad-hoc change is ready to move into the release/testing pipeline - triggered
by "ready for release", independent of task/spec completion status. This is
a separate, interim layer and does NOT replace or alter the existing
whole-protocol `rel/vX.X.X` / `release/vX.X.X` convention - a `cdp/.../release`
branch (or an ad-hoc branch squashed directly) may itself later be folded
into a `rel/vX.X.X` release.

1. Create `cdp/specs/<spec_number>/release` or `cdp/tasks/<task_number>/release`
   from the spec's or task's own `Base branch` (recorded in
   `.claude/specs/<spec_name>/session.md` or `.claude/tasks/<task-name>/session.md`
   - e.g. `master`, or a custom integration branch like `dev/next-release`) -
   **not** from `cdp/specs/<spec_number>/main`'s or `cdp/tasks/<task_number>/dev`'s
   own current tip. Those are the branch being squashed in step 2 - branching
   `release` from either of their tips would make that squash a no-op, since
   `release` and the source branch would start as identical commits. `release`
   must start from a point earlier than the source branch's own commits for
   the squash to actually collapse anything.
2. `git merge --squash` all source commits into the release branch, then commit
   with:
   - A descriptive subject naming the single most significant or memorable
     change in this release - not a generic `release: vX.X.X` label, and not
     git's default `Squashed commit of the following:` template (`git commit
     --no-edit` after a squash produces that template, not a usable message -
     always pass an explicit `-m` instead)
   - A body of `- ` bullet points, one per distinct group of changes, each
     separated by a blank line for readability - group related changes
     together rather than listing one bullet per underlying task or commit
   - The usual footer trailer (`cdp/spec:<n>` / `cdp/task:<n>`)

   Example (abbreviated) from this workflow's own first real use:
   ```
   feat: cdp/ branch naming overhaul with auto-merge and release-squash workflow

   - cdp/-prefixed branch naming (bare numeric IDs) with spec-task auto-merge
     into cdp/specs/<n>/main and a release-squash workflow for moving a
     spec/task into the release pipeline independent of completion status

   - Commit format: plain `type: description` subject, spec/task identity
     moved to a cdp/spec:/cdp/task: footer trailer instead of a parenthetical
     scope; Targeted Search grep updated to match

   - New assets/ folder for operator-dropped reference material, with an
     incrementally-updated glossary.md + index.toml

   cdp/spec:008
   ```
3. Verify the release branch's tree is identical to the source branch's tree
   before asking for confirmation:
   ```bash
   git diff <source_branch> <release_branch>
   ```
   Empty output confirms no file was left out of the squash. If the diff is
   non-empty, do not proceed to step 4 - investigate the discrepancy first.
4. Ask the human to confirm deletion of the source branch(es) ONCE, citing
   the empty diff from step 3 as evidence nothing will be lost - squashing is
   not reversible from the release branch alone, so this confirmation must be
   explicit even though it is no longer asked twice
5. Delete the source branch(es) only after that confirmation
