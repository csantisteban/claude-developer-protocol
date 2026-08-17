# C

## Overview

Standards for all C source files, including libraries, CLIs, and system-level
or embedded code.

The baseline target is **C17** (ISO/IEC 9899:2018) - effectively "C11 with
bugs fixed," the most stable and portable target, universally supported by
GCC, Clang, and MSVC. Prefer C17 over both older standards (C99) and newer
ones (C23) unless the project has an explicit reason to target something
else.

The standard version itself is not the primary lever for bug reduction -
compiler warnings and sanitizers are:

- **Compiler warnings as errors:** `-Wall -Wextra -Werror` (GCC/Clang)
- **Sanitizers in dev/test builds:** `-fsanitize=address,undefined`
- **Static analysis:** `clang-tidy` or `cppcheck` where available

This file defines the coding conventions Claude writes to by hand. It does
not configure or install any of the tools named above - see
`c-security.md` for the security-specific checklist (CERT C).

---

## Rules That Override the Baseline

### No rule overrides defined.

Document project-specific exceptions here as they are identified.

---

## Rules That Match the Baseline (Key Reminders)

These rules are highlighted because they are commonly missed:

### File Naming

Source and header files use `snake_case`:

```c
/* bad */
OrderUtils.c
OrderUtils.h

/* good */
order_utils.c
order_utils.h
```

### Header Guards

Every header uses an `#ifndef` guard (or `#pragma once` if the project has
already standardized on it) - never leave a header unguarded:

```c
/* good */
#ifndef ORDER_UTILS_H
#define ORDER_UTILS_H

/* declarations */

#endif /* ORDER_UTILS_H */
```

### Memory Ownership

Every function that returns a heap-allocated pointer documents who owns it
and who must free it, in a comment directly above the declaration:

```c
/* Returns a heap-allocated Order. Caller owns the returned pointer and
 * must call order_free() on it. */
Order *order_create(int id);
void order_free(Order *order);
```

Pair every `malloc`/`calloc` with an explicit, traceable `free` - never rely
on process exit to reclaim memory in long-running code paths.

### Explicit Initialization

Never leave a local variable uninitialized when it might be read before an
unconditional assignment:

```c
/* bad - uninitialized read possible on some paths */
int result;
if (condition) {
    result = compute();
}
return result;

/* good */
int result = 0;
if (condition) {
    result = compute();
}
return result;
```

### Return Value Checking

Check the return value of every function that can fail - `malloc`, file
I/O, and any project function returning an error code:

```c
/* bad */
char *buf = malloc(size);
strcpy(buf, input);

/* good */
char *buf = malloc(size);
if (buf == NULL) {
    return ERR_OUT_OF_MEMORY;
}
```

### Naming Conventions

| Kind | Convention | Example |
|---|---|---|
| Function | `snake_case` | `order_create()` |
| Type (`struct`/`enum`/`typedef`) | `snake_case_t` suffix | `typedef struct order order_t;` |
| Constant/macro | `UPPER_SNAKE_CASE` | `#define MAX_RETRIES 3` |
| Local variable | `snake_case` | `int retry_count` |

### Const Correctness

Mark pointer parameters `const` whenever the function does not modify what
they point to - this documents intent and lets the compiler catch accidental
mutation:

```c
/* good */
size_t order_id_length(const char *order_id);
```

### Struct Initialization

Use designated initializers for struct literals with more than two or three
fields - avoids positional-order bugs when the struct definition changes:

```c
/* bad - fragile if field order changes */
Order order = {1, "pending", 42.50};

/* good */
Order order = {
    .id = 1,
    .status = "pending",
    .total = 42.50,
};
```

---

## What Claude Must Not Do

- Do not leave a local variable uninitialized on a path where it could be
  read before assignment
- Do not ignore the return value of `malloc`, `calloc`, `realloc`, or any
  function that signals failure through its return value
- Do not use `gets()` - it has no bounds checking and is removed from the
  C11 standard library entirely; use `fgets()` instead
- Do not use `strcpy`/`strcat`/`sprintf` on buffers sized from anything
  other than a compile-time constant - use the bounded variants
  (`strncpy`/`strncat`/`snprintf`) and always verify truncation
- Do not leave a header file without an include guard
- Do not free a pointer without also documenting ownership at the point the
  pointer is created
