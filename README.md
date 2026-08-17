# Claude Developer Protocol (CDP)

A structured protocol for Claude Code to follow when working on software
projects - specs and tasks with clear requirements, consistent git branching,
persistent memory, and session tracking, so work stays traceable across a
project's whole lifecycle.

Full documentation: **https://csantisteban.github.io/claude-developer-protocol/**

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
> The one-liner above bypasses the policy for this run only.
> To allow local scripts permanently for your user account:
> ```powershell
> Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
> ```
> Then run `.\cdp_install.ps1` normally.

---

## What gets installed

The install script creates a `.claude/` directory in your project root containing:

- `CLAUDE.md` - protocol instructions loaded by Claude at session start
- `standards/` - language and framework coding conventions
- `architecture/`, `config/` - project reference docs (overview stubs provided)
- `design/`, `knowledge/`, `snippets/` - empty directories for project-specific content
- `specs/spec-template/` - template for new specifications
- `tasks/nnn-task-template/`, `tasks/000-sync-memory/` - task templates
- `autoupdate.sh` - protocol self-update script

See [Getting Started](https://csantisteban.github.io/claude-developer-protocol/)
for a full walkthrough.

---

## Updates

CDP updates itself automatically at session start (once per 7 days). To update manually:

```bash
bash .claude/autoupdate.sh --force
```

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
