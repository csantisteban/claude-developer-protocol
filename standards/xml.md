# XML

## Overview

Standards for all XML documents, including config files, data interchange
formats, and markup vocabularies (not covering XML-derived HTML - see
`html.md` for that).

The baseline is the **Google XML Document Format Style Guide**:
https://google.github.io/styleguide/xmlstyle.html

This is the closest thing XML has to a detailed, citable formatting spec -
comparable to PSR-12 for PHP or the Google Java Style Guide for Java. This
file defines only the rules that differ from or extend that baseline.

---

## Rules That Override the Baseline

### No rule overrides defined.

Document project-specific exceptions here as they are identified.

---

## Rules That Match the Baseline (Key Reminders)

These rules are highlighted because they are commonly missed:

### Indentation

2-space indentation, no tabs:

```xml
<!-- bad -->
<order>
    <id>1</id>
</order>

<!-- good -->
<order>
  <id>1</id>
</order>
```

### Attribute Formatting

A single attribute stays on the same line as its element. When an element
has multiple attributes, put one per line, aligned under the first:

```xml
<!-- bad - multiple attributes crammed on one line -->
<order id="1" status="pending" created="2026-08-15" customer="acme-co">

<!-- good - single attribute -->
<order id="1">

<!-- good - multiple attributes, one per line, aligned -->
<order id="1"
       status="pending"
       created="2026-08-15"
       customer="acme-co">
```

### Elements vs. Attributes

Use an element when the data is content the document is fundamentally
about; use an attribute for metadata describing that content. When in
doubt, prefer an element - it is easier to extend later (add children,
support mixed content) than an attribute is:

```xml
<!-- bad - core data crammed into attributes -->
<order id="1" total="42.50" status="pending"/>

<!-- good - total and status are the actual data -->
<order id="1">
  <total>42.50</total>
  <status>pending</status>
</order>
```

`id` as an attribute is a reasonable exception - it is genuinely metadata
identifying the element, not content.

### Self-Closing Tags

Use a self-closing tag (`<tag/>`) only for elements with no content and no
children. Never write an empty open/close pair when a self-closing tag is
available:

```xml
<!-- bad -->
<note></note>

<!-- good -->
<note/>
```

### Line Wrapping

Wrap long lines at a natural boundary (an attribute, not mid-word). Prefer
breaking one attribute per line (see above) over letting a line run long
rather than wrapping mid-attribute-value.

### Comments

Place a comment immediately above the element or block it describes, at the
same indentation level:

```xml
<!-- good -->
<order>
  <!-- total excludes tax, computed separately at checkout -->
  <total>42.50</total>
</order>
```

### Whitespace-Significant Content

When an element's content is whitespace-significant (e.g. preformatted
text), do not reformat or re-indent that content - preserve it exactly, and
avoid adding indentation around it that would become part of the content:

```xml
<!-- bad - indentation is now part of the preformatted content -->
<pre>
    line one
    line two
</pre>

<!-- good - content starts immediately, no injected whitespace -->
<pre>line one
line two</pre>
```

### Declaration and Encoding

Every standalone XML document starts with an explicit XML declaration and
encoding:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<order>
  ...
</order>
```

---

## A Note on XML Security

XML parsers are XXE-vulnerable by default in many languages/libraries
(external entity resolution enabled unless explicitly disabled). This file
covers document formatting only - the parser-level mitigation (disabling
DTD/external entity resolution) is a language-specific concern, already
covered where relevant (e.g. `java-security.md`'s XXE check). When writing
code that parses XML from an untrusted source, consult that language's
`*-security.md` file, not this one.

---

## What Claude Must Not Do

- Do not cram core document data into attributes when it belongs in element
  content
- Do not use an empty open/close tag pair where a self-closing tag applies
- Do not put multiple attributes on one line once an element has more than
  one
- Do not reformat or re-indent whitespace-significant content
- Do not omit the XML declaration and encoding from a standalone document
