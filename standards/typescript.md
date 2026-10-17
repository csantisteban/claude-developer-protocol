# TypeScript

## Overview

Standards for all TypeScript files. `vue3.md` builds on this file for
`.vue` components.

This file extends `javascript.md` - its baseline (ESLint's recommended
rules, Prettier for formatting) and style rules still apply unless
overridden here. On top of it, the baseline is **typescript-eslint**'s
`strictTypeChecked` and `stylisticTypeChecked` rule sets, maintained by the
typescript-eslint team:
https://typescript-eslint.io/users/configs

These are typed rules - they use the TypeScript compiler's type information,
so they catch real bugs (unhandled promises, unsafe `any`, unnecessary
conditions) that syntax-only linting cannot.

---

## Toolchain Setup

```bash
npm install -D eslint @eslint/js typescript typescript-eslint prettier eslint-config-prettier
```

**TypeScript version:** typed linting only works with the TypeScript
versions `typescript-eslint` supports - check the `typescript` peer range of
the installed `typescript-eslint` before upgrading TypeScript. Do not move a
project to a TypeScript major that range does not cover yet.

**`eslint.config.js`:**

```js
import js from '@eslint/js';
import { defineConfig } from 'eslint/config';
import eslintConfigPrettier from 'eslint-config-prettier/flat';
import tseslint from 'typescript-eslint';

export default defineConfig([
  js.configs.recommended,
  tseslint.configs.strictTypeChecked,
  tseslint.configs.stylisticTypeChecked,
  {
    languageOptions: {
      parserOptions: {
        projectService: true,
        tsconfigRootDir: import.meta.dirname,
      },
    },
    rules: {
      // ...the style rules from javascript.md...
      '@typescript-eslint/consistent-type-imports': 'error',
      '@typescript-eslint/explicit-module-boundary-types': 'error',
      '@typescript-eslint/naming-convention': ['error', {
        selector: 'interface',
        format: ['PascalCase'],
        custom: { regex: '^I[A-Z]', match: false },
      }],
    },
  },
  {
    // Plain JS files (e.g. this config) get no typed rules
    files: ['**/*.{js,mjs,cjs}'],
    extends: [tseslint.configs.disableTypeChecked],
  },
  eslintConfigPrettier,
]);
```

Type-check in CI with `tsc --noEmit` (or `vue-tsc --noEmit` in Vue
projects) - ESLint does not report compiler errors.

---

## tsconfig Requirements

Always enable strict mode. No exceptions.

```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true
  }
}
```

| Flag | Why |
|---|---|
| `strict` | Enables all strict checks, including `strictNullChecks` and `noImplicitAny` |
| `noUncheckedIndexedAccess` | Array and object indexing returns `T \| undefined`, not just `T` |
| `exactOptionalPropertyTypes` | Distinguishes `{ a?: string }` from `{ a: string \| undefined }` |
| `noImplicitReturns` | Every code path in a function must return a value |
| `noFallthroughCasesInSwitch` | A non-empty `case` must end with `break`, `return`, or `throw` |

---

## Naming Conventions

| Thing | Convention | Example |
|---|---|---|
| Variables and functions | `camelCase` | `getUserById` |
| Classes | `PascalCase` | `UserService` |
| Interfaces | `PascalCase`, no `I` prefix | `UserDto`, `ApiResponse` |
| Type aliases | `PascalCase` | `UserId`, `UserRole` |
| Enum names and members | `PascalCase` | `UserRole.Admin` |
| Module-level constants | `UPPER_SNAKE_CASE` | `MAX_RETRIES` |
| Files | `kebab-case` | `user-service.ts` |

**File name exceptions:** Vue components (`UserCard.vue`) and Vue
composables and stores (`useAuth.ts`) follow `vue3.md`.

---

## Types and Interfaces

- Use `interface` for object shapes (props, API contracts, class shapes)
- Use `type` for unions, intersections, mapped types, and aliases
- Never use `any` (`no-explicit-any`, `no-unsafe-*`) - use `unknown` and
  narrow it

```ts
// good - interface for object shapes
interface UserDto {
  id: string;
  email: string;
  role: UserRole;
}

// good - type for unions and aliases
type UserId = string;
type Status = 'active' | 'inactive' | 'pending';

// bad
const payload: any = JSON.parse(text);

// good - unknown, then narrow
const payload: unknown = JSON.parse(text);
if (isUserDto(payload)) { ... }
```

---

## Enums

Prefer a union of string literals. If an enum is needed, use a string enum
so values are readable at runtime. Avoid numeric enums (opaque values) and
`const enum` in exported code (breaks across module boundaries):

```ts
// good - preferred for simple cases
type UserRole = 'ADMIN' | 'VIEWER' | 'EDITOR';

// good - string enum
enum UserRole {
  Admin = 'ADMIN',
  Viewer = 'VIEWER',
}

// bad - numeric enum
enum Direction { Up, Down }
```

---

## Functions

- Exported functions declare parameter and return types
  (`explicit-module-boundary-types`)
- Function declarations for named functions, arrow functions for callbacks
  (as in `javascript.md`)
- Every promise is awaited, returned, or explicitly handled
  (`no-floating-promises`) - use `void` only when ignoring it is deliberate

```ts
// good
export async function fetchUser(id: string): Promise<UserDto> {
  const response = await apiClient.get<UserDto>(`/users/${id}`);
  return response.data;
}

const activeUsers = users.filter((user) => user.status === 'active');

// bad - untyped boundary, floating promise
export async function fetchUser(id) { ... }
fetchUser('42');
```

---

## Generics

Use descriptive names beyond `T` when the context benefits from it, and
constrain generics when the shape is known:

```ts
function merge<TBase extends object, TOverride extends object>(
  base: TBase,
  override: TOverride,
): TBase & TOverride { ... }

function first<T>(items: T[]): T | undefined {
  return items[0];
}
```

---

## Null and Undefined

- Prefer `undefined` over `null` for optional values
- Use optional chaining (`?.`) and nullish coalescing (`??`)
- Never use the non-null assertion `!` (`no-non-null-assertion`) - narrow
  with a check instead

```ts
// bad - silences the type checker
const name = user!.profile!.displayName;

// good
const name = user?.profile?.displayName ?? 'Anonymous';

// good - narrow, then use
const canvas = document.getElementById('chart');
if (!(canvas instanceof HTMLCanvasElement)) {
  throw new Error('Chart canvas missing');
}
```

---

## Type Assertions (`as`)

Avoid `as` except when the type system cannot know a type that you can prove
(DOM event targets, untyped third-party code). Never use `as any` or
`as unknown as T` to force a type:

```ts
// acceptable - the handler is only attached to inputs
const input = event.target as HTMLInputElement;

// bad
const data = response as any;
```

---

## Imports

- Use path aliases (`@/`) instead of deep relative chains (`../../../`)
- Use `import type` for type-only imports (`consistent-type-imports`)
- Group imports as in `javascript.md`, with type-only imports last

```ts
import { computed, ref } from 'vue';

import { apiClient } from '@/lib/api-client';
import { useUserStore } from '@/stores/useUserStore';

import type { UserDto } from '@/types/user';
```

---

## Classes

- Use `private`, `protected`, and `readonly` explicitly
- Prefer a getter or method over a public mutable field
- Use `static` only for genuinely stateless logic

```ts
class UserService {
  constructor(
    private readonly userRepository: UserRepository,
    private readonly logger: Logger,
  ) {}

  async findById(id: string): Promise<UserDto | undefined> {
    return this.userRepository.findOne(id);
  }
}
```

---

## Error Handling

Only throw `Error` objects (`only-throw-error`), never strings or plain
objects. Subclass `Error` for errors callers need to tell apart:

```ts
class NotFoundError extends Error {
  constructor(resource: string) {
    super(`${resource} not found`);
    this.name = 'NotFoundError';
  }
}

// bad
throw 'User not found';
```

---

## What Claude Must Never Do

- Use `any`, `as any`, or `as unknown as T` - use `unknown` and narrow
- Use the non-null assertion `!`
- Use `// @ts-ignore` or `// @ts-nocheck` - fix the type; if unavoidable, use
  `// @ts-expect-error` with a reason
- Add the `I` prefix to interfaces
- Leave a promise unawaited and unhandled
- Leave parameter or return types implicit on exported functions
- Skip `import type` for type-only imports
- Upgrade TypeScript past the version `typescript-eslint` supports
