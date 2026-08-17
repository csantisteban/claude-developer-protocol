## Architecture Files

This document lists the architecture reference files for this project.
Claude uses this file to understand the system structure before starting any task.

> All paths are relative to the project root unless stated otherwise.

---

### Reference Files

| File | Purpose |
|------|---------|
| `.claude/architecture/project-structure.md` | Project directory listing with the purpose of each folder |
| `.claude/architecture/database.md` | Database type, schema location, naming rules, and migration process |

---

### What Belongs Here

Architecture files describe the system as it currently exists — not as it
should be. Add a file to this directory when a domain is complex enough that
a developer (or Claude) needs a map before touching it.

Common files to include:

| File | When to add it |
|------|----------------|
| `project-structure.md` | Always — every project should have this |
| `database.md` | When the project has a database |
| `api.md` | When the project exposes or consumes APIs |
| `auth.md` | When authentication or session handling is non-trivial |
| `domain-model.md` | When the business domain has complex relationships |
| `integrations.md` | When the project connects to external services |
| `deployment.md` | When the deployment topology affects development decisions |
| `data-flow.md` | When data moves through multiple systems or transforms significantly |

---

### What Claude Must Not Do

- Do not modify architecture files unless the task explicitly instructs it
- Do not make assumptions about system structure if the relevant file is missing —
  stop and ask
- Do not treat architecture files as specifications — they describe what exists,
  not what to build
