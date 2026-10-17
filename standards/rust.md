# Rust

## Overview

Standards for all Rust source files, including services, CLIs, and
libraries/crates.

Formatting is not a style choice in Rust - it is part of the language
toolchain. **Defer entirely to `rustfmt`'s default output.** Do not hand-format
code to look different from what `rustfmt` would produce, and do not restate
`rustfmt`'s rules here.

For public API design (naming, trait implementation patterns, error handling,
documentation conventions), the baseline is the **Rust API Guidelines**:
https://rust-lang.github.io/api-guidelines/

This file defines only the rules that differ from or extend those two
baselines. When in doubt, `rustfmt`'s output is authoritative for formatting
and the Rust API Guidelines are authoritative for API design.

---

## Rules That Override the Baseline

### No rule overrides defined.

Document project-specific exceptions here as they are identified.

---

## Rules That Match the Baseline (Key Reminders)

These rules are highlighted because they are commonly missed:

### Naming Conventions (Rust API Guidelines - C-CASE)

| Kind | Convention | Example |
|---|---|---|
| Crate/module | `snake_case` | `mod order_utils;` |
| Type/trait | `UpperCamelCase` | `struct Order`, `trait Processor` |
| Function/method/variable | `snake_case` | `fn get_order()` |
| Constant/static | `SCREAMING_SNAKE_CASE` | `const MAX_RETRIES: u32 = 3;` |
| Type parameter | short `UpperCamelCase`, usually single letter | `struct Wrapper<T>` |

### Error Handling

Use `Result<T, E>` for recoverable errors, never `panic!` for anything the
caller could reasonably expect to happen (missing record, invalid input,
network failure). Reserve `panic!` for programmer errors and invariant
violations:

```rust
// bad - caller can't recover, program crashes on a routine failure
fn get_order(id: u32) -> Order {
    orders.get(&id).unwrap().clone()
}

// good
fn get_order(id: u32) -> Result<Order, OrderError> {
    orders.get(&id).cloned().ok_or(OrderError::NotFound(id))
}
```

Implement `std::error::Error` for custom error types (or use a crate like
`thiserror` if the project has already adopted one) rather than inventing an
ad hoc error representation.

Use `?` to propagate errors instead of manual `match` + `return Err(...)`
boilerplate:

```rust
// bad
fn process(id: u32) -> Result<(), OrderError> {
    let order = match get_order(id) {
        Ok(o) => o,
        Err(e) => return Err(e),
    };
    Ok(())
}

// good
fn process(id: u32) -> Result<(), OrderError> {
    let order = get_order(id)?;
    Ok(())
}
```

### Ownership and Borrowing

Prefer borrowing (`&T`) over taking ownership when the function does not
need to consume or store the value:

```rust
// bad - takes ownership unnecessarily
fn order_total(order: Order) -> f64 {
    order.items.iter().map(|i| i.price).sum()
}

// good
fn order_total(order: &Order) -> f64 {
    order.items.iter().map(|i| i.price).sum()
}
```

Avoid `.clone()` as a way to silence a borrow-checker error without
understanding why the error occurred - restructure ownership instead unless
the clone is genuinely cheap and intentional.

### Documentation

Every public item gets a `///` doc comment. Crate-level and module-level
documentation uses `//!`:

```rust
/// Retrieves a single order by its database ID.
///
/// # Errors
///
/// Returns `OrderError::NotFound` if no order exists with the given ID.
pub fn get_order(id: u32) -> Result<Order, OrderError> {
    ...
}
```

### `unsafe`

Every `unsafe` block is preceded by a `// SAFETY:` comment explaining exactly
why the invariant the compiler cannot verify actually holds:

```rust
// SAFETY: `ptr` was allocated by `Vec::with_capacity(len)` above and `len`
// has not changed since, so this read is within bounds.
let value = unsafe { *ptr };
```

See `rust-security.md` for the full set of `unsafe`/FFI security checks.

### Iterators Over Manual Loops

Prefer iterator combinators (`map`, `filter`, `fold`) over manual index-based
loops when the logic is a straightforward transformation:

```rust
// bad
let mut total = 0.0;
for i in 0..items.len() {
    total += items[i].price;
}

// good
let total: f64 = items.iter().map(|item| item.price).sum();
```

---

## What Claude Must Not Do

- Do not hand-format code to differ from what `rustfmt` would produce
- Do not use `unwrap()`/`expect()` on a `Result`/`Option` that can plausibly
  be `Err`/`None` in production - propagate with `?` or handle explicitly
- Do not write an `unsafe` block without a `// SAFETY:` comment justifying it
- Do not use `.clone()` to work around a borrow-checker error without first
  understanding whether the ownership structure itself should change
- Do not leave a public item without a `///` doc comment
