# Lua

## Overview

Standards for all Lua source files, including embedded scripts, game logic,
and configuration/automation scripting.

The baseline is a community-maintained Lua style guide in the tradition of
the one commonly bundled with `luacheck` - variable naming, module shape,
and idiomatic error handling for Lua 5.1+.

This file defines only the rules that differ from or extend that baseline.

---

## Rules That Override the Baseline

### No rule overrides defined.

Document project-specific exceptions here as they are identified.

---

## Rules That Match the Baseline (Key Reminders)

These rules are highlighted because they are commonly missed:

### File Naming

Script files use `snake_case.lua`:

```
-- bad
OrderUtils.lua
order-utils.lua

-- good
order_utils.lua
```

### Naming Conventions

| Kind | Convention | Example |
|---|---|---|
| Local variable/function | `snake_case` | `local order_count` |
| Module-level "class" (metatable-based) | `CapWords` | `local Order = {}` |
| Constant | `UPPER_SNAKE_CASE` | `local MAX_RETRIES = 3` |
| Private field (by convention) | leading underscore | `self._cache` |

Lua has no enforced privacy - a leading underscore is a convention signal to
readers, not an access restriction. Respect it as if it were enforced.

### Locals Over Globals

Always declare variables `local`. An undeclared assignment silently creates
a global, which leaks across files loaded into the same Lua state:

```lua
-- bad - creates a global, invisible from the declaration site
order_count = 0

-- good
local order_count = 0
```

Declare all locals used by a module at the top of the file, or immediately
before first use in a function - never rely on Lua's implicit global
fallback as a substitute for a proper module return table.

### Modules

Every file that is meant to be `require`d returns a single table - never
mutate globals as a way of exposing a module's API:

```lua
-- bad
function get_order(id) ... end  -- becomes a global

-- good
local M = {}

function M.get_order(id)
  ...
end

return M
```

### Error Handling

Use `pcall`/`xpcall` around any call that can fail in a way the caller must
recover from - do not let an uncaught error propagate past a boundary where
the caller has no way to know Lua raises errors instead of returning them:

```lua
-- bad - caller has no indication this can error
local order = fetch_order(id)

-- good
local ok, order_or_err = pcall(fetch_order, id)
if not ok then
  return nil, order_or_err
end
```

Prefer the Lua idiom of returning `nil, error_message` from functions that
fail in an expected way (a missing record, invalid input) - reserve
`error()`/`pcall` for truly exceptional, programmer-error conditions:

```lua
-- good - expected failure, not exceptional
function M.find_order(id)
  local order = orders[id]
  if not order then
    return nil, "order not found: " .. tostring(id)
  end
  return order
end
```

### String Concatenation

Use `table.concat` instead of repeated `..` concatenation inside a loop -
each `..` allocates a new string:

```lua
-- bad - O(n^2) allocations
local result = ""
for _, item in ipairs(items) do
  result = result .. item .. ", "
end

-- good
local parts = {}
for _, item in ipairs(items) do
  parts[#parts + 1] = item
end
local result = table.concat(parts, ", ")
```

### Table Iteration

Use `ipairs` for sequential array-like tables, `pairs` for general
key-value tables. Never rely on `pairs`' iteration order - it is undefined.

```lua
-- good - sequence
for i, item in ipairs(items) do ... end

-- good - map, order not assumed
for key, value in pairs(config) do ... end
```

### Comments

Use `--` for single-line comments, `--[[ ]]` only for block comments that
span multiple lines. Do not use `--[[ ]]` for a single line - `--` is
idiomatic and easier to toggle:

```lua
-- good
-- Explains why, not what.

--[[
Multi-line explanation spanning
more than one line.
]]
```

---

## What Claude Must Not Do

- Do not create an implicit global by omitting `local`
- Do not use `error()`/`pcall` for expected failure conditions - return
  `nil, message` instead
- Do not concatenate strings with `..` inside a loop - use `table.concat`
- Do not assume `pairs()` iteration order
- Do not mutate a global table as a module's public API - always `return M`
