# Python

## Overview

Standards for all Python source files, including services, CLIs, libraries,
scripts, and tooling.

The baseline is the **Google Python Style Guide**:
https://google.github.io/styleguide/pyguide.html

This file defines only the rules that differ from or extend that baseline.
When in doubt, the Google Python Style Guide is the authority.

All files must be free of lint errors before being committed. This file does
not mandate a specific linter or formatter configuration - it documents the
conventions Claude writes to by hand.

---

## Rules That Override the Baseline

### No rule overrides defined.

Document project-specific exceptions here as they are identified.

---

## Rules That Match the Baseline (Key Reminders)

These rules are highlighted because they are commonly missed:

### File and Module Naming

Modules and packages use `lower_snake_case`. Never use mixed case or hyphens
in an importable module name:

```python
# bad
import orderUtils
import order-utils

# good
import order_utils
```

### Type Hints

Every function signature must have type hints on parameters and the return
value - this is a baseline requirement, not optional style:

```python
# bad
def get_order(order_id):
    ...

# good
def get_order(order_id: int) -> Order:
    ...
```

Use `Optional[X]` (or `X | None` on Python 3.10+) explicitly - never let a
default of `None` imply the type without annotating it:

```python
# bad
def find_order(order_id=None):
    ...

# good
def find_order(order_id: int | None = None) -> Order | None:
    ...
```

### Docstrings

Every public module, class, and function gets a docstring in Google style
(summary line, blank line, `Args:`, `Returns:`, `Raises:` sections):

```python
def get_order(order_id: int) -> Order:
    """Retrieves a single order by its database ID.

    Args:
        order_id: The primary key of the order to fetch.

    Returns:
        The matching Order instance.

    Raises:
        OrderNotFoundError: If no order exists with the given ID.
    """
```

### Imports

Group imports into three blocks, separated by blank lines, each
alphabetized within its block:

1. Standard library
2. Third-party packages
3. Local/internal modules

```python
import json
import os

import requests
from sqlalchemy import Column

from myapp.models import Order
from myapp.utils import format_currency
```

Never use wildcard imports (`from module import *`) and never use relative
imports beyond a single level (`from . import x` is fine, `from ...pkg
import x` is not - restructure instead).

### Naming Conventions

| Kind | Convention | Example |
|---|---|---|
| Module/package | `lower_snake_case` | `order_utils.py` |
| Class | `CapWords` | `class OrderProcessor:` |
| Function/variable | `lower_snake_case` | `def get_order():` |
| Constant | `UPPER_SNAKE_CASE` | `MAX_RETRIES = 3` |
| Private attribute | leading underscore | `self._cache` |

Never use single-character names except for loop counters (`i`, `j`) or
well-established math conventions (`x`, `y` in geometry code).

### Exceptions

Catch the narrowest exception type possible. Never use a bare `except:` -
always name the exception, even if it is `Exception`:

```python
# bad
try:
    order = fetch_order(order_id)
except:
    order = None

# good
try:
    order = fetch_order(order_id)
except OrderNotFoundError:
    order = None
```

Raise custom exception classes for domain errors rather than reusing generic
built-ins like `ValueError` for anything that isn't literally a value error.

### Context Managers

Use `with` for any resource that needs deterministic cleanup - files,
locks, database connections, network sockets:

```python
# bad
f = open("data.csv")
data = f.read()
f.close()

# good
with open("data.csv") as f:
    data = f.read()
```

### Comprehensions

Prefer a comprehension over a `for` loop with `.append()` when the result is
a simple transformation or filter. Fall back to an explicit loop once the
comprehension needs a nested loop or more than one condition - readability
over cleverness:

```python
# good - simple transform
order_ids = [order.id for order in orders]

# good - simple filter
open_orders = [o for o in orders if o.status == "open"]

# bad - too complex for a comprehension, hard to read
result = [x for x in data if x.valid for y in x.items if y.active]

# good - the same logic as an explicit loop
result = []
for x in data:
    if not x.valid:
        continue
    for y in x.items:
        if y.active:
            result.append(y)
```

---

## Testing

Use `pytest`-style test functions (`test_*`), not `unittest.TestCase`
subclasses, unless the project has already standardized on `unittest`.

```python
def test_get_order_returns_order_for_valid_id():
    order = get_order(order_id=1)
    assert order.id == 1

def test_get_order_raises_for_missing_id():
    with pytest.raises(OrderNotFoundError):
        get_order(order_id=999)
```

Use `pytest.mark.parametrize` for table-driven tests instead of writing near-
duplicate test functions for each case.

---

## What Claude Must Not Do

- Do not omit type hints on function signatures
- Do not use a bare `except:` clause
- Do not use wildcard imports
- Do not use mutable default arguments (`def f(items=[]):`) - use `None` and
  initialize inside the function body
- Do not use `assert` for input validation in production code paths -
  `assert` statements are stripped when Python runs with `-O`; use an
  explicit `if` and raise instead
- Do not leave a public function, class, or module without a docstring
