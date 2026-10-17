# CHANGELOG

<!--
Each entry: a "## [X.Y.Z] - YYYY-MM-DD" heading, followed immediately by ONE
plain-text summary line (no leading "-", no heading marker). That line is
read by scripts/sync-github-release.sh and used as the GitHub sync commit
subject. Then the usual "### Added"/"### Changed"/"### Fixed" subheadings
with bullet detail.
-->

## [1.5.0] - 2026-10-16

First public release of the Claude Developer Protocol.

### Added
- **Specs and tasks** - a spec template with requirements, open questions,
  and numbered tasks; a task template covering implementation, bug fixes,
  refactors, migrations, research, and investigations; and a guided
  spec-authoring flow. Claude
  drafts a task to disk for your approval when a request needs one, and
  lists drafts left over from an earlier session at Session Start.
- **Git workflow** - branch naming per spec and task with a Branch Safety
  Check, automatic merging of task branches into the spec branch, a commit
  footer that traces every commit to its spec or task, a clean-working-tree
  check after every commit, and a release squash that collapses a spec into
  one well-described commit.
- **Parallel-safe records** - memory, worklogs, and test-run notes are
  folders of small dated files (`RECORDS.md`). Every session, parallel
  task, or subagent writes its own files, so concurrent work never
  conflicts on a record. Corrections supersede older entries instead of
  editing them.
- **Context loading by relevance** - the 10 newest memory entries and test
  runs are read in full and older ones as one-line summaries. Knowledge
  files declare which paths they apply to, and Claude loads only those
  matching the current task, plus any the spec names.
- **Session tracking** - per-spec and per-task session files to pause and
  resume work, a sync check that spots changes made since Claude's last
  session, and reminders for specs that are still open.
- **Prior-art check** - before writing code for any task, Claude searches
  memory, knowledge, and earlier work for decisions and code that already
  cover it.
- **Closing a spec** - a reconciliation of every branch, task, and edit
  that touched the spec, followed by a security analysis report you sign
  off on.
- **Standards** - coding conventions for C, C++, C#, Java, JavaScript,
  TypeScript, Node.js, Vue 3, Angular, Python, Go, Rust, Ruby, PHP, Swift,
  Lua, Visual Basic, ColdFusion, SQL, Bash, PowerShell, HTML, CSS, XML,
  YAML, and Docker Compose, with language-specific security checks for 16
  of them. The JavaScript family builds on rule sets maintained by ESLint,
  typescript-eslint, the Vue team, and eslint-plugin-n, with Prettier for
  formatting; every config example is tested against current versions.
- **Test cases** - a per-spec and per-task test suite format with fixtures
  and an execution table, plus an optional project-wide regression suite.
- **Customization** - `project.md` for your project's overview, stack, and
  copyright header; `extensions/` to override documented protocol
  behavior; and `local/overview.md` for personal instructions that are
  never committed.
- **Installation and updates** - install scripts for Linux, macOS, and
  Windows. Updates run at most once every 7 days at session start, verify
  the release checksum, refuse unsafe packages, require a clean working
  tree, never commit for you, and never touch the files listed in
  `manifest.txt`.
- **Documentation** - a documentation site with a getting-started guide,
  glossary, folder reference, and three worked examples.
