# JavaScript

## Overview

Standards for all JavaScript files. `node.md`, `typescript.md`, and
`vue3.md` build on this file.

The baseline has three parts, all maintained by the tools' own teams:

- **Correctness** - ESLint's recommended rules (`@eslint/js`):
  https://eslint.org/docs/latest/rules/
- **Formatting** - **Prettier**, so layout (indentation, quotes, semicolons,
  line breaks) is never decided by hand or argued in review:
  https://prettier.io/
- **Style** - the rules below. Each one names the ESLint rule that enforces
  it, so lint checks it rather than a reader.

When in doubt about something not covered here, the ESLint rule
documentation is the authority.

All files must pass ESLint with no errors and be formatted with Prettier
before being committed.

---

## Toolchain Setup

```bash
npm install -D eslint @eslint/js globals prettier eslint-config-prettier
```

**`eslint.config.js`:**

```js
import js from '@eslint/js';
import { defineConfig } from 'eslint/config';
import eslintConfigPrettier from 'eslint-config-prettier/flat';
import globals from 'globals';

export default defineConfig([
  js.configs.recommended,
  {
    files: ['**/*.{js,mjs,cjs}'],
    languageOptions: { globals: globals.browser },
    rules: {
      'no-var': 'error',
      'prefer-const': 'error',
      eqeqeq: ['error', 'always'],
      'prefer-template': 'error',
      'object-shorthand': ['error', 'always'],
      'prefer-destructuring': ['error', { object: true, array: false }],
      'prefer-arrow-callback': 'error',
      'func-style': ['error', 'declaration', { allowArrowFunctions: true }],
      'no-param-reassign': 'error',
    },
  },
  eslintConfigPrettier, // last - turns off any rule that conflicts with Prettier
]);
```

**`.prettierrc.json`:**

```json
{ "singleQuote": true }
```

Use ESLint's flat config (`eslint.config.js`). The legacy `.eslintrc*`
format is no longer supported by current ESLint.

---

## Rules That Override the Baseline

### No rule overrides defined.

Document project-specific exceptions here as they are identified.

---

## Style Rules

### Variables (`no-var`, `prefer-const`)

Always use `const` by default. Use `let` only when reassignment is required.
Never use `var`:

```js
// bad
var count = 0;
let name = 'Alex';

// good
const name = 'Alex';
let count = 0;
count += 1;
```

### Functions (`func-style`, `prefer-arrow-callback`)

Use function declarations for named functions - they are hoisted and named
in stack traces. Use arrow functions for callbacks and short inline
functions:

```js
// bad
const getTotal = function (items) { return items.length; };
[1, 2, 3].map(function (x) { return x * 2; });

// good
function getTotal(items) {
  return items.length;
}
[1, 2, 3].map((x) => x * 2);
```

### Parameters (`no-param-reassign`)

Never reassign a function parameter - copy it to a local variable instead.

### Objects (`object-shorthand`)

Use shorthand property and method notation:

```js
// bad
const obj = {
  name: name,
  getValue: function () { return this.value; },
};

// good
const obj = {
  name,
  getValue() { return this.value; },
};
```

### Destructuring (`prefer-destructuring`)

Use object destructuring when reading properties into variables of the
same name:

```js
// bad
const firstName = user.firstName;

// good
const { firstName, lastName } = user;
```

### Strings (`prefer-template`)

Use template literals for interpolation and multiline strings, never string
concatenation. Quote style is set by Prettier (`singleQuote`):

```js
// bad
const greeting = 'Hello ' + name;

// good
const greeting = `Hello ${name}`;
```

### Comparison (`eqeqeq`)

Always use strict equality (`===` and `!==`). Never use `==` or `!=`:

```js
// bad
if (value == null) {}

// good
if (value === null || value === undefined) {}
```

### Imports

Imports appear at the top of the file, grouped in this order, with one blank
line between groups:

1. Built-in and external packages
2. Internal modules (path aliases such as `@/`)
3. Relative imports

```js
import { format } from 'date-fns';

import { formatPrice } from '@/utils/price';

import { OrderRow } from './order-row';
```

### Comments

Use `//` for single-line comments and `/** ... */` (JSDoc) on exported
functions and classes. Comment the *why*, not the *what*. Do not leave
commented-out code - remove it; version control keeps the history:

```js
// bad
// const oldValue = compute();

// good
// Retry once on 429 before surfacing the error to the caller
```

---

## What Claude Must Not Do

- Do not use `var` - use `const` or `let`
- Do not use `==` or `!=` - always use `===` or `!==`
- Do not use string concatenation for interpolation - use template literals
- Do not use function expressions for named functions or callbacks - use a
  declaration or an arrow function
- Do not reassign function parameters
- Do not format code by hand against Prettier's output, or add ESLint
  formatting rules that fight it
- Do not leave commented-out code in committed files
- Do not commit files that produce ESLint errors
