# Visual Basic

## Overview

Standards for Visual Basic source files. Visual Basic spans two genuinely
different eras with different baselines - use the one matching the code
being written:

- **VB.NET (primary baseline for new code):** Microsoft's Visual Basic
  Coding Conventions (Microsoft Learn) plus the shared **.NET Framework
  Design Guidelines** that apply across all .NET languages.
- **VB6 (legacy compatibility only):** Hungarian Notation and the
  conventions that were the de facto VB6-era standard, documented here so
  Claude can work consistently within existing VB6 codebases - not a
  recommendation to write new VB6 code.

Default to VB.NET conventions unless the file being edited is already VB6 -
in that case, follow the VB6 section below to stay consistent with the
surrounding code rather than mixing conventions within one legacy file.

---

## VB.NET (New Code)

### Naming Conventions (.NET Framework Design Guidelines)

| Kind | Convention | Example |
|---|---|---|
| Class/Interface/Enum | `PascalCase` | `Public Class OrderProcessor` |
| Public method/property | `PascalCase` | `Public Function GetOrder(id As Integer) As Order` |
| Private field | `camelCase`, often `_` prefixed by project convention | `Private _orderCount As Integer` |
| Parameter/local variable | `camelCase` | `Dim orderId As Integer` |
| Constant | `PascalCase` (VB.NET convention, differs from C#'s `UPPER_SNAKE_CASE`) | `Public Const MaxRetries As Integer = 3` |
| Interface | `I` prefix | `Public Interface IOrderRepository` |

### Option Explicit and Option Strict

Every file declares both, at the top, above any `Imports`:

```vb
Option Explicit On
Option Strict On

Imports System
```

`Option Strict On` disallows implicit narrowing conversions - this is the
single highest-value VB.NET setting for catching real bugs at compile time.

### Explicit Typing

Declare every variable with an explicit type - never rely on `Dim x` without
`As Type`, and never use `Object` where a specific type is known:

```vb
' bad
Dim total = 0
Dim order As Object = GetOrder(id)

' good
Dim total As Decimal = 0
Dim order As Order = GetOrder(id)
```

### Properties Over Public Fields

Expose state through properties, not public fields - even for simple
get/set pairs, use auto-implemented properties:

```vb
' bad
Public OrderId As Integer

' good
Public Property OrderId As Integer
```

### Exception Handling

Use structured `Try`/`Catch`/`Finally` - never `On Error Resume Next` in new
VB.NET code, which silently swallows errors and is a VB6-era pattern that
VB.NET's structured exception handling was designed to replace:

```vb
' bad - VB6-era pattern, silently continues past errors
On Error Resume Next
order = repository.GetOrder(id)

' good
Try
    order = repository.GetOrder(id)
Catch ex As OrderNotFoundException
    order = Nothing
End Try
```

Catch the narrowest exception type possible, same principle as `csharp.md`.

### XML Documentation Comments

Every public member gets an XML doc comment:

```vb
''' <summary>
''' Retrieves a single order by its database ID.
''' </summary>
''' <param name="id">The primary key of the order to fetch.</param>
''' <returns>The matching order, or Nothing if not found.</returns>
Public Function GetOrder(id As Integer) As Order
    ...
End Function
```

---

## VB6 (Legacy Compatibility Only)

Applies only when working within an existing VB6 codebase. Do not use these
conventions for new VB.NET code.

### Hungarian Notation

VB6's IDE had weak type visibility compared to modern tooling, making
Hungarian Notation the de facto mandatory convention:

| Prefix | Type | Example |
|---|---|---|
| `str` | String | `strName` |
| `int` | Integer | `intCount` |
| `obj` | Object | `objCustomer` |
| `bln` | Boolean | `blnIsValid` |
| `arr` | Array | `arrItems` |

When editing an existing VB6 file, match its existing naming convention
exactly - do not introduce PascalCase/camelCase naming into a file that
otherwise uses Hungarian Notation throughout.

### Module Organization

One class per `.cls` file, one standard module per `.bas` file, matching the
file name to the class/module name.

### Error Handling

VB6 has no structured exception handling - use `On Error GoTo` with an
explicit error-handling label, never `On Error Resume Next` as a way to
avoid writing real error handling:

```vb
' good - VB6 idiom
Sub ProcessOrder(orderId As Integer)
    On Error GoTo ErrorHandler

    ' processing logic

    Exit Sub

ErrorHandler:
    LogError Err.Number, Err.Description
End Sub
```

---

## What Claude Must Not Do

- Do not write new VB6 code - VB6 conventions apply only to editing existing
  legacy files
- Do not omit `Option Explicit On` / `Option Strict On` from a new VB.NET
  file
- Do not use `On Error Resume Next` in VB.NET code
- Do not mix Hungarian Notation and PascalCase within the same file
- Do not use `Object` as a variable's type when the actual type is known
  at the point of declaration
