# Vue 3

## Overview

Standards for Vue 3 single-file components (`.vue`), composables, and Pinia
stores.

The baseline is the **official Vue Style Guide**, Priority A (Essential),
B (Strongly Recommended), and C (Recommended):
https://vuejs.org/style-guide/

It is enforced by the Vue team's own tooling:

- **`eslint-plugin-vue`** (`flat/recommended`) - the style guide's rules
- **`@vue/eslint-config-typescript`** - typescript-eslint's rules adapted
  for `.vue` files
- **`@vue/eslint-config-prettier/skip-formatting`** - leaves formatting to
  Prettier

This file builds on `typescript.md` and `javascript.md`; their rules apply to
the `<script>` block and to `.ts` files.

---

## Language

Components are written in TypeScript: `<script setup lang="ts">`. The
official TypeScript config assumes every `<script>` block is TypeScript and
discourages plain JavaScript in `.vue` files, because it causes false
positives and negatives in the typed rules.

If a project must allow JavaScript `<script>` blocks (e.g. while migrating
an existing codebase), pass `{ scriptLangs: ['ts', 'js'] }` as the first
argument to `withVueTs()` and set `allowJs` and `checkJs` in `tsconfig.json`.
Treat that as temporary. Plain `.js` files outside components follow
`javascript.md`.

---

## Toolchain Setup

```bash
npm install -D eslint eslint-plugin-vue @vue/eslint-config-typescript \
  @vue/eslint-config-prettier prettier typescript vue-tsc
```

**`eslint.config.js`:**

```js
import skipFormatting from '@vue/eslint-config-prettier/skip-formatting';
import { vueTsConfigs, withVueTs } from '@vue/eslint-config-typescript';
import pluginVue from 'eslint-plugin-vue';

export default withVueTs(
  pluginVue.configs['flat/recommended'],
  vueTsConfigs.recommendedTypeChecked,
  {
    rules: {
      'vue/component-api-style': ['error', ['script-setup']],
      'vue/block-order': ['error', { order: ['script', 'template', 'style'] }],
      'vue/define-macros-order': ['error', {
        order: ['defineOptions', 'defineProps', 'defineEmits', 'defineModel'],
      }],
    },
  },
  skipFormatting, // last
);
```

`recommendedTypeChecked` is the Vue team's recommended starting point.
`vueTsConfigs.strictTypeChecked` matches `typescript.md` more closely and can
be used once the project lints cleanly.

Type-check components with `vue-tsc --noEmit` - ESLint does not report
compiler errors.

---

## SFC Block Order (`vue/block-order`)

Always `<script>`, then `<template>`, then `<style>`:

```vue
<script setup lang="ts">
// ...
</script>

<template>
  <!-- ... -->
</template>

<style scoped>
/* ... */
</style>
```

---

## `<script setup>` - Always Use It (`vue/component-api-style`)

`<script setup>` is required for all components. The Options API
(`data()`, `methods:`, `computed:`) is not permitted in new code.

```vue
<script setup lang="ts">
import { computed } from 'vue';

import type { UserDto } from '@/types/user';

interface Props {
  user: UserDto;
  showDetails?: boolean;
}

const { user, showDetails = false } = defineProps<Props>();

const emit = defineEmits<{
  'user-select': [user: UserDto];
  dismiss: [];
}>();

const displayName = computed(() => user.displayName ?? 'Anonymous');
</script>
```

---

## Naming Conventions

| Thing | Convention | Example |
|---|---|---|
| Component files | `PascalCase`, always multi-word (`vue/multi-word-component-names`) | `UserCard.vue`, `BaseButton.vue` |
| Route-level components | `PascalCase`, ending in `View` | `UserProfileView.vue` |
| Composables | `camelCase` with `use` prefix | `useAuth.ts` |
| Pinia stores | `camelCase` with `use` prefix and `Store` suffix | `useCartStore.ts` |
| Other `.ts` files | `kebab-case` (see `typescript.md`) | `format-price.ts` |
| Props | `camelCase` in script, `kebab-case` in template | `modelValue` / `:model-value` |
| Events | `kebab-case` | `@user-select` |
| Types and interfaces | `PascalCase` | `UserDto` |

Multi-word component names avoid clashes with current and future HTML
elements, which are all single words. Root `App` and Vue's built-in
components are the exception.

---

## Props

Use type-based declaration with `defineProps<T>()` and reactive props
destructuring for defaults (Vue 3.5+). Extract the interface when props are
complex - do not inline large types:

```ts
interface Props {
  title: string;
  count?: number;
  status: 'active' | 'inactive';
}

const { title, count = 0, status } = defineProps<Props>();
```

Never mutate a prop (`vue/no-mutating-props`) - emit an event or use
`defineModel`.

---

## Emits

Use the named-tuple syntax:

```ts
const emit = defineEmits<{
  'update:modelValue': [value: string];
  'user-select': [user: UserDto];
  dismiss: [];
}>();
```

---

## `v-model` - `defineModel`

Use `defineModel` for two-way binding:

```ts
const modelValue = defineModel<string>({ required: true });

// named model with modifiers
const [visible, visibleModifiers] = defineModel<boolean>('visible');
```

---

## Composables

- One concern per composable
- Always prefix with `use`
- Return a plain object of refs and functions, not one reactive wrapper of
  the whole state
- Type all return values

```ts
// useAuth.ts
import { computed, ref } from 'vue';

import type { UserDto } from '@/types/user';

export function useAuth() {
  const user = ref<UserDto | undefined>();
  const isAuthenticated = computed(() => user.value !== undefined);

  async function login(email: string, password: string): Promise<void> {
    // ...
  }

  function logout(): void {
    user.value = undefined;
  }

  return { user, isAuthenticated, login, logout };
}
```

---

## Template Rules (Priority A - Essential)

### Always use `:key` with `v-for` (`vue/require-v-for-key`)

```html
<!-- good -->
<li v-for="item in items" :key="item.id">{{ item.name }}</li>

<!-- bad -->
<li v-for="item in items">{{ item.name }}</li>
```

### Never use `v-if` and `v-for` on the same element (`vue/no-use-v-if-with-v-for`)

Filter in a computed list, or move `v-if` to a wrapper:

```html
<!-- good -->
<li v-for="user in activeUsers" :key="user.id">{{ user.name }}</li>

<!-- bad -->
<li v-for="user in users" v-if="user.active" :key="user.id">{{ user.name }}</li>
```

### Scoped styles

Scope component styles with `scoped` (or CSS modules). Only the root `App`
component and layout components may use global styles.

---

## Template Rules (Priority B - Strongly Recommended)

### No logic in templates

Templates contain only simple expressions. Move anything more complex into a
computed property or function:

```html
<!-- good -->
<span>{{ formattedDate }}</span>

<!-- bad -->
<span>{{ new Date(user.createdAt).toLocaleDateString('en-US', { year: 'numeric', month: 'long' }) }}</span>
```

### Component casing

Use `PascalCase` for components in SFC templates, and self-close components
that have no content:

```html
<!-- good -->
<UserCard :user="currentUser" />

<!-- bad -->
<user-card :user="currentUser"></user-card>
```

Use `kebab-case` only in in-DOM templates (HTML that is not compiled).

Line breaks and attribute wrapping are left to Prettier.

---

## Directory Structure

```
src/
├── assets/
├── components/        # Reusable components (UserCard.vue)
│   └── base/          # App-wide base components (BaseButton.vue, BaseInput.vue)
├── composables/       # Composables (useAuth.ts)
├── router/
├── stores/            # Pinia stores (useUserStore.ts)
├── types/             # Shared types and interfaces
├── utils/             # Pure utility functions (format-price.ts)
└── views/             # Route-level components (UserProfileView.vue)
```

---

## Pinia Stores

Pinia is the state-management standard. Use the **setup store** syntax, not
the options store:

```ts
// stores/useUserStore.ts
import { defineStore } from 'pinia';
import { computed, ref } from 'vue';

import type { UserDto } from '@/types/user';

export const useUserStore = defineStore('user', () => {
  const currentUser = ref<UserDto | undefined>();
  const isLoggedIn = computed(() => currentUser.value !== undefined);

  function setUser(user: UserDto): void {
    currentUser.value = user;
  }

  function clearUser(): void {
    currentUser.value = undefined;
  }

  return { currentUser, isLoggedIn, setUser, clearUser };
});
```

---

## Reactivity Guidelines

| Use | For |
|---|---|
| `ref()` | Primitives, optional values, DOM refs - the default |
| `reactive()` | Only when the whole object is always present and stable |
| `computed()` | Derived state - never recalculate in the template |
| `watch()` | Side effects reacting to specific state changes |
| `watchEffect()` | Side effects whose dependencies are collected automatically |

Prefer `ref()` over `reactive()` - it behaves predictably when destructured
and is easier to type.

---

## What Claude Must Never Do

- Use the Options API (`data()`, `methods:`, `computed:`) in new components
- Use `<script>` without `setup`, or plain JavaScript `<script>` blocks,
  unless the project has opted in via `scriptLangs`
- Put logic or complex expressions in templates - use computed properties
- Use `v-for` and `v-if` on the same element
- Omit `:key` on `v-for`
- Use deep relative imports (`../../`) - use `@/` aliases
- Use unscoped styles in components other than `App` and layouts
- Mutate props - emit an event or use `defineModel`
- Use Vuex - Pinia is the standard
- Skip type declarations on `defineProps` / `defineEmits`
