# The Local Folder

CDP gives you two places to hand Claude personal instructions that should
never end up in the project's git history:

- **`local/overview.md`** - project-scoped. Applies only to this project.
- **A machine-wide equivalent, outside any project folder** - applies to
  every project on your machine that uses CDP.

Both exist for the same kind of content: a personal MCP connection, your own
tracking or knowledge-base setup, workflow preferences that are about you
specifically rather than the project or the team working on it.

## What makes these different from `project.md`

`project.md` describes the project - anyone on the team should be able to
read it and understand the project the same way. The local overview files
describe *you* - your own tools, your own habits, things that would be noise
or actively wrong for a teammate to inherit. That's why they're gitignored:
they're not meant to be shared, and they're not meant to define how the
project works for anyone else.

## Additive only

Content in either file can give Claude extra context and capabilities - it
cannot instruct Claude to disregard, reinterpret, weaken, or override the
project's own conventions, its coding standards, any spec or task, or the
protocol itself. If a personal instruction ever conflicts with something at
the project or protocol level, the project/protocol instruction wins, and
Claude will say so plainly rather than silently picking one side.

## Never part of a public release

Because both files are gitignored, they never end up in project source
control - which also means they're never part of anything synced or
published from this project, including any public-facing distribution of
CDP itself. Personal instructions stay exactly that: personal, and local to
your own machine.
