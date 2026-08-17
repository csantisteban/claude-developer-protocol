# Example Project

A worked example, using a fictional project, showing a spec, a task, and a
worklog entry the way CDP actually produces them. Nothing here is a real
product or a real company - it's a small note-taking app called
**Lighthouse Notes**, invented purely to give these conventions something
concrete to look at.

## The scenario

Lighthouse Notes lets users write short notes and tag them. A user asked for
a way to filter their notes by tag from the main list view - currently tags
are shown on each note, but there's no way to filter by one. This is a
small, contained feature, so it becomes a single-task spec.

## The spec (`specs/003-tag-filtering/spec.md`, trimmed)

```markdown
# Spec: Tag-Based Note Filtering

> **Spec Name:** tag-filtering
> **Type:** Feature
> **Status:** Open
> **Author:** Jordan Lee
> **Last Updated:** 2026-03-02

---

## Goal

Let a user filter their note list down to notes carrying a specific tag,
from the main list view, without leaving the page.

---

## Background

- `src/views/NoteList.tsx` renders the full, unfiltered note list today.
- Tags already exist on each note (`tag: string[]` on the `Note` type in
  `src/models/note.ts`) and are displayed as small labels per note - there's
  just no interaction with them yet.

---

## Scope

### In Scope
- A tag filter control above the note list
- Filtering the visible list client-side by the selected tag
- Clearing the filter back to "all notes"

### Out of Scope
- Multi-tag (AND/OR) filtering - single tag only, for now
- Persisting the selected filter across page reloads

---

## Requirements

| # | Requirement |
|---|-------------|
| 1 | A dropdown listing every tag currently in use MUST appear above the note list in `NoteList.tsx` |
| 2 | Selecting a tag MUST filter the visible notes to only those carrying that tag |
| 3 | A visible "Clear filter" control MUST restore the full, unfiltered list |
| 4 | The tag list in the dropdown MUST be derived from the notes currently loaded, not hardcoded |

---

## Acceptance Criteria

- [ ] Selecting a tag from the dropdown shows only notes carrying that tag.
- [ ] "Clear filter" restores every note to the list.
- [ ] A tag with zero notes never appears in the dropdown.
```

## The task (`specs/003-tag-filtering/tasks/001-add-tag-filter-control.md`, trimmed)

```markdown
# Task: 001-add-tag-filter-control

> **Type:** Implementation
> **Author:** Claude
> **Last Updated:** 2026-03-02

---

## Goal

Add the tag filter dropdown and filtering logic to `NoteList.tsx`.

---

## Deliverables

- Modify: `src/views/NoteList.tsx`

---

## Steps

1. Derive the set of in-use tags from the currently loaded `notes` array.
2. Add a `<select>` control above the list, populated from that derived set,
   plus a "Clear filter" option.
3. Filter the rendered list to notes containing the selected tag; render the
   full list when no filter is selected.

---

## Constraints

- Client-side filtering only - no new API call for this task.
- Do not change the `Note` model or how tags are stored.
```

## The worklog entry

Once the task above was complete, a small follow-up came up mid-spec: the
dropdown's default label read "Select..." instead of something clearer. It
was a one-line change with no design decision involved, so it was logged
rather than turned into a second task:

```markdown
| Date | Branch | Action | Outcome | Follow-up |
|------|--------|--------|---------|-----------|
| 2026-03-02 | cdp/specs/003/tasks/001 | Changed the tag filter's default option label from "Select..." to "All tags" in `src/views/NoteList.tsx` | Matches the "Clear filter" wording used elsewhere in the same control | None |
```

That row lives in `specs/003-tag-filtering/worklog.md`, since the spec was
actively being worked on when the change happened - not the project's root
worklog, which is only used when no spec or task is currently active.

## What this shows

- A spec stays focused - one goal, a short background pointing at the exact
  files involved, requirements specific enough that two developers would
  implement them the same way.
- A task covers only its own slice of that spec - it doesn't restate the
  background or requirements, just the concrete steps.
- Small in-flight adjustments don't need their own task - they get a
  worklog row, scoped to whatever spec or task was active when they happened.

See [A `.triage/` Brain Dump](triage-brain-dump.md) for where this spec's
initial idea actually came from,
[Seeding a Spec from a Ticket via MCP](mcp-ticket-to-spec.md) for an
alternative starting point using an external ticket tracker, and
[Test Cases](../test-cases.md) for how this spec's tag-filtering feature
could have been formally verified.
