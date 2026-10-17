# Test Cases - Spec {nnn}: {Spec Title}

## What this suite verifies

{1-3 sentence summary of the end-to-end behavior this suite covers}

---

## Notes

{Free-form context for this suite - known quirks, historical reasons a test
looks the way it does, anything a human would want to say out loud when
handing this suite to someone else. Omit this section if there's nothing to
add.}

---

## Restrictions

{Scope fence - what Claude must NOT touch or change while writing or fixing a
test in this suite (e.g. "do not modify fixtures/prod-sample.json", "do not
change the auth middleware to make this test pass"). This is a scope fence,
not a retry limiter. MAY be scoped to a single test case by number (e.g.
"test 004 only: ..."). Omit this section if there are no restrictions.}

---

## Execution

| # | File | Verifies | Method | Status |
|---|------|----------|--------|--------|
| 001 | `001-{name}.md` | {free text - requirement(s), task(s), or behavior covered} | {SQL / HTTP / Manual / Automated} | {Not run / In progress / Passed - YYYY-MM-DD / Failed - YYYY-MM-DD} |

---

## Running the automated tests

{Omit this entire section if there is no automated runner. Otherwise: instructions,
e.g. `node run-tests.js` from this directory.}

---

## Environment

{Env vars / credentials needed and where they live - e.g. `.claude/.env`, gitignored.}

---

## Fixtures

| File | Purpose |
|------|---------|
| `fixtures/{name}.json` | {what it represents and how it's used} |
