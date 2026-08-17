# Test Cases

`test-cases/` is an optional, per-spec verification suite - a consistent
place to define what "verified" actually means beyond a spec's own
Acceptance Criteria, track per-test status across sessions, keep test data
separate from real code, and log test-execution history for later
regression runs. It's genuinely optional: nothing about CDP requires it, and
this repo's own history proves it - none of its closed specs have needed one
so far. Use it when a spec's behavior is concrete enough to be worth
verifying the same way twice.

A one-off task can have the same thing at `tasks/<task-name>/test-cases/` -
identical shape, created only when that specific task explicitly warrants
its own verification suite (most don't).

## File shape

| File | Purpose |
|---|---|
| `test-cases/overview.md` | What the suite verifies, an execution table, environment/fixture notes |
| `test-cases/NNN-<test-name>.md` | One file per test case |
| `test-cases/memory.md` | Newest-first log of test-execution sessions |
| `test-cases/fixtures/` | Test data, kept separate from real code |

### `overview.md`

- A 1-3 sentence summary of what the suite verifies.
- An execution table: `#`, `File`, `Verifies`, `Method`, `Status`.
- A "Running the automated tests" section - included only if an automated
  runner actually exists for the suite; omitted entirely otherwise.
- `Environment` - env vars or credentials the suite needs, and where they
  live (see Predictability below).
- `Fixtures` - a table of what's in `fixtures/` and what each file represents.
- Optional `Notes` (free-form context, quirks, history worth stating) and
  `Restrictions` (a scope fence - what must NOT be touched while writing or
  fixing a test in this suite) sections, each omitted if there's nothing to add.

### Individual test case (`NNN-<test-name>.md`)

- `Verifies` - free text: one or more requirements, one or more tasks, or a
  plain description of the behavior covered. There's no fixed cardinality
  between Acceptance Criteria and test cases - write as many or as few as
  the behavior actually needs.
- `Requires` - preconditions (migrations deployed, a prior test already passed, etc.).
- `Status` - one of `Not run`, `In progress`, `Passed - YYYY-MM-DD`, `Failed - YYYY-MM-DD`.
- `Trigger` - what kicks the test off: an HTTP call, a script, a manual
  action, or "none - query state directly."
- Numbered `Steps`, each with a `Method` (SQL / HTTP / Manual / etc.), the
  exact `Detail` (query, request, or instructions), and the exact `Expected` result.

## Keeping it predictable

A few conventions exist specifically so a test case gives the same answer
every time it's run, not just the first time:

- **Fixtures capture exact input data**, so a test never depends on
  whatever happens to already exist. Two naming patterns: `<purpose>.<ext>`
  for a static fixture used as-is, `<purpose>_template.<ext>` for one with
  `{{placeholder}}` tokens substituted at run time.
- **No real PII, phone numbers, or email addresses in fixtures** - use
  placeholders. Fixtures are committed; production-shaped fake data is fine,
  real production data is not.
- **Credentials never live in `fixtures/`** - they stay in the project's own
  gitignored secrets location (e.g. `.claude/.env`), referenced by
  `overview.md`'s `Environment` section, not embedded anywhere in the test
  files themselves.
- **`Requires` states exact preconditions**, so a test case can be re-run
  from a known state instead of depending on whatever the last run happened
  to leave behind.
- **`Method` and `Expected` are written down ahead of time** - a test case
  states what should happen before it's ever run, not after.

## When a suite needs automation

An automated runner is optional, used only when a suite actually benefits
from it - not scaffolded by default. When one exists, the convention is:

- **One script per test case**, not one large script covering every case.
- Shared setup, teardown, or fixture-loading logic **may** be pulled into a
  common helper script to avoid duplicating it across test-case scripts.
- Exactly one orchestrator script, named `run-tests.js`, discovers and runs
  the independent per-test-case scripts and reports pass/fail per case. The
  orchestrator itself contains no test logic of its own - it only finds and
  runs the individual scripts.

## When a test case fails

- The test case's `Status` becomes `Failed - YYYY-MM-DD`, updated in both
  its own file and its row in `overview.md`'s execution table.
- A session entry goes into `test-cases/memory.md` documenting the failure.
- A matching entry goes into the spec's own `memory.md`, so the failure is
  visible without anyone needing to open `test-cases/` at all.
- A `fix/<spec-name>/<short-description>` task gets drafted and presented -
  never applied silently. `Status` stays `Failed` until that fix lands and
  the test is re-run.

## Worked example

Extending [Example Project](examples/example-project.md)'s Lighthouse Notes
scenario: after `003-tag-filtering` shipped, a test case might look like this.

**`test-cases/overview.md` (trimmed)**

```markdown
## Execution

| # | File | Verifies | Method | Status |
|---|------|----------|--------|--------|
| 001 | `001-filter-by-tag.md` | Requirements 1-3 (dropdown, filtering, clear) | Manual | Passed - 2026-03-02 |
```

**`test-cases/001-filter-by-tag.md`**

```markdown
# Test Case 001: Filter notes by tag

**Verifies:** Requirements 1-3 - dropdown appears, filtering works, clear restores the list
**Requires:** At least two notes exist, each with a different tag
**Status:** Passed - 2026-03-02

## Trigger

Manual - open the note list view in a browser

## Steps

1. Open the note list with notes tagged `work` and `personal` present.
   - Method: Manual
   - Detail: Select `work` from the tag dropdown above the list.
   - Expected: Only notes tagged `work` remain visible.
2. Clear the filter.
   - Method: Manual
   - Detail: Click "Clear filter."
   - Expected: All notes are visible again, regardless of tag.
```

No automation was warranted here - a two-step manual check was enough to
confirm the feature worked, logged once in `test-cases/memory.md` and left
at `Passed`.
