# Ruby

## Overview

Standards for all Ruby source files, including web applications (Rails or
otherwise), gems, and scripts.

The baseline is **The Ruby Style Guide** (Bozhidar Batsov, community-
maintained): https://rubystyle.guide

This file defines only the rules that differ from or extend that baseline.
When in doubt, The Ruby Style Guide is the authority.

---

## Rules That Override the Baseline

### No rule overrides defined.

Document project-specific exceptions here as they are identified.

---

## Rules That Match the Baseline (Key Reminders)

These rules are highlighted because they are commonly missed:

### Naming Conventions

| Kind | Convention | Example |
|---|---|---|
| Method/variable | `snake_case` | `def get_order` |
| Class/Module | `CamelCase` | `class OrderProcessor` |
| Constant | `SCREAMING_SNAKE_CASE` | `MAX_RETRIES = 3` |
| Predicate method (returns boolean) | ends in `?`, no `is_`/`has_` prefix | `def valid?`, not `def is_valid?` |
| Dangerous/mutating method | ends in `!` | `def normalize!` |

### Formatting

2-space indentation, no semicolons, single quotes for strings with no
interpolation, double quotes only when interpolating or when the string
contains a character that would need escaping in single quotes:

```ruby
# bad
name = "Carlos";
greeting = "Hello, #{name}"

# good
name = 'Carlos'
greeting = "Hello, #{name}"
```

### Guard Clauses

Prefer a guard clause with `unless`/`return` over nesting the entire method
body inside a conditional:

```ruby
# bad
def process_order(order)
  if order.valid?
    # ... entire method body nested here
  end
end

# good
def process_order(order)
  return unless order.valid?

  # ... method body at the top level
end
```

### `unless` Over `if !`

Use `unless` for a negative condition instead of `if !` - but only for
simple conditions with no `else`; an `unless`/`else` pair reads worse than
a plain `if`:

```ruby
# bad
if !order.valid?
  return nil
end

# good
return nil unless order.valid?

# bad - unless/else is harder to read than if/else
unless order.valid?
  handle_invalid
else
  process
end

# good
if order.valid?
  process
else
  handle_invalid
end
```

### `&&`/`||` Over `and`/`or`

Use `&&`/`||` for boolean logic in expressions. `and`/`or` have different
(lower) precedence and are reserved for control-flow-style statement
separation, not boolean expressions:

```ruby
# bad - "and" has lower precedence than "=", this doesn't do what it looks like
valid = order.present? and order.total > 0

# good
valid = order.present? && order.total > 0
```

### Symbols Over Strings for Identifiers

Use symbols for internal identifiers (hash keys, method names passed as
arguments) - only use strings for actual textual data:

```ruby
# bad
config = { "timeout" => 30, "retries" => 3 }

# good
config = { timeout: 30, retries: 3 }
```

### Blocks

Use `{ }` for single-line blocks, `do...end` for multi-line blocks:

```ruby
# good - single line
orders.each { |order| process(order) }

# good - multi-line
orders.each do |order|
  validate(order)
  process(order)
end
```

### Memoization

Use `||=` for simple memoization, but never for a value that could
legitimately be `false` or `nil` as a valid result - that breaks the
memoization silently:

```ruby
# good - value is never falsy
def orders
  @orders ||= fetch_orders
end

# bad - if valid? legitimately returns false, this recomputes every time
def valid?
  @valid ||= compute_validity
end
```

---

## What Claude Must Not Do

- Do not use `and`/`or` for boolean expressions - use `&&`/`||`
- Do not prefix a predicate method with `is_`/`has_` - use a trailing `?`
  instead
- Do not nest a method's entire body inside a conditional when a guard
  clause would flatten it
- Do not use `||=` to memoize a method that can legitimately return `false`
  or `nil`
- Do not use string keys for internal hash identifiers where a symbol fits
