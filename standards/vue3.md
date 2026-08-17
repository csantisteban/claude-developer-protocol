# Vue 3 Standards

**Based on:** [Official Vue.js Style Guide](https://vuejs.org/style-guide/) — Priority A (Essential) + B (Strongly Recommended) + C (Recommended)  
**Primary language:** TypeScript (`<script setup lang="ts">`)  
**Fallback language:** JavaScript (`<script setup>`) — acceptable for utility scripts, simple pages, or legacy integration  
**Enforced by:** `eslint-plugin-vue` + `@vue/eslint-config-typescript`

---

## Language Mode

TypeScript is the default for all new components and composables.
JavaScript is a **valid fallback** — use it when:
- The file is a simple utility with no component state
- You're integrating with a plain JS library with no types available
- A task explicitly calls for a JS-only file

> When writing JS, still use `<script setup>` and runtime prop definitions. Do not regress to the Options API.

---

## Toolchain Setup

```bash
npm install -D \
  eslint-plugin-vue \
  @vue/eslint-config-typescript \
  vue-tsc
```

**`eslint.config.ts` additions for Vue:**

```ts
import pluginVue from 'eslint-plugin-vue';

export default [
  ...pluginVue.configs['flat/recommended'],
  {
    rules: {
      'vue/component-api-style': ['error', ['script-setup']],
      'vue/define-macros-order': ['error', {
        order: ['defineOptions', 'defineProps', 'defineEmits', 'defineModel'],
      }],
      'vue/block-order': ['error', { order: ['script', 'template', 'style'] }],
    },
  },
];
```

---

## SFC Block Order

Always order `<script>`, `<template>`, and `<style>` tags consistently, with `<style>` last.

```vue
<!-- ✅ Always this order -->
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

## `<script setup>` — Always Use It

`<script setup>` is the required syntax for all new components.
The Options API is **not permitted** in new code.

**TypeScript (default):**

```vue
<script setup lang="ts">
import { ref, computed } from 'vue';
import type { UserDto } from '@/types/user';

interface Props {
  user: UserDto;
  showDetails?: boolean;
}

const props = withDefaults(defineProps<Props>(), {
  showDetails: false,
});

const emit = defineEmits<{
  'user-select': [user: UserDto];
  'dismiss': [];
}>();

const displayName = computed(() => props.user.displayName ?? 'Anonymous');
</script>
```

**JavaScript (fallback):**

```vue
<script setup>
import { ref, computed } from 'vue';

const props = defineProps({
  user: { type: Object, required: true },
  showDetails: { type: Boolean, default: false },
});

const emit = defineEmits(['user-select', 'dismiss']);

const displayName = computed(() => props.user.displayName ?? 'Anonymous');
</script>
```

---

## Naming Conventions

| Thing | Convention | Example |
|---|---|---|
| Component files | `PascalCase` | `UserCard.vue`, `BaseButton.vue` |
| Component names | Always multi-word | `UserCard`, not `Card` |
| Composables | `camelCase` with `use` prefix | `useAuth.ts`, `useUserStore.ts` |
| Pinia stores | `camelCase` with `use` prefix | `useCartStore.ts` |
| View/page files | `kebab-case` | `user-profile.vue` |
| Prop names | `camelCase` in script, `kebab-case` in template | `modelValue` / `:model-value` |
| Event names | `kebab-case` | `@user-select`, `@form-submit` |
| Types / Interfaces | `PascalCase` | `UserDto`, `CartItem` |

> Component names should always be multi-word, except for root `App` components and built-in components provided by Vue such as `<transition>` or `<component>`. This prevents conflicts with existing and future HTML elements, since all HTML elements are a single word.

---

## Props

### TypeScript (preferred)

Use type-based declaration with `defineProps<T>()`.
Use `withDefaults()` for default values.
Extract the interface when props are complex — do not inline large types.

```ts
// ✅ TypeScript — type-based declaration
interface Props {
  title: string;
  count?: number;
  status: 'active' | 'inactive';
}

const props = withDefaults(defineProps<Props>(), {
  count: 0,
});
```

**Vue 3.5+:** You can destructure props reactively:

```ts
// ✅ Vue 3.5+ reactive destructure
const { title, count = 0 } = defineProps<Props>();
```

### JavaScript (fallback)

Use runtime declaration with validators when there are constraints.

```js
// ✅ JavaScript — runtime declaration
const props = defineProps({
  title: { type: String, required: true },
  count: { type: Number, default: 0 },
  status: {
    type: String,
    default: 'active',
    validator: (val) => ['active', 'inactive'].includes(val),
  },
});
```

> Prop definitions should be as detailed as possible. In committed code, prop definitions should always be as detailed as possible, specifying at least type(s).

---

## Emits

### TypeScript (preferred)

Use the shorthand tuple syntax (Vue 3.3+):

```ts
// ✅ Succinct syntax (Vue 3.3+)
const emit = defineEmits<{
  'update:modelValue': [value: string];
  'user-select': [user: UserDto];
  'dismiss': [];
}>();
```

### JavaScript (fallback)

```js
// ✅ JavaScript
const emit = defineEmits(['update:modelValue', 'user-select', 'dismiss']);
```

---

## `v-model` — `defineModel`

Use `defineModel` for two-way binding (Vue 3.4+).

```ts
// ✅ TypeScript
const modelValue = defineModel<string>({ required: true });

// ✅ Named model
const [visible, visibleModifiers] = defineModel<boolean>('visible');
```

```js
// ✅ JavaScript fallback
const modelValue = defineModel({ required: true });
```

---

## Composables

- One concern per composable
- Always prefix with `use`
- Return a plain object — do not return reactive wrappers of the whole state
- Type all return values in TypeScript

```ts
// ✅ useAuth.ts
import { ref, computed } from 'vue';
import type { UserDto } from '@/types/user';

export function useAuth() {
  const user = ref<UserDto | null>(null);
  const isAuthenticated = computed(() => user.value !== null);

  async function login(email: string, password: string): Promise<void> {
    // ...
  }

  function logout(): void {
    user.value = null;
  }

  return { user, isAuthenticated, login, logout };
}
```

---

## Template Rules (Priority A — Essential)

### Always use `:key` with `v-for`

```html
<!-- ✅ -->
<li v-for="item in items" :key="item.id">{{ item.name }}</li>

<!-- ❌ -->
<li v-for="item in items">{{ item.name }}</li>
```

### Never use `v-if` and `v-for` on the same element

Never use `v-if` on the same element as `v-for`. Move `v-if` to a wrapper or use a computed list.

```html
<!-- ✅ Filter in computed, not in template -->
<li v-for="user in activeUsers" :key="user.id">{{ user.name }}</li>

<!-- ❌ -->
<li v-for="user in users" v-if="user.active" :key="user.id">{{ user.name }}</li>
```

### Scoped styles

Always scope component styles. Use `scoped` for leaf/presentational components.

```html
<!-- ✅ -->
<style scoped>
.card { ... }
</style>
```

---

## Template Rules (Priority B — Strongly Recommended)

### One attribute per line for multi-attribute elements

```html
<!-- ✅ -->
<UserCard
  :user="currentUser"
  :show-details="true"
  @user-select="handleSelect"
/>

<!-- ❌ -->
<UserCard :user="currentUser" :show-details="true" @user-select="handleSelect" />
```

### No logic in templates — use computed properties

Component templates should only include simple expressions, with more complex expressions refactored into computed properties or methods.

```html
<!-- ✅ -->
<span>{{ formattedDate }}</span>

<!-- ❌ -->
<span>{{ new Date(user.createdAt).toLocaleDateString('en-US', { year: 'numeric', month: 'long' }) }}</span>
```

### Self-closing components

```html
<!-- ✅ -->
<UserCard />
<BaseButton />

<!-- ❌ -->
<UserCard></UserCard>
```

### Component casing in templates

Use `PascalCase` in SFC templates. Use `kebab-case` only in DOM templates (non-compiled HTML).

```html
<!-- ✅ SFC template -->
<UserCard />
<BaseModal />
```

---

## Directory Structure

```
src/
├── assets/
├── components/        # Reusable UI components (PascalCase.vue)
│   └── base/          # App-wide base components (BaseButton.vue, BaseInput.vue)
├── composables/       # Composable functions (useAuth.ts)
├── router/
├── stores/            # Pinia stores (useUserStore.ts)
├── types/             # Shared TypeScript types and interfaces
├── utils/             # Pure utility functions (kebab-case.ts)
└── views/             # Route-level components (kebab-case.vue)
```

---

## Pinia Stores

Use the **setup store** syntax (composition-style) — not the options store.

```ts
// ✅ TypeScript — setup store
import { defineStore } from 'pinia';
import { ref, computed } from 'vue';
import type { UserDto } from '@/types/user';

export const useUserStore = defineStore('user', () => {
  const currentUser = ref<UserDto | null>(null);
  const isLoggedIn = computed(() => currentUser.value !== null);

  function setUser(user: UserDto): void {
    currentUser.value = user;
  }

  function clearUser(): void {
    currentUser.value = null;
  }

  return { currentUser, isLoggedIn, setUser, clearUser };
});
```

```js
// ✅ JavaScript fallback
import { defineStore } from 'pinia';
import { ref, computed } from 'vue';

export const useUserStore = defineStore('user', () => {
  const currentUser = ref(null);
  const isLoggedIn = computed(() => currentUser.value !== null);

  function setUser(user) { currentUser.value = user; }
  function clearUser() { currentUser.value = null; }

  return { currentUser, isLoggedIn, setUser, clearUser };
});
```

---

## Reactivity Guidelines

| Use | For |
|---|---|
| `ref()` | Primitives, nullable values, DOM refs |
| `reactive()` | Only when the entire object is always present and stable |
| `computed()` | Derived state — never recalculate in template |
| `watch()` | Side effects reacting to state changes |
| `watchEffect()` | When dependencies are implicit / collected automatically |

> Prefer `ref()` over `reactive()` for most cases — it is more predictable with destructuring and easier to type.

---

## What Claude Must Never Do

- Use the Options API (`data()`, `methods:`, `computed:`) in new components
- Use `<script>` without `setup` in new SFCs
- Put logic or expressions directly in templates — use computed properties
- Use `v-for` and `v-if` on the same element
- Omit `:key` on `v-for` loops
- Use relative import paths (`../../`) — use `@/` aliases
- Use unscoped styles in leaf components
- Mutate props directly — always emit or use `defineModel`
- Use Vuex — Pinia is the standard
- Skip type declarations on `defineProps` / `defineEmits` in TypeScript files