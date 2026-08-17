# CSS (Vanilla)

## Overview

Standards for vanilla CSS - no preprocessor (Sass/Less), no utility
framework (Tailwind). For CSS embedded in Docker Compose files or YAML, see
those files' own standards instead.

Two baselines apply together, each solving a different problem:

- **ITCSS (Inverted Triangle CSS)** for architecture - solves specificity
  wars by ordering rules from generic to specific, low-specificity to
  high-specificity, so cascade order and specificity order always agree
- **BEM (Block, Element, Modifier)** for naming - removes ambiguity about
  what a class does and where it is safe to reuse it

This file defines only the rules that extend those two conventions. When in
doubt, ITCSS governs file/rule ordering and BEM governs class naming.

---

## Rules That Override the Baseline

### No rule overrides defined.

Document project-specific exceptions here as they are identified.

---

## Rules That Match the Baseline (Key Reminders)

These rules are highlighted because they are commonly missed:

### ITCSS Layer Ordering

Organize stylesheets (or `@import`/`<link>` order) from generic to specific,
never mixing layers out of order:

1. **Settings** - variables, custom properties, no output CSS
2. **Tools** - mixins/functions, no output CSS
3. **Generic** - resets, normalize, box-sizing
4. **Elements** - bare HTML element selectors (`h1`, `a`, `body`)
5. **Objects** - layout patterns, no cosmetic styling (`.o-container`, `.o-grid`)
6. **Components** - actual UI pieces, BEM-named (`.c-card`, `.c-nav`)
7. **Utilities** - single-purpose overrides, highest specificity (`.u-hidden`)

```css
/* good - generic before specific, matches ITCSS layer order */

/* 3. Generic */
* { box-sizing: border-box; }

/* 4. Elements */
h1 { font-size: 2rem; }

/* 6. Components */
.c-card { padding: 1rem; }

/* 7. Utilities */
.u-hidden { display: none; }
```

### Specificity Discipline

Never fight specificity with `!important` as a routine tool - it is a signal
the ITCSS layering broke down somewhere. Reserve `!important` for utility
classes that must always win by design (layer 7), and never use it inside a
Components-layer rule:

```css
/* bad - patches over a specificity problem instead of fixing the layering */
.c-card .title {
  color: red !important;
}

/* good - utility class, designed to always win */
.u-text-error {
  color: red !important;
}
```

Keep selectors as flat as possible - a single class per rule wherever
achievable. Avoid selector nesting/chaining that raises specificity beyond
what BEM naming already needs:

```css
/* bad - unnecessarily specific, hard to override */
.c-card .c-card__header .c-card__title {
  font-weight: bold;
}

/* good - BEM naming already encodes the relationship */
.c-card__title {
  font-weight: bold;
}
```

### BEM Naming

`block`, `block__element`, `block--modifier` - double underscore for
elements, double hyphen for modifiers:

```css
/* good */
.card { }
.card__title { }
.card__title--large { }
.card--featured { }
```

```html
<!-- good -->
<div class="card card--featured">
  <h2 class="card__title card__title--large">Order Summary</h2>
</div>
```

Never nest a block name inside another block's element name (`.card
.nav__item` styling `.nav__item` differently only inside `.card` breaks
BEM's independence guarantee) - if a component needs to look different in a
context, that is a modifier, not a nested selector:

```css
/* bad - nav__item's appearance now depends on where it's placed */
.card .nav__item { color: blue; }

/* good - explicit modifier makes the variant self-contained */
.nav__item--highlighted { color: blue; }
```

### Custom Properties for Design Tokens

Define reusable values (colors, spacing, breakpoints) as CSS custom
properties in the Settings layer, never hardcoded repeatedly across
Components:

```css
/* Settings layer */
:root {
  --color-primary: #1a73e8;
  --space-md: 1rem;
}

/* Components layer */
.c-card {
  padding: var(--space-md);
  border-color: var(--color-primary);
}
```

### Units

Use `rem` for font sizes and most spacing (scales with user font-size
preference), `px` only for things that should never scale (hairline
borders, box-shadow offsets).

---

## What Claude Must Not Do

- Do not write a Components-layer or Elements-layer rule using `!important`
- Do not nest a selector across block boundaries (styling one block's
  element differently based on an ancestor block)
- Do not hardcode a color, spacing, or breakpoint value that already has a
  custom property defined for it
- Do not mix ITCSS layers out of order in the same stylesheet/import chain
- Do not use an ID selector for styling - IDs create specificity that BEM's
  flat class model cannot easily override
