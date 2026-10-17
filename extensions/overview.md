# Overview - extensions/

## Purpose

This folder lets a project override or add protocol-adjacent behavior
for a specific rule that a protocol file explicitly documents as
overridable - distinct from `architecture/` (describes the app as it
exists) and `config/` (the app's own runtime configuration). There is
no protocol-mandated filename convention: an operator names each file
however they like. What matters is that every file present is
registered below, so Claude (and any protocol rule checking for an
override) can find it by reading this table rather than assuming a name.

## Contents

| File | Overrides |
|---|---|

*(Empty until a project adds its first override. Add a row here for
every file placed in this folder, naming exactly which protocol rule or
section it overrides.)*

## Notes

Claude reads this file in full at Session Start, immediately after
`.claude/project.md` - see `CLAUDE.md`'s `## Session Start`. If anything
listed here conflicts with something `project.md` says, Claude stops
and asks which source to follow rather than guessing.

## Restrictions

- Claude never creates a file in this folder unprompted - only a human
  decides to override a default.
- Any time Claude creates, or finds, a file in this folder not yet
  listed in `Contents`, it adds a row for it as part of the same piece
  of work.
