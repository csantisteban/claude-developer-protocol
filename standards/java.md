# Java

## Overview

Standards for all Java source files, including services, libraries, and
Android/enterprise application code.

The baseline is the **Google Java Style Guide**:
https://google.github.io/styleguide/javaguide.html

This file defines only the rules that differ from or extend that baseline.
When in doubt, the Google Java Style Guide is the authority. It is precisely
specified (exact brace placement, 2-space indentation, enforceable via
`google-java-format`) - this file assumes that level of precision and does
not restate it.

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
| Package | all lowercase, no underscores | `com.example.orders` |
| Class/interface | `UpperCamelCase` | `class OrderProcessor` |
| Method/variable | `lowerCamelCase` | `getOrder()` |
| Constant (`static final`) | `UPPER_SNAKE_CASE` | `static final int MAX_RETRIES = 3;` |

### Immutability

Prefer `final` for local variables, parameters, and fields unless the value
is genuinely reassigned. Prefer immutable objects (`List.of`, records,
builders producing a fully-constructed object) over mutable ones that are
exposed outside the class that owns them:

```java
// bad - exposes a mutable internal list
public List<Item> getItems() {
    return items;
}

// good
public List<Item> getItems() {
    return Collections.unmodifiableList(items);
}
```

### Exceptions

Catch the narrowest exception type possible. Never catch `Exception` or
`Throwable` broadly unless the code is at a top-level boundary (a request
handler, a `main` method) that must not propagate any failure further:

```java
// bad
try {
    order = fetchOrder(id);
} catch (Exception e) {
    order = null;
}

// good
try {
    order = fetchOrder(id);
} catch (OrderNotFoundException e) {
    order = null;
}
```

Never swallow an exception silently - at minimum, log it with enough context
to diagnose the failure. An empty `catch` block is never acceptable.

Prefer unchecked exceptions for programmer errors and checked exceptions
only for conditions a caller can reasonably be expected to recover from.

### Optional

Use `Optional<T>` as a return type to signal "may be absent" - never as a
field type or a method parameter type:

```java
// bad - Optional as a field
private Optional<String> nickname;

// good
private String nickname; // null if absent, or use a sentinel per project convention

// good - Optional as a return type
public Optional<Order> findOrder(long id) {
    ...
}
```

### Dependency Injection

Prefer constructor injection over field injection - it makes dependencies
explicit and enables immutability (`final` fields):

```java
// bad
@Autowired
private OrderRepository repository;

// good
private final OrderRepository repository;

public OrderService(OrderRepository repository) {
    this.repository = repository;
}
```

### Streams

Use the Streams API for genuine transform/filter/collect pipelines. Fall
back to an explicit loop once the stream chain needs more than two or three
operations or has side effects - readability over cleverness:

```java
// good - simple pipeline
List<Long> ids = orders.stream()
    .filter(o -> o.getStatus() == Status.OPEN)
    .map(Order::getId)
    .collect(Collectors.toList());

// bad - side-effecting stream, hard to reason about
orders.stream().forEach(o -> { o.setStatus(CLOSED); auditLog.record(o); });

// good - the same logic as an explicit loop
for (Order o : orders) {
    o.setStatus(CLOSED);
    auditLog.record(o);
}
```

### Javadoc

Every public class and method gets a Javadoc comment - summary line,
`@param`, `@return`, `@throws` as applicable:

```java
/**
 * Retrieves a single order by its database ID.
 *
 * @param id the primary key of the order to fetch
 * @return the matching order
 * @throws OrderNotFoundException if no order exists with the given ID
 */
public Order getOrder(long id) throws OrderNotFoundException {
    ...
}
```

---

## What Claude Must Not Do

- Do not catch `Exception` or `Throwable` outside a top-level boundary
- Do not leave a `catch` block empty - always log or rethrow
- Do not use `Optional` as a field type or method parameter type
- Do not expose a mutable collection field directly from a getter
- Do not use field injection when constructor injection is available
- Do not leave a public class or method without a Javadoc comment
