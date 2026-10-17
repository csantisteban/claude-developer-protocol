# HTML

## Overview

Standards for all HTML markup, including static pages, server-rendered
templates, and the markup portion of component-based frameworks.

Three baselines apply together, each covering a different concern:

- **Semantic structure:** WHATWG's intended usage of HTML5 elements -
  https://html.spec.whatwg.org
- **Accessibility:** WCAG 2.1/2.2 AA - https://www.w3.org/WAI/WCAG22/quickref/
  - this is the real quality bar for markup, not formatting
- **Formatting:** the Google HTML Style Guide -
  https://google.github.io/styleguide/htmlcssguide.html

This file defines only the rules that differ from or extend those baselines.
When in doubt, WHATWG governs element semantics, WCAG 2.1/2.2 AA governs
accessibility, and the Google HTML Style Guide governs formatting.

---

## Rules That Override the Baseline

### No rule overrides defined.

Document project-specific exceptions here as they are identified.

---

## Rules That Match the Baseline (Key Reminders)

These rules are highlighted because they are commonly missed:

### Semantic Elements Over `<div>`/`<span>`

Use the element whose native semantics match the content's role - never a
generic `<div>` where a semantic element exists:

```html
<!-- bad -->
<div class="nav">...</div>
<div class="header">...</div>
<div onclick="submit()">Submit</div>

<!-- good -->
<nav>...</nav>
<header>...</header>
<button type="submit">Submit</button>
```

Reach for `<section>`, `<article>`, `<nav>`, `<header>`, `<footer>`,
`<aside>`, `<main>` based on the content's actual role, not visual layout
convenience.

### Heading Hierarchy

Headings (`<h1>`-`<h6>`) form a single logical outline per page - never skip
a level, and never choose a heading level for its default font size instead
of its outline position:

```html
<!-- bad - skips from h1 to h3 -->
<h1>Order Summary</h1>
<h3>Items</h3>

<!-- bad - h2 used only because it "looks right," breaks the outline -->
<h1>Order Summary</h1>
<h2>Items</h2>
<h2>Total (styled as a subsection of Items)</h2>

<!-- good -->
<h1>Order Summary</h1>
<h2>Items</h2>
<h3>Total</h3>
```

Exactly one `<h1>` per page, describing the page's primary content.

### Accessible Forms

Every form control has a programmatically associated label - never rely on
placeholder text or surrounding prose as the only label:

```html
<!-- bad - placeholder disappears on input, not a real label -->
<input type="email" placeholder="Email">

<!-- good -->
<label for="email">Email</label>
<input type="email" id="email" name="email">
```

Group related controls (e.g. a radio button set) in a `<fieldset>` with a
`<legend>` describing the group.

### Alt Text

Every `<img>` has an `alt` attribute. Decorative images get `alt=""`
(empty, not omitted) so assistive technology skips them; informative images
get a description of their content and purpose, not their filename:

```html
<!-- bad -->
<img src="chart.png">
<img src="icon-trash.svg" alt="icon-trash">

<!-- good - informative -->
<img src="revenue-chart.png" alt="Revenue grew 12% quarter over quarter">

<!-- good - decorative -->
<img src="divider.svg" alt="">
```

### ARIA - Only Where Native Semantics Fall Short

Prefer a native element with built-in semantics over adding ARIA to a
generic one. Use ARIA only to fill a genuine gap - and never to override the
native semantics of an element that already has them:

```html
<!-- bad - reinvents what <button> already provides -->
<div role="button" tabindex="0" onclick="submit()">Submit</div>

<!-- good -->
<button type="submit">Submit</button>

<!-- good - ARIA fills a real gap, no native element for this widget -->
<div role="tablist">
  <button role="tab" aria-selected="true">Overview</button>
  <button role="tab" aria-selected="false">Details</button>
</div>
```

### Keyboard Navigability

Every interactive element must be reachable and operable via keyboard alone
- native interactive elements (`<button>`, `<a href>`, `<input>`) get this
for free; a custom interactive widget built from non-interactive elements
needs an explicit `tabindex` and key event handling:

```html
<!-- bad - not focusable, not operable by keyboard -->
<span onclick="toggle()">Expand</span>

<!-- good -->
<button type="button" onclick="toggle()">Expand</button>
```

### Attribute Quoting and Formatting

Double-quote all attribute values. One attribute per line only when a tag
has enough attributes that a single line would hurt readability - follow the
Google HTML Style Guide's line-length judgment, not a fixed attribute count:

```html
<!-- bad -->
<input type=text name=email required>

<!-- good -->
<input type="text" name="email" required>
```

### `lang` and `charset`

Every document declares `<html lang="...">` and `<meta charset="utf-8">` as
the first elements inside `<head>`:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Order Summary</title>
</head>
```

---

## What Claude Must Not Do

- Do not use a `<div>` or `<span>` where a semantic element's native meaning
  fits
- Do not skip a heading level or use more than one `<h1>` per page
- Do not omit `alt` on an `<img>` - use `alt=""` for decorative images, never
  omit the attribute entirely
- Do not use placeholder text as a substitute for a real `<label>`
- Do not add `role`/ARIA attributes to override the native semantics of an
  element that already has them
- Do not build a custom interactive widget without keyboard support
- Do not omit `lang` on `<html>` or `charset` on the document
