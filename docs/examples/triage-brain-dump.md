# A `.triage/` Brain Dump

[`.triage/`](../folder-reference.md) is a drop-zone: leave rough notes there
for Claude to read and fold into a spec, task, or memory file. This page
shows where the fictional [Example Project](example-project.md)'s
tag-filtering spec actually came from.

## The brain dump (`.triage/tag-filtering-idea.md`)

Before `003-tag-filtering` existed as a spec, the developer working on
Lighthouse Notes dropped this file into `.triage/` - informal, unpolished,
exactly as typed:

```markdown
tag filter idea

users keep asking for this. right now tags just sit there on each note,
you cant actually filter by them

thinking: dropdown above the note list, pick a tag, list filters down.
clear button to go back to everything.

NOT doing multi-tag for now, keep it simple. dont need to remember the
filter across reloads either, thats overkill for v1

probably touches NoteList.tsx mostly? tags are already on the Note type
in models/note.ts so no data model work needed i think
```

That's it - no headers, no structure, a couple of half-finished thoughts and
a guess about which file is involved. That's the point: `.triage/` doesn't
expect polish.

## What happens next

The next time spec authoring runs (`SPEC-AUTHORING.md` Step 2, "Read project
context"), Claude reads whatever's sitting in `.triage/` as part of
gathering context. This particular file gets folded straight into the
brain dump for a new spec: the rough "dropdown, clear button, no multi-tag"
notes become `003-tag-filtering`'s `## Scope` section, the guess about
`NoteList.tsx` gets verified against the actual codebase and becomes
`## Background`, and the file itself is deleted once its content has been
folded in - per `.triage/`'s lifecycle (the folder stays, the processed file
doesn't).

See [Example Project](example-project.md) for the spec and task that came
out of this note.
