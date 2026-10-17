# Node.js

## Overview

Standards for Node.js runtime code - servers, CLIs, and backend services.

This file assumes `javascript.md` has already been read. It shares the same
baseline (ESLint's recommended rules, Prettier for formatting, and the style
rules there) and does not repeat them. It covers only what is specific to
running JavaScript in Node rather than a browser: the module system,
`package.json`, async I/O, streams, configuration, and the process
lifecycle.

Node-specific checks are enforced with **`eslint-plugin-n`**, maintained by
the ESLint community:
https://github.com/eslint-community/eslint-plugin-n

For TypeScript on Node, apply `typescript.md` as well.

---

## Toolchain Setup

```bash
npm install -D eslint @eslint/js globals eslint-plugin-n prettier eslint-config-prettier
```

**`eslint.config.js`** - the `javascript.md` config plus the Node rules:

```js
import js from '@eslint/js';
import { defineConfig } from 'eslint/config';
import eslintConfigPrettier from 'eslint-config-prettier/flat';
import n from 'eslint-plugin-n';
import globals from 'globals';

export default defineConfig([
  js.configs.recommended,
  n.configs['flat/recommended-module'], // 'flat/recommended-script' for CommonJS
  {
    files: ['**/*.{js,mjs,cjs}'],
    languageOptions: { globals: globals.node },
    rules: {
      // ...the style rules from javascript.md...
      'n/prefer-node-protocol': 'error',
      'n/prefer-promises/fs': 'error',
      'n/no-sync': 'error',
      'n/no-process-exit': 'error',
    },
  },
  {
    // One-shot scripts and CLI entry points may block and exit
    files: ['scripts/**', 'bin/**'],
    rules: { 'n/no-sync': 'off', 'n/no-process-exit': 'off' },
  },
  eslintConfigPrettier,
]);
```

`eslint-plugin-n` reads `engines.node` from `package.json` to flag
language and API features the declared Node version does not support - see
**`package.json` Conventions** below.

---

## Rules That Override the Baseline

### No rule overrides defined.

Document project-specific exceptions here as they are identified.

---

## Node Rules

### Module System

Use ES modules (`import`/`export`, `"type": "module"` in `package.json`) for
new projects unless the project has already standardized on CommonJS
(`require`/`module.exports`). Do not mix both styles within one project:

```js
// good - ES modules
import { readFile } from 'node:fs/promises';
export function getOrder(id) { ... }

// good - CommonJS, if that's the project's established convention
const { readFile } = require('node:fs/promises');
module.exports = { getOrder };
```

Use the `node:` prefix for built-in modules (`n/prefer-node-protocol`) - it
makes clear at a glance that the import is a Node built-in, not a package:

```js
// bad
import fs from 'fs';

// good
import fs from 'node:fs';
```

### Async I/O (`n/prefer-promises/fs`, `n/no-sync`)

Use the Promise-based APIs (`node:fs/promises`, etc.) over callback-based
APIs. Never mix callback style and Promise style for the same operation:

```js
// bad - callback style
fs.readFile(path, (err, data) => { ... });

// good
const data = await readFile(path);
```

Never call a synchronous I/O function (`readFileSync`, `execSync`) on a
request-handling code path - it blocks the event loop and stalls every
other in-flight request. Synchronous calls are acceptable only in startup
or CLI code that runs once, before the server accepts requests (the
`scripts/**` / `bin/**` override above).

### `package.json` Conventions

- Pin dependency versions deliberately, following the project's existing
  convention (exact or a `^` range) - do not silently switch strategies.
- Keep `dependencies` and `devDependencies` separate - a build or test tool
  never belongs in `dependencies`.
- Declare `engines.node` so the required Node version is discoverable and
  `eslint-plugin-n` can check against it.
- Commit the lockfile.

### Streams

Prefer streaming APIs over loading a whole file or response into memory when
the data could be large (uploads, exports, log processing). Use
`pipeline()` from `node:stream/promises`, which propagates errors and
closes every stream:

```js
// bad - loads the entire file into memory
const data = await readFile(largePath);

// good - bounded memory, errors handled
import { pipeline } from 'node:stream/promises';
await pipeline(createReadStream(largePath), transform, destination);
```

If streams are wired up by hand instead, attach an `error` handler to each
one - an unhandled stream error crashes the process.

### Environment Configuration

Read configuration from `process.env`. Never hardcode environment-specific
values (URLs, ports, feature flags). Validate required variables at startup
and fail fast with a clear message if one is missing, instead of failing
confusingly at first use.

### Error Handling and Process Lifecycle

In server entry points, handle `unhandledRejection` and
`uncaughtException` at the process level, logging the error before the
process exits - a silent or cryptic crash must never be the only signal.

Never call `process.exit()` from a request-handling code path
(`n/no-process-exit`) - it kills in-flight requests for every connection,
not just the one that failed. Throw, or return an error response, instead.

---

## What Claude Must Not Do

- Do not call a synchronous I/O function on a request-handling code path
- Do not mix ES modules and CommonJS within one project
- Do not import built-ins without the `node:` prefix
- Do not call `process.exit()` from a request-handling code path
- Do not load a potentially large file or response fully into memory when a
  streaming API is available
- Do not leave a hand-wired stream without an `error` handler
- Do not hardcode environment-specific configuration values
