# Node.js

## Overview

Standards for Node.js runtime code - servers, CLIs, and backend services.
This file assumes `javascript.md` has already been read - it shares the same
**Airbnb JavaScript Style Guide** baseline for general JS conventions
(naming, formatting, ES6+ idioms) and does not repeat them here. This file
covers only what is specific to running JavaScript in Node's runtime rather
than a browser: the module system, npm/`package.json` conventions, streams,
and the event loop.

---

## Rules That Override the Baseline

### No rule overrides defined.

Document project-specific exceptions here as they are identified.

---

## Rules That Match the Baseline (Key Reminders)

These rules are highlighted because they are commonly missed:

### Module System

Use ES modules (`import`/`export`, `"type": "module"` in `package.json`)
for new projects unless the project has already standardized on CommonJS
(`require`/`module.exports`) - do not mix both styles within one project:

```javascript
// good - ES modules
import { readFile } from 'node:fs/promises';
export function getOrder(id) { ... }

// good - CommonJS, if that's the project's established convention
const { readFile } = require('node:fs/promises');
module.exports = { getOrder };
```

Use the `node:` prefix for built-in module imports - makes it unambiguous
at a glance that the import is a Node built-in, not a package:

```javascript
// bad
import fs from 'fs';

// good
import fs from 'node:fs';
```

### Async I/O

Use the Promise-based APIs (`node:fs/promises`, etc.) over callback-based
APIs in new code. Never mix callback-style and Promise-style for the same
operation:

```javascript
// bad - callback style
fs.readFile(path, (err, data) => { ... });

// good
const data = await fs.readFile(path);
```

Never use a synchronous I/O function (`readFileSync`, `execSync`) on a
request-handling code path - it blocks the entire event loop, stalling
every other in-flight request. Synchronous calls are acceptable only in
startup/CLI-script code paths that run once, before the server starts
accepting requests.

### `package.json` Conventions

Pin dependency versions deliberately (exact or `^minor.patch` range per the
project's existing convention - do not silently switch a project between
pinning strategies). Keep `dependencies` and `devDependencies` correctly
separated - a build/test-only tool never belongs in `dependencies`.

Declare an explicit `engines.node` field so the required Node version is
discoverable without reading CI config.

### Streams

Prefer streaming APIs over loading an entire file/response into memory when
processing data that could be large (uploads, exports, log processing):

```javascript
// bad - loads the entire file into memory
const data = await fs.readFile(largePath);
process(data);

// good - streams, bounded memory usage
const stream = fs.createReadStream(largePath);
stream.pipe(transform).pipe(destination);
```

Always attach an `error` handler to a stream - an unhandled stream error
crashes the process in Node's default configuration.

### Environment Configuration

Read configuration from `process.env`, never hardcode environment-specific
values (URLs, ports, feature flags). Validate required environment
variables at startup and fail fast with a clear error if one is missing,
rather than failing confusingly later at first use.

### Error Handling and Process Lifecycle

Attach handlers for `unhandledRejection` and `uncaughtException` at the
process level in server entry points, logging the error before the process
exits - never let the default Node behavior (a silent or cryptic crash)
be the only signal something went wrong.

Never call `process.exit()` from within a request-handling code path - it
kills in-flight requests for every other concurrent connection, not just
the one that failed.

---

## What Claude Must Not Do

- Do not use a synchronous I/O function on a request-handling code path
- Do not mix ES modules and CommonJS within the same project
- Do not call `process.exit()` from a request-handling code path
- Do not load a potentially large file or response fully into memory when a
  streaming API is available
- Do not leave a stream without an `error` handler
- Do not hardcode environment-specific configuration values
