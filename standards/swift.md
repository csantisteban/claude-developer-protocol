# Swift

## Overview

Standards for all Swift source files, including iOS/macOS applications,
server-side Swift, and libraries.

Two baselines apply together:

- **Swift API Design Guidelines** (Apple) - non-negotiable for naming and
  public API shape, this is where Swift's actual design philosophy lives:
  https://www.swift.org/documentation/api-design-guidelines/
- **Google Swift Style Guide** - for formatting consistency, since Apple's
  own guidelines don't cover formatting in depth:
  https://google.github.io/swift/

Swift's biggest quality lever is not formatting - it is **API clarity and
correct use of the type system**: optionals, value vs. reference types, and
avoiding force-unwraps. This file weights those concerns accordingly.

---

## Rules That Override the Baseline

### No rule overrides defined.

Document project-specific exceptions here as they are identified.

---

## Rules That Match the Baseline (Key Reminders)

These rules are highlighted because they are commonly missed:

### Naming (Swift API Design Guidelines)

Name methods and functions so call sites read as grammatical English -
this is the guidelines' central principle:

```swift
// bad - doesn't read naturally at the call site
x.insert(y, position: z)
// call site: x.insert(y, position: z)

// good
x.insert(y, at: z)
// call site: x.insert(y, at: z)
```

Types and protocols use `UpperCamelCase`; everything else (methods,
properties, variables) uses `lowerCamelCase`:

```swift
struct Order { }
protocol OrderRepository { }

func getOrder(id: Int) -> Order? { }
var orderCount: Int
```

Omit needless words - a parameter name should not repeat what the type
already makes obvious:

```swift
// bad - redundant
func removeElement(_ element: Element)

// good
func remove(_ element: Element)
```

### Optionals

Never force-unwrap (`!`) a value unless its presence is a genuine, provable
invariant at that point in the code - not "it's usually there":

```swift
// bad - crashes if the order is missing
let order = orders[id]!

// good
guard let order = orders[id] else {
    return nil
}
```

Prefer `guard let`/`if let` over optional chaining with a silent fallback
when the absence of a value is a condition the caller needs to know about,
not just paper over:

```swift
// risky - silently no-ops if order is nil, caller can't tell why nothing happened
order?.process()

// good - the absence is visible
guard let order else {
    throw OrderError.notFound
}
order.process()
```

Use `if let name { }` shorthand (Swift 5.7+) instead of `if let name = name { }`.

### Value Types vs. Reference Types

Default to `struct` for data models; use `class` only when reference
semantics (shared mutable state, identity, inheritance) are actually
required:

```swift
// good - default to struct, value semantics prevent accidental shared mutation
struct Order {
    let id: Int
    var status: OrderStatus
}

// good - class only because identity/shared mutable state is the point
class OrderCache {
    private var cache: [Int: Order] = [:]
}
```

### Error Handling

Use Swift's `throws`/`try`/`catch` for recoverable errors. Never use `try!`
outside of a context where failure is provably impossible (the same bar as
force-unwrapping):

```swift
// bad
let order = try! fetchOrder(id: id)

// good
do {
    let order = try fetchOrder(id: id)
} catch {
    // handle
}
```

Define error types conforming to `Error`, ideally an `enum` with associated
values for structured failure information:

```swift
enum OrderError: Error {
    case notFound(id: Int)
    case invalidStatus(String)
}
```

### Access Control

Mark every type and member with the narrowest access level that works -
default to `internal` (Swift's implicit default is fine for most module-
internal code), use `private`/`fileprivate` for implementation details, and
`public`/`open` only for genuine external API:

```swift
// good
private var cache: [Int: Order] = [:]

public struct Order {
    public let id: Int
    private var internalNotes: String
}
```

### Documentation Comments

Public APIs get `///` documentation comments:

```swift
/// Retrieves a single order by its database ID.
/// - Parameter id: The primary key of the order to fetch.
/// - Returns: The matching order, or `nil` if not found.
func getOrder(id: Int) -> Order? {
    ...
}
```

---

## What Claude Must Not Do

- Do not force-unwrap (`!`) an optional unless its presence is a provable
  invariant, not just an assumption
- Do not use `try!` outside a context where failure is provably impossible
- Do not default to `class` when `struct` value semantics would work
- Do not name a parameter redundantly with information the type already
  conveys
- Do not mark a type or member `public`/`open` unless it is genuine external
  API
- Do not leave a public API without a `///` documentation comment
