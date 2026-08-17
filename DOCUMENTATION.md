# DOCUMENTATION.md - Doc Organization, Index Linking, and Numbering

Read this file when organizing generated docs into category subfolders, or when
naming a generated doc file.

---

## Doc Category Subfolders

Once a second file of the same generated-doc category would be added to
`.claude/docs/`, move both files into a dedicated subfolder named after the
category (e.g. `.claude/docs/security-reports/`):

1. Create `.claude/docs/<category>/` and move the existing file(s) into it
2. Create `.claude/docs/<category>/README.md` as that category's index, using
   the same `File | Summary` table shape as the top-level README
3. Collapse the top-level `.claude/docs/README.md` to a single entry for the
   category, linking to `<category>/README.md`
4. Every later file in that category is added only to `<category>/README.md`,
   never to the top-level README

The procedure file for each doc type (e.g. `SECURITY-ANALYSIS.md`) defines
that category's name and file-naming convention.

---

## Linked Index Rule

Any file that serves as an index for other docs - the top-level
`.claude/docs/README.md`, a category README, or similar - must list each doc
as a markdown link to that doc's actual path relative to the index file's own
location. Never list a bare filename or a description-only row with no link.

---

## Numbering

- A generated doc tied to a specific spec must reuse that spec folder's exact
  name, including any zero-padding, wherever `<spec_name>` appears - both in
  the filename and inside the doc's content
- A generated doc not tied to any spec folder must not receive a numeric
  prefix - name it after the feature or work item it documents
