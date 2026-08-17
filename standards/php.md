# PHP

## Overview

Standards for all PHP source files, including web applications, APIs, and
Composer-based libraries.

The baseline is **PSR-12** (Extended Coding Style) for formatting:
https://www.php-fig.org/psr/psr-12/
and **PSR-4** (Autoloading) for namespace/file structure:
https://www.php-fig.org/psr/psr-4/

Both are the de facto industry standard, effectively mandatory for any
modern Composer-based PHP project. This file defines only the rules that
differ from or extend those baselines. When in doubt, PSR-12 governs
formatting and PSR-4 governs autoloading/namespace structure.

---

## Rules That Override the Baseline

### No rule overrides defined.

Document project-specific exceptions here as they are identified.

---

## Rules That Match the Baseline (Key Reminders)

These rules are highlighted because they are commonly missed:

### File Structure (PSR-4)

One class/interface/trait per file. The file path mirrors the fully
qualified namespace, and the filename matches the class name exactly:

```
// bad - multiple classes in one file
// src/Orders.php contains both Order and OrderRepository

// good
// src/Order.php
namespace App\Orders;
class Order { ... }

// src/OrderRepository.php
namespace App\Orders;
class OrderRepository { ... }
```

### Strict Types

Every file declares `strict_types=1` as the first statement:

```php
<?php

declare(strict_types=1);

namespace App\Orders;
```

### Type Declarations

Every method signature declares parameter types and a return type,
including `void` where nothing is returned:

```php
// bad
public function getOrder($id)
{
    ...
}

// good
public function getOrder(int $id): ?Order
{
    ...
}
```

### Braces (PSR-12)

Opening brace for classes and methods on its own line; opening brace for
control structures on the same line:

```php
// good
class OrderService
{
    public function getOrder(int $id): ?Order
    {
        if ($id < 1) {
            return null;
        }

        return $this->repository->find($id);
    }
}
```

### Visibility

Every property and method declares explicit visibility (`public`,
`protected`, `private`) - never omit it and rely on PHP's implicit `public`
default:

```php
// bad
function getTotal() { ... }
var $total;

// good
private float $total;

public function getTotal(): float
{
    return $this->total;
}
```

### Null Coalescing and Nullsafe Operators

Prefer `??`/`??=` over `isset()` + ternary, and `?->` over chained
`isset()` checks for nullable object chains:

```php
// bad
$name = isset($order->customer) ? $order->customer->name : 'Unknown';

// good
$name = $order->customer?->name ?? 'Unknown';
```

### Constructor Property Promotion

Use constructor property promotion (PHP 8+) instead of manually declaring
and assigning each property when there is no additional logic in the
constructor:

```php
// bad - PHP 7 style, unnecessary boilerplate on PHP 8+
class Order
{
    private int $id;
    private string $status;

    public function __construct(int $id, string $status)
    {
        $this->id = $id;
        $this->status = $status;
    }
}

// good
class Order
{
    public function __construct(
        private int $id,
        private string $status,
    ) {
    }
}
```

### Exceptions

Throw specific exception classes, never the generic `\Exception`. Catch the
narrowest type possible:

```php
// bad
throw new \Exception('Order not found');

// good
throw new OrderNotFoundException("Order not found: {$id}");
```

---

## What Claude Must Not Do

- Do not omit `declare(strict_types=1)` from a new file
- Do not omit a type declaration on a method parameter or return type
- Do not omit explicit visibility on a property or method
- Do not put more than one class/interface/trait in a single file
- Do not throw or catch the generic `\Exception` class directly
- Do not use `list()`/array destructuring without keys when named keys
  would make the intent clearer
