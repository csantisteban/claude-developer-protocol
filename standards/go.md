# Go

## Overview

Standards for all Go source files, including services, CLIs, libraries, and
internal tooling.

The baseline is the **official Go style documentation**, which comprises three
layers — each more prescriptive than the last:

- **Go Style Guide:** https://google.github.io/styleguide/go/guide
- **Go Style Decisions:** https://google.github.io/styleguide/go/decisions
- **Go Best Practices:** https://google.github.io/styleguide/go/best-practices

This file defines only the rules that differ from or extend that baseline.
When in doubt, the Google Go Style Guide is the authority.

Formatting is enforced via **gofmt** (built into the toolchain) and **goimports**
for import ordering. Linting is enforced via **golangci-lint**:
https://golangci-lint.run

All files must be `gofmt`-clean and pass `golangci-lint run` with no errors
before being committed.

---

## Rules That Override the Google Baseline

### No rule overrides defined.

Document project-specific exceptions here as they are identified.

---

## Rules That Match the Baseline (Key Reminders)

These rules are highlighted because they are commonly missed:

### Package Names

Package names must be lowercase, single words with no underscores or mixed
case. The package name is part of the API — choose it so callers read well:

```go
// bad
package orderUtils
package order_utils
package OrderUtils

// good
package order
package api
package config
```

Never use generic names like `util`, `common`, or `helpers` — they create
ambiguity. Name the package after what it provides, not what it is.

### File Naming

Use `snake_case` for all Go source files:

```
// bad
orderHandler.go
OrderHandler.go

// good
order_handler.go
order_handler_test.go
```

### Error Handling

Every error must be handled or explicitly discarded with a comment explaining
why. Never use `_` to silently drop an error without a reason:

```go
// bad
result, _ = doSomething()

// good — failure is non-fatal in this specific case
result, _ = cache.Get(key) // cache miss is acceptable; caller falls back to DB

// good — handle it
result, err := doSomething()
if err != nil {
    return fmt.Errorf("doSomething: %w", err)
}
```

Wrap errors with `fmt.Errorf("context: %w", err)` — never discard the original
error when propagating. The wrapping message should describe what the caller was
doing, not what the callee did:

```go
// bad — describes the callee
return fmt.Errorf("sql query failed: %w", err)

// good — describes the caller's intent
return fmt.Errorf("fetch order %d: %w", id, err)
```

### Named Return Values

Avoid named return values except in short functions (under 5 lines) or when
they materially improve clarity in a defer. They make error paths harder to
follow in longer functions:

```go
// bad
func getOrder(id int) (order Order, err error) {
    order, err = db.Find(id)
    return
}

// good
func getOrder(id int) (Order, error) {
    order, err := db.Find(id)
    if err != nil {
        return Order{}, fmt.Errorf("get order %d: %w", id, err)
    }
    return order, nil
}
```

### Variable Declarations

Prefer short variable declaration (`:=`) inside functions. Use `var` only for
zero values or when the type needs to be explicit:

```go
// bad
var name string = "Carlos"
var count int = 0

// good
name := "Carlos"
var count int  // zero value is meaningful
```

### Constants and Enumerations

Group constants in a `const` block. Use `iota` for ordered enumerations:

```go
// bad
const StatusOpen = 1
const StatusClosed = 2

// good
const (
    StatusOpen = iota + 1
    StatusClosed
)
```

### Structs

Define struct fields in logical groups, not alphabetical order. Export only
fields that callers need; keep implementation details unexported:

```go
// good
type Order struct {
    ID        int
    UserID    int
    CreatedAt time.Time

    total     float64  // unexported — computed, not stored directly
}
```

Use constructor functions (`NewOrder(...)`) instead of direct struct literals
for any type that has invariants to enforce.

### Interfaces

Define interfaces at the point of use (in the package that consumes them), not
in the package that implements them. Keep interfaces small — one to three
methods is the norm:

```go
// bad — defined in the implementation package
package order
type OrderRepository interface { ... }

// good — defined in the consumer package
package api
type orderStore interface {
    FindByID(ctx context.Context, id int) (order.Order, error)
}
```

### Context

Every function that performs I/O, calls an external service, or runs a query
must accept a `context.Context` as its first parameter, named `ctx`:

```go
// bad
func fetchOrder(id int) (Order, error)

// good
func fetchOrder(ctx context.Context, id int) (Order, error)
```

Never store a `context.Context` in a struct — pass it through the call chain.

### Goroutines and Channels

Never start a goroutine without knowing when and how it will stop. Document the
lifecycle in a comment if it is not obvious from the code:

```go
// bad — goroutine leaks if the channel is never closed
go func() {
    for msg := range ch {
        process(msg)
    }
}()

// good — lifetime is bounded by the parent context
go func() {
    for {
        select {
        case <-ctx.Done():
            return
        case msg := <-ch:
            process(msg)
        }
    }
}()
```

Use `sync.WaitGroup` or `errgroup.Group` (from `golang.org/x/sync/errgroup`)
to coordinate goroutine lifecycle — never rely on `time.Sleep` to wait for
goroutines.

### Imports

Group imports into three blocks, separated by blank lines:

1. Standard library
2. External (third-party) packages
3. Internal packages (within this module)

`goimports` enforces this automatically. Do not reorder manually:

```go
import (
    "context"
    "fmt"

    "github.com/some/library"

    "example.com/myapp/internal/order"
)
```

### Comments

Every exported symbol (function, type, constant, variable) must have a doc
comment. The comment must begin with the symbol's name:

```go
// bad
// Fetches an order by ID.
func GetOrder(ctx context.Context, id int) (Order, error)

// good
// GetOrder retrieves a single order by its database ID.
// Returns an error wrapping sql.ErrNoRows if the record does not exist.
func GetOrder(ctx context.Context, id int) (Order, error)
```

Use `//` for all comments — never `/* */` except for build tags.

---

## Testing

Test files live alongside the code they test, named `<file>_test.go`.

Use table-driven tests for functions with multiple input/output cases:

```go
func TestGetOrder(t *testing.T) {
    tests := []struct {
        name    string
        id      int
        want    Order
        wantErr bool
    }{
        {"valid id", 1, Order{ID: 1}, false},
        {"missing id", 999, Order{}, true},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := GetOrder(context.Background(), tt.id)
            if (err != nil) != tt.wantErr {
                t.Fatalf("GetOrder() error = %v, wantErr %v", err, tt.wantErr)
            }
            if got != tt.want {
                t.Errorf("GetOrder() = %v, want %v", got, tt.want)
            }
        })
    }
}
```

Never use `t.Log` for assertions — use `t.Errorf` or `t.Fatalf`. Prefer the
standard library over assertion libraries unless the project has already
adopted one.

---

## What Claude Must Not Do

- Do not ignore returned errors without a comment explaining why
- Do not wrap errors without context — always use `fmt.Errorf("context: %w", err)`
- Do not store `context.Context` in a struct
- Do not start goroutines without a defined exit condition
- Do not use generic package names: `util`, `common`, `helpers`, `misc`
- Do not define interfaces in the implementation package
- Do not commit files that are not `gofmt`-clean or produce `golangci-lint` errors
- Do not use `init()` functions unless absolutely necessary — prefer explicit initialization
