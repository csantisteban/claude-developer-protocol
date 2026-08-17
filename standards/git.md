## Git

### Commit format
Conventional commits, subject only - no scope in parens:
`<type>: <description>`

| Type       | When to use                                     |
|------------|-------------------------------------------------|
| `feat`     | New feature                                     |
| `fix`      | Type 1 implementation bug                       |
| `chore`    | Maintenance, dependency updates                 |
| `refactor` | Code change with no behaviour change            |
| `docs`     | Documentation only                              |
| `test`     | Adding or updating tests                        |
| `task`     | A task defined in the `.claude/tasks` directory |
| `amend`    | Type 2 spec amendment task                          |
| `research`    | Read-only codebase investigation — no code changed, produces a findings report      |
| `investigate` | Mid-spec triage of an unexpected result — produces a verdict report for the human  |

Subject descriptions should summarize the change plainly enough for a
non-developer to understand what changed - internals belong in the spec's
`## Changelog`, not the commit subject.

### Footer
End the commit body with a footer identifying the spec and/or task this
commit belongs to, replacing the old parenthetical scope:
```
cdp/spec:<spec_number>
cdp/task:<task_number>
```
Comma-delimit if a commit spans multiple specs or tasks of the same kind
(e.g. `cdp/task:003,004`). Omit the footer entirely for commits with no
spec/task scope (e.g. root-level protocol maintenance).

### Branch naming
`cdp/specs/<spec_number>/tasks/<task_number>`, `cdp/specs/<spec_number>/main`,
`cdp/specs/<spec_number>/fix/<short-description>`,
`cdp/specs/<spec_number>/amend/<short-description>`, `cdp/tasks/<task_number>/dev`
- see `CLAUDE.md`'s `### Branch Naming` for the full table and auto-merge rules.

### Rules
- Never commit to the master, development or migrations branches
