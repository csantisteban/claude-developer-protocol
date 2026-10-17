# Claude Developer Protocol (CDP)

A structured protocol for Claude Code to follow when working on software
projects - specs and tasks with clear requirements, consistent git branching,
persistent memory, and session tracking, so work stays traceable across a
project's whole lifecycle.

CDP is a set of Markdown files installed into your project's `.claude/`
folder. Claude Code reads them at the start of every session; there is no
service to run and nothing to configure before you start.

Full documentation: **https://csantisteban.github.io/claude-developer-protocol/**

---

## What it does

- **Specs and tasks** - work is planned as a spec broken into numbered
  tasks, each with a goal, deliverables, and constraints. Claude reads the
  spec, its memory, and the relevant standards before writing any code, and
  drafts a task for your approval when a request needs one.
- **Consistent git workflow** - predictable branch names per spec and task,
  task branches merged into the spec branch automatically, commits traced
  back to their spec or task, and a squash workflow for moving work toward
  a release.
- **Memory that survives sessions and parallel work** - decisions, notes,
  and worklogs are small dated files, one per entry or session, so several
  sessions or subagents can work at once without merge conflicts. Recent
  entries are read in full; older ones as one-line summaries Claude opens
  when relevant.
- **Relevant context only** - project knowledge files declare which paths
  they apply to, so Claude loads what the current task touches instead of
  everything.
- **Session tracking** - pause and resume work, detect changes made since
  Claude's last session, and get reminded about unfinished specs and task
  drafts.
- **Closing a spec** - a reconciliation of everything that touched the spec,
  then a security analysis against the project's standards, signed off by
  you before the spec is closed.
- **Coding and security standards** - conventions for C, C++, C#, Java,
  JavaScript, TypeScript, Node.js, Vue 3, Angular, Python, Go, Rust, Ruby,
  PHP, Swift, Lua, Visual Basic, ColdFusion, SQL, Bash, PowerShell, HTML,
  CSS, XML, YAML, and Docker Compose, plus language-specific security checks
  for 16 of them.
- **Customization without forking** - describe your project in
  `project.md`, override documented protocol behavior in `extensions/`, and
  keep personal instructions in a never-committed `local/` folder.
- **Safe self-updates** - updates verify a checksum, require a clean working
  tree, never commit for you, and never touch your own files.

---

## Requirements

- [Claude Code](https://code.claude.com/docs/en/overview)
- A git repository for your project
- **Linux / macOS:** `bash`, `curl`, `unzip`, `rsync`, and `sha256sum` or
  `shasum`
- **Windows:** PowerShell

---

## Installation

Run the install script from your **project root** (the directory that will contain `.claude/`).

### Linux / macOS

```bash
curl -fsSL https://raw.githubusercontent.com/csantisteban/claude-developer-protocol/main/scripts/install.sh | bash
```

Or download and run manually:

```bash
curl -fsSL https://raw.githubusercontent.com/csantisteban/claude-developer-protocol/main/scripts/install.sh -o cdp_install.sh
bash cdp_install.sh
```

### Windows (PowerShell)

Download the script first, then run it with execution policy bypass:

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/csantisteban/claude-developer-protocol/main/scripts/install.ps1" -OutFile cdp_install.ps1
powershell -ExecutionPolicy Bypass -File .\cdp_install.ps1
```

> **Execution policy error?** Windows blocks unsigned scripts by default.
> The command above bypasses the policy for this run only.
> To allow local scripts permanently for your user account:
> ```powershell
> Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
> ```
> Then run `.\cdp_install.ps1` normally.

---

## What gets installed

The install script creates a `.claude/` directory in your project root containing:

- `CLAUDE.md` - protocol instructions loaded by Claude at session start,
  plus the on-demand procedure files it points to (branching, records,
  knowledge loading, closing a spec, and so on)
- `AGENTS.md` - a short pointer for other AI agents working in the repo
- `standards/` - language and framework coding conventions and security checks
- `architecture/`, `config/`, `extensions/` - project reference docs and
  protocol overrides, each seeded with a starter `overview.md`
- `local/overview.md` - your personal, never-committed instructions
- `design/`, `knowledge/`, `snippets/`, `.triage/`, `assets/` - empty
  directories for project-specific content
- `specs/spec-template/` - template for new specifications
- `tasks/nnn-task-template/`, `tasks/000-sync-memory/` - task templates
- `autoupdate.sh`, `autoupdate.ps1` - protocol self-update scripts
- `manifest.txt` - the list of your own files that updates never touch
- `settings.json` - Claude Code tool permissions, yours to adjust after install
- `version.txt` - the installed CDP version

`project.md` is not shipped - create it to describe your project (see
[Customization](https://csantisteban.github.io/claude-developer-protocol/customization/)).
Memory and worklog folders (`memory/`, `worklog/`) are created the first
time Claude records something.

---

## Getting started

1. Install CDP into your project (above) and commit the new `.claude/`
   folder.
2. Optionally create `.claude/project.md` with your project's overview and
   stack.
3. Start Claude Code in the project and describe what you want to build.
   Claude helps you write a spec, breaks it into tasks, and works through
   them one at a time.

See [Getting Started](https://csantisteban.github.io/claude-developer-protocol/)
for a full walkthrough, and the
[worked example](https://csantisteban.github.io/claude-developer-protocol/examples/example-project/)
for a spec followed from start to close.

---

## Updates

CDP checks for updates automatically at session start (once every 7 days). To update manually:

```bash
bash .claude/autoupdate.sh --force
```

On Windows:

```powershell
powershell -ExecutionPolicy Bypass -File .\.claude\autoupdate.ps1 -Force
```

An update needs a clean working tree: if you have uncommitted changes, it
stops and asks you to commit or stash them first. It never makes a commit
for you, verifies the release checksum before installing, and never touches
your own files (project overview, memory, worklogs, specs, tasks, knowledge,
and the rest of the paths listed in `manifest.txt`).

To pin to the current version and skip updates, create `.pinned-version` in your project root:

```bash
touch .pinned-version
```

See [`CHANGELOG.md`](./CHANGELOG.md) for release history.

---

## Contributing

Pull requests are welcome but not guaranteed to be merged - see
[`CONTRIBUTING.md`](./CONTRIBUTING.md). Forking and adapting CDP to your own
project is the recommended path if it doesn't fit your workflow as-is.

## License

MIT - see [`LICENSE`](./LICENSE). Code generated *by* an AI assistant using
this protocol is governed separately - see
[`GENERATED-CODE-LICENSE`](./GENERATED-CODE-LICENSE).
