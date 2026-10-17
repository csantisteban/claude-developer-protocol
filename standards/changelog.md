# Changelog

## Overview

Standards for writing and maintaining a project's `CHANGELOG.md`.

The baseline is **Keep a Changelog**: https://keepachangelog.com

This file defines only the rules that differ from or extend that baseline.
When in doubt, Keep a Changelog is the authority.

---

## Core Principles

Keep a Changelog is built on a small set of principles - follow them in this
order of priority when they conflict:

1. **Changelogs are for humans, not machines.** Write entries a person can
   scan in a few seconds - plain language, not a raw commit log dump.
2. **Every version gets an entry.** Do not skip a release because "nothing
   user-facing changed" - note it as such if truly empty, do not omit the
   version.
3. **The latest version comes first.** Reverse-chronological order, always.
4. **Each version is dated**, in `YYYY-MM-DD` format.
5. **Group changes by type**, using the fixed category headings below - not
   free-form prose paragraphs.
6. **Mention whether a version is a major, minor, or patch release** implicitly
   through Semantic Versioning (`MAJOR.MINOR.PATCH`) - do not invent a
   parallel versioning scheme.

---

## File Structure

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- New feature description here

## [1.2.0] - 2026-08-15

### Added
- Feature A was added

### Fixed
- Bug B was fixed

## [1.1.0] - 2026-07-20

### Changed
- Behavior C was changed
```

---

## Category Headings

Use only these six headings, in this order, and only the ones that have
entries for that version - never an empty heading with no bullets under it:

| Heading | What goes here |
|---|---|
| `Added` | New features |
| `Changed` | Changes to existing functionality |
| `Deprecated` | Features that still work but will be removed in a future release |
| `Removed` | Features that were removed |
| `Fixed` | Bug fixes |
| `Security` | Vulnerability fixes - always call these out separately, never bury them under `Fixed` |

```markdown
# bad - empty heading with nothing under it
### Changed

### Fixed
- Fixed the login timeout bug

# good - only headings with actual entries
### Fixed
- Fixed the login timeout bug
```

---

## The `[Unreleased]` Section

Always keep an `[Unreleased]` section at the very top, above the newest
version. Add entries to it as changes land - do not wait until release time
to reconstruct what changed from git history:

```markdown
## [Unreleased]

### Added
- Work-in-progress feature, not yet released
```

When cutting a release, rename `[Unreleased]` to the new version and date,
then add a fresh empty `[Unreleased]` above it.

---

## Entry Style

- One bullet per distinct change, not one bullet per commit - squash related
  commits into a single entry describing the net effect
- Start each bullet with a past-tense verb or a noun phrase, not an
  imperative: "Fixed the token refresh race condition," not "Fix token
  refresh race condition"
- Reference the affected area when it is not obvious from context: "Fixed a
  crash in the CSV export when a field contained a comma"
- Do not restate the version number or date inside a bullet - the section
  header already carries that
- Do not link to internal issue trackers or ticket IDs unless the project has
  an established convention for it already - keep the changelog readable
  without external context

```markdown
# bad - commit-log style, imperative, restates context already in the header
## [1.2.0] - 2026-08-15
- fix: token refresh bug
- Fix token refresh bug (again)
- Merge branch 'fix/token-refresh'

# good - human-readable, past tense, one entry for the net effect
## [1.2.0] - 2026-08-15

### Fixed
- Fixed a race condition where a token refresh could fire twice concurrently
```

---

## Versioning

Follow Semantic Versioning (`MAJOR.MINOR.PATCH`) for the version numbers used
as section headers:

- `MAJOR` - incompatible/breaking changes
- `MINOR` - backwards-compatible new functionality
- `PATCH` - backwards-compatible bug fixes

Link each version heading to a diff or tag comparison if the project's
hosting platform supports it (e.g. `[1.2.0]: https://.../compare/v1.1.0...v1.2.0`
as a reference-style link at the bottom of the file) - do not hardcode this
if the project has no public repository to link against.

---

## What Claude Must Not Do

- Do not generate changelog entries directly from raw commit messages or
  `git log` output without rewriting them into human-readable form
- Do not use an empty category heading with no bullets under it
- Do not skip the `[Unreleased]` section - it must always be present, even
  if currently empty
- Do not bury a security fix under `Fixed` - it always gets its own
  `Security` heading
- Do not invent a versioning scheme other than Semantic Versioning without
  the project already having established one
