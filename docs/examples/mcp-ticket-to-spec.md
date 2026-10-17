# Seeding a Spec from a Ticket via MCP

This is an optional customization pattern, not something CDP ships or
requires. If your team tracks work in an external tracker (Jira, Linear,
GitHub Issues, YouTrack, or anything else with an MCP server available),
you can wire Claude up to pull a ticket's content directly instead of
retyping it as a brain dump.

## The pattern

1. **Configure an MCP server for your tracker** in
   [`local/overview.md`](../local-folder.md) (project-scoped) or its
   machine-wide counterpart, if the same tracker applies across every
   project you work on. This is exactly what that file is for - personal
   tooling and connections, additive only, never committed.
2. **Give Claude the ticket reference** at the start of a session - "this is
   PROJ-142" or similar. Claude uses the configured MCP tool to fetch that
   ticket's title, description, and any relevant comments.
3. **That fetched content becomes the brain dump.** Spec authoring
   (`SPEC-AUTHORING.md` Step 1, "Receive the brain dump") doesn't care where
   the free-form description came from - a ticket pulled over MCP works the
   same way as something typed directly into the conversation, or a file
   read from [`.triage/`](triage-brain-dump.md).

## Applied to Lighthouse Notes

If the fictional Lighthouse Notes team tracked work in a tracker with an
MCP server available, the `003-tag-filtering` spec from
[Example Project](example-project.md) could have started from a ticket
instead of a `.triage/` file - same underlying idea (users want to filter
notes by tag, don't need multi-tag support yet), just fetched over MCP
instead of hand-typed or dropped in as a file. The rest of spec authoring -
researching the codebase, drafting requirements, presenting them for
review - works identically either way.

## What this doesn't do

This pattern only covers *reading* a ticket to seed a spec. Anything beyond
that - updating the ticket's state, logging time against it, linking
sub-tickets, or similar - is entirely up to how you configure your own MCP
connection and workflow notes: personal setups belong in
[`local/overview.md`](../local-folder.md), or in
[`project.md`](../customization.md) instead if the convention should be
shared across the team. CDP itself has no opinion on ticket trackers and
doesn't assume one is in use at all.
