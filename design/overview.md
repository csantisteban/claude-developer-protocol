## Design Files

This document describes the `design/` directory for this project. Claude
uses this file to understand what UI and design guidance is available
before starting any task that touches the frontend or user-facing behavior.

> All paths are relative to the project root unless stated otherwise.

---

### What Belongs Here

`design/` is operator-populated - it ships empty and is filled in as the
project's design system takes shape. Add a file here when there is
concrete design guidance a developer (or Claude) needs before building or
changing UI, rather than leaving it to be inferred from existing screens.

Common files to include:

| File | When to add it |
|------|----------------|
| `style-guide.md` | Color palette, typography, spacing, and other visual tokens |
| `components.md` | Reusable UI component inventory and usage rules |
| `wireframes/` | Screen layouts or flows, as images or linked files |
| `interaction-patterns.md` | Standard behaviors for common UI patterns (forms, modals, navigation) |
| `accessibility.md` | WCAG level, keyboard navigation, and screen reader requirements specific to this project |
| `voice-and-tone.md` | Copy and microcopy conventions |

---

### What Claude Must Not Do

- Do not modify design files unless the task explicitly instructs it
- Do not choose or change colors, fonts, or spacing values unilaterally -
  those are product/design decisions, not Claude's to make (see `CLAUDE.md`'s
  `## Out of Scope for Claude`)
- Do not treat design files as specifications - they describe the design
  system as it currently exists, not what to build for a given feature
- Do not invent design guidance when this directory is empty - stop and ask
  the human rather than assuming visual or interaction details
