# JavaScript

## Overview

Standards for all vanilla JavaScript files.

The baseline is the **Airbnb JavaScript Style Guide**:
https://github.com/airbnb/javascript

This file defines only the rules that differ from or extend the Airbnb baseline.
When in doubt, the Airbnb guide is the authority.

Linting is enforced via **ESLint** with the Airbnb config:
https://www.npmjs.com/package/eslint-config-airbnb-base

All files must pass ESLint with no errors before being committed.

---

## Rules That Override Airbnb

### No rule overrides defined.

Document project-specific exceptions here as they are identified.

---

## Rules That Match Airbnb (Key Reminders)

These Airbnb rules are highlighted because they are commonly missed:

### Variables

Always use `const` by default. Use `let` only when reassignment is required.
Never use `var`:

```js
// bad
var count = 0;
let name = 'Carlos';

// good
const name = 'Carlos';
let count = 0;
count += 1;
```

### Functions

Prefer named function expressions over function declarations for assigned
functions. Always use arrow functions for callbacks:

```js
// bad
function foo() {}
const bar = function() {};
[1, 2, 3].map(function(x) { return x * 2; });

// good
const foo = () => {};
[1, 2, 3].map((x) => x * 2);
```

### Objects

Use shorthand property and method notation. Do not quote property keys unless
required:

```js
// bad
const obj = {
  name: name,
  getValue: function() { return this.value; },
  'key': 1,
};

// good
const obj = {
  name,
  getValue() { return this.value; },
  key: 1,
};
```

### Destructuring

Use destructuring for objects and arrays wherever practical:

```js
// bad
const firstName = user.firstName;
const lastName = user.lastName;

// good
const { firstName, lastName } = user;
const [first, second] = items;
```

### Strings

Use single quotes for string literals. Use template literals for interpolation
and multiline strings — never string concatenation:

```js
// bad
const greeting = "Hello " + name;
const multiline = "line one\n" + "line two";

// good
const greeting = `Hello ${name}`;
const multiline = `
  line one
  line two
`;
```

### Comparison

Always use strict equality (`===` and `!==`). Never use `==` or `!=`:

```js
// bad
if (value == null) {}
if (result != false) {}

// good
if (value === null) {}
if (result !== false) {}
```

### Imports

Imports must appear at the top of the file, grouped and ordered as follows:

1. External libraries
2. Internal modules (absolute paths)
3. Relative imports

One blank line between each group:

```js
import axios from 'axios';
import _ from 'lodash';

import { formatDate } from '@/utils/date';

import MyComponent from './MyComponent';
```

### Comments

Use `//` for single-line comments. Use `/** ... */` for JSDoc on exported
functions and classes. Avoid commented-out code — remove it or track it in
version control:

```js
// bad
// const oldValue = compute();

// good — document the why, not the what
// Retry once on 429 before surfacing the error to the caller
```

---

## What Claude Must Not Do

- Do not use `var` — use `const` or `let`
- Do not use `==` or `!=` — always use `===` or `!==`
- Do not use string concatenation for interpolation — use template literals
- Do not use anonymous function expressions where a named one is clearer
- Do not leave commented-out code in committed files
- Do not commit files that produce ESLint errors
