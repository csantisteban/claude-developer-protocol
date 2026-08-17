# AGENTS.md

This project uses Claude Code, driven by the Claude Developer Protocol. For
any AI agent operating in this repo, the full workflow, session rules, and
conventions are defined in `.claude/CLAUDE.md` - read that file first; this
file is only a pointer to where things live.

## Where to look

- `.claude/knowledge/` - domain summaries and the app glossary, written for
  future agent sessions, read when relevant to the current task
- `.claude/docs/` - human-facing documentation; not read during task
  processing unless a task explicitly says to
- `.claude/snippets/` - reusable code patterns established in this codebase
- `.claude/architecture/` - system structure, folder layout, and (if
  applicable) database schema
- `.claude/standards/` - language and framework coding conventions

Do not modify `.claude/` protocol files directly as deliverables - see
`.claude/CLAUDE.md` for the full rules on what is safe to edit and when.
