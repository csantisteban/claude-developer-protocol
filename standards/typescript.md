# TypeScript Standards

**Based on:** [Airbnb JavaScript Style Guide](https://github.com/airbnb/javascript) + [`eslint-config-airbnb-typescript`](https://github.com/iamturns/eslint-config-airbnb-typescript)  
**Enforced by:** ESLint + `@typescript-eslint` — see `eslint.config.ts` at project root

This file extends the project's existing JavaScript (Airbnb) standards into TypeScript.
All Airbnb JS rules still apply unless explicitly overridden here.

---

## Toolchain Setup

```bash
npm install -D \
  eslint-config-airbnb-typescript \
  @typescript-eslint/eslint-plugin@^7.0.0 \
  @typescript-eslint/parser@^7.0.0
```

**`eslint.config.ts` base:**

```ts
export default [
  {
    extends: [
      'airbnb',
      'airbnb-typescript',
      'plugin:@typescript-eslint/recommended-type-checked',
      'plugin:@typescript-eslint/stylistic-type-checked',
    ],
    parser: '@typescript-eslint/parser',
    parserOptions: {
      project: './tsconfig.json',
    },
  },
];
```

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
| `strict` | Enables all strict checks including `strictNullChecks` and `noImplicitAny` |
| `noUncheckedIndexedAccess` | Array/object indexing returns `T \| undefined`, not just `T` |
| `exactOptionalPropertyTypes` | Distinguishes `{ a?: string }` from `{ a: string \| undefined }` |
| `noImplicitReturns` | All code paths in a function must return a value |

---

## Naming Conventions

| Thing | Convention | Example |
|---|---|---|
| Variables & functions | `camelCase` | `getUserById` |
| Classes | `PascalCase` | `UserService` |
| Interfaces | `PascalCase` — no `I` prefix | `UserDto`, `ApiResponse` |
| Type aliases | `PascalCase` | `UserId`, `UserRole` |
| Enums | `PascalCase` (name and members) | `UserRole.Admin` |
| Files | `kebab-case` | `user-service.ts` |
| Constants | `UPPER_SNAKE_CASE` for module-level; `camelCase` for local | `MAX_RETRIES` |

> **Note:** Airbnb does not use an `I` prefix for interfaces. Do not prefix interfaces with `I`.

---

## Variables & References

Follows Airbnb JS rules — extended for TypeScript:

```ts
// ✅ Always prefer const
const userId = 'abc-123';

// ✅ Use let only when reassignment is required
let count = 0;
count += 1;

// ❌ Never use var
var name = 'bad'; // eslint: no-var
```

---

## Types & Interfaces

- Use `interface` for object shapes that describe the structure of things (classes, props, API contracts)
- Use `type` for unions, intersections, mapped types, and utility aliases
- Never use `any` — use `unknown` and narrow explicitly

```ts
// ✅ Interface for object shapes
interface UserDto {
  id: string;
  email: string;
  role: UserRole;
}

// ✅ Type for unions and aliases
type UserId = string;
type ApiResult<T> = { data: T; status: number };
type Status = 'active' | 'inactive' | 'pending';

// ❌ Never use any
const response: any = fetch('/users'); // banned

// ✅ Use unknown and narrow
const response: unknown = fetch('/users');
if (typeof response === 'object' && response !== null) { ... }
```

---

## Enums

Prefer **string enums** so values are readable at runtime. Avoid `const enum` for shared/exported code — it can cause issues across module boundaries.

```ts
// ✅ String enum — value visible at runtime
enum UserRole {
  Admin = 'ADMIN',
  Viewer = 'VIEWER',
  Editor = 'EDITOR',
}

// ✅ Alternative: union type (preferred for simple cases)
type UserRole = 'ADMIN' | 'VIEWER' | 'EDITOR';

// ❌ Avoid numeric enums — values are opaque
enum Direction {
  Up,    // 0
  Down,  // 1
}
```

---

## Functions

- Always type parameters and return types on exported functions
- Prefer arrow functions for callbacks and inline logic
- Use named function declarations for exported top-level functions
- Keep functions single-purpose and short

```ts
// ✅ Exported function — explicit return type
export async function fetchUser(id: string): Promise<UserDto> {
  const response = await apiClient.get<UserDto>(`/users/${id}`);
  return response.data;
}

// ✅ Arrow function for callbacks
const activeUsers = users.filter((user) => user.status === 'active');

// ✅ Type inline parameters in callbacks
setTimeout((event: MouseEvent) => handleClick(event), 0);

// ❌ Missing return type on exported function
export async function fetchUser(id) { ... } // implicit any
```

---

## Generics

Use descriptive generic names beyond `T` when context benefits from it.
Constrain generics when the shape is known.

```ts
// ✅ Descriptive in complex contexts
function merge<TBase extends object, TOverride extends object>(
  base: TBase,
  override: TOverride,
): TBase & TOverride { ... }

// ✅ Simple T is fine for straightforward utilities
function first<T>(arr: T[]): T | undefined {
  return arr[0];
}
```

---

## Null & Undefined

- Prefer `undefined` over `null` for optional values
- Use optional chaining (`?.`) and nullish coalescing (`??`)
- **Never use non-null assertion (`!`)** unless provably safe — add a comment if you must

```ts
// ✅
const name = user?.profile?.displayName ?? 'Anonymous';

// ✅ If ! is unavoidable, explain why
const canvas = document.getElementById('canvas') as HTMLCanvasElement; // guaranteed by template

// ❌
const name = user!.profile!.displayName; // suppresses type safety silently
```

---

## Type Assertions (`as`)

Avoid `as` casting except when interfacing with untyped third-party code.
Never use `as any` — it is a full type system bypass.

```ts
// ✅ Acceptable — interfacing with untyped DOM
const input = event.target as HTMLInputElement;

// ❌ Never
const data = response as any;
```

---

## Imports

- Use path aliases (`@/`) — no deep relative chains
- Use `import type` for type-only imports (enforced by `@typescript-eslint/consistent-type-imports`)
- Group imports: external libraries → internal modules → types

```ts
// ✅
import { ref, computed } from 'vue';

import { useUserStore } from '@/stores/user';
import { apiClient } from '@/lib/api-client';

import type { UserDto } from '@/types/user';

// ❌
import { UserDto } from '../../../types/user';
```

---

## Classes

- Use `private`, `protected`, and `readonly` modifiers explicitly
- Avoid public class fields when a getter/method is more appropriate
- Do not use `static` methods unless the logic is genuinely stateless

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

Follows Airbnb JS `no-throw-literal` — only throw `Error` objects, never strings or plain objects.

```ts
// ✅
throw new Error('User not found');

// ✅ Custom error class
class NotFoundError extends Error {
  constructor(resource: string) {
    super(`${resource} not found`);
    this.name = 'NotFoundError';
  }
}

// ❌
throw 'User not found'; // eslint: no-throw-literal
throw { message: 'User not found' };
```

---

## What Claude Must Never Do

- Use `any` — use `unknown` and narrow explicitly
- Use `// @ts-ignore` or `// @ts-nocheck` — fix the type properly
- Use `as any` — it is an unconditional ban
- Add the `I` prefix to interfaces (`IUserDto`) — Airbnb convention does not use it
- Use `var` — `const` or `let` only
- Leave implicit `any` on function parameters or return types in exported code
- Skip `import type` for type-only imports