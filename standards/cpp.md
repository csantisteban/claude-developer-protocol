# C++

## Overview

Standards for all C++ source files, including services, libraries, and
performance-sensitive or embedded code.

The baseline is the **Google C++ Style Guide**:
https://google.github.io/styleguide/cppguide.html

This file defines only the rules that differ from or extend that baseline.
When in doubt, the Google C++ Style Guide is the authority. Target a modern
C++ standard (C++17 or later) and prefer modern idioms (RAII, smart
pointers, `std::` algorithms) over C-style manual resource management -
memory safety is this language's central risk, and modern C++ exists largely
to make that risk manageable.

---

## Rules That Override the Baseline

### No rule overrides defined.

Document project-specific exceptions here as they are identified.

---

## Rules That Match the Baseline (Key Reminders)

These rules are highlighted because they are commonly missed:

### File Naming

Source and header files use `snake_case`:

```cpp
// bad
OrderUtils.cpp
OrderUtils.h

// good
order_utils.cpp
order_utils.h
```

### RAII Over Manual Resource Management

Every resource (memory, file handle, lock, socket) is owned by an object
whose destructor releases it. Never pair a manual acquire with a manual
release when an RAII wrapper is available:

```cpp
// bad - leaks on early return or exception
Order* order = new Order();
if (!valid) {
    return;  // leaked
}
delete order;

// good
auto order = std::make_unique<Order>();
if (!valid) {
    return;  // destructor runs automatically
}
```

### Smart Pointers Over Raw Owning Pointers

Use `std::unique_ptr` for exclusive ownership, `std::shared_ptr` only when
shared ownership is a genuine requirement (not a default). Raw pointers are
fine for non-owning references, never for ownership:

```cpp
// bad - unclear ownership
Order* create_order();

// good - ownership is explicit in the type
std::unique_ptr<Order> create_order();

// good - raw pointer used only as a non-owning view
void process(const Order* order);
```

### `const` Correctness

Mark parameters, methods, and variables `const` whenever they are not
mutated. Pass non-trivial types by `const&` instead of by value unless the
function needs its own copy:

```cpp
// bad - unnecessary copy
void process(std::string order_id);

// good
void process(const std::string& order_id);

// good - method that doesn't mutate state
double total() const;
```

### Naming Conventions

| Kind | Convention | Example |
|---|---|---|
| Class/struct | `UpperCamelCase` | `class OrderProcessor` |
| Function/method | `lowerCamelCase` (Google) or project-established convention | `getOrder()` |
| Variable | `snake_case` | `int retry_count` |
| Constant | `kCamelCase` (Google convention) | `constexpr int kMaxRetries = 3;` |
| Private member | trailing underscore | `int retry_count_;` |

### Initialization

Prefer brace initialization and always initialize variables at the point of
declaration - never leave a variable in an indeterminate state:

```cpp
// bad
int count;
if (condition) {
    count = compute();
}

// good
int count = condition ? compute() : 0;
```

### Rule of Zero / Rule of Five

If a class manages a resource directly, it must define all five special
member functions (destructor, copy constructor, copy assignment, move
constructor, move assignment) or explicitly `= delete` the ones that don't
apply. Prefer the Rule of Zero - let RAII members handle resource lifetime
so the class needs none of the five defined manually:

```cpp
// good - Rule of Zero: no manual resource management, no special members needed
class OrderCache {
    std::unordered_map<int, Order> cache_;
    std::mutex mutex_;
};
```

### Exceptions vs Error Codes

Follow whatever error-handling convention the project has already
established (exceptions or `std::expected`/error-code returns) consistently
- do not mix both styles for the same category of error within one
codebase.

---

## What Claude Must Not Do

- Do not use `new`/`delete` directly when a smart pointer or standard
  container can express the same ownership
- Do not leave a variable uninitialized at its declaration
- Do not write a class that manages a resource without following the Rule of
  Zero/Five for its special member functions
- Do not pass a non-trivial type by value when `const&` is sufficient
- Do not use a raw pointer to express ownership
- Do not use C-style casts (`(Type)value`) - use `static_cast`,
  `dynamic_cast`, `const_cast`, or `reinterpret_cast` explicitly
