# FEATURE-FLOW-DOCGEN.md — Feature Flow Documentation Generator

Read this file when the human requests a feature flow document at spec close.
See `CLAUDE.md → Closing a Spec` for when this is triggered.

---

## Overview

Produced at spec close when the human explicitly requests it. Saved to:

```
.claude/docs/<spec_name>-flow.md
```

When a new doc is created, add an entry to `.claude/docs/README.md` — create
it if it does not exist.

---

## What to Produce

Read `.claude/specs/<spec_name>/memory.md` and all task memory files for this
spec before writing. The doc must reflect the final delivered state — not the
spec as originally written.

The document must contain the following sections:

**1. Overview**
Two to four sentences describing what the feature does from the user's
perspective and why it exists.

**2. Sequence Diagram**
A Mermaid `sequenceDiagram` showing the full end-to-end flow: what triggers
the feature, which files handle each step, and where the flow terminates.
Use actual file names, not generic labels. Include line references where the
key logic lives.

**3. Files Affected**
A table with columns: `File`, `Change` (Created / Modified / Referenced),
`Purpose`. List every file touched by the spec including assets.

**4. Flow Narrative**
A numbered prose walkthrough of each stage in the sequence diagram. One
paragraph per stage. Include file names, line references, and any non-obvious
decisions made during implementation (sourced from memory).

**5. Assets**
A table of all non-code assets referenced by the feature: designs, copy files,
images, PDFs. Include the relative path for each.

---

## Format Rules

- Use Mermaid for all diagrams — it renders natively in GitHub and GitLab
  without extra tooling
- All file paths must be relative to the project root
- Do not invent line numbers — only include them if they appear in the spec,
  task files, or memory
- If a decision was made during implementation that affects how the flow works,
  note it inline in the narrative rather than omitting it
- Keep the document under 150 lines — if the flow is complex enough to exceed
  this, split the narrative into subsections rather than expanding the diagram
