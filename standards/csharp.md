# C#

## Overview

Standards for all C# files.

The baseline is the **Microsoft Framework Design Guidelines**:
https://learn.microsoft.com/en-us/dotnet/standard/design-guidelines/

This file defines the rules from the **Philips C# Coding Standard v5.33**, which
extends the Microsoft baseline. When in doubt about anything not covered here,
the Microsoft Framework Design Guidelines are the authority.

This standard does not define naming conventions or general layout rules (e.g.
indentation, brace placement). Adopt a separate style guide for those. Rule IDs
(e.g. `6@105`) are included as references to the Philips standard.

Linting is enforced via static analysis tools configured to check the rules
marked **Checked** in the Philips standard.

---

## Coding Style

### Operator Spacing (11@407)

Write unary, increment/decrement, function call, subscript, and member access
operators together with their operands - no spaces between them. Insert spaces
around all other operators. Do not separate a unary operator from its operand
with a newline.

```csharp
// bad
a = -- b;
a = (b1+b2)+(c1-c2);

// good
a = --b;
a = (b1 + b2) + (c1 - c2);
```

### Tabs vs Spaces (11@409)

Always use spaces instead of tabs. Configure your editor accordingly. Different
applications interpret tabs differently, which causes inconsistent formatting
across the team.

---

## Comments

### File Header (4@101)

Every file must contain a copyright header block. It must include at minimum
the word "Copyright" or "(c)", the company name, and a year:

```csharp
/* Copyright (c) <year> Koninklijke Philips N.V.
 * All rights are reserved. Reproduction or dissemination
 * in whole or in part is prohibited without the prior written
 * consent of the copyright holder.
 */
```

### Language (4@105)

All comments must be written in English. Either UK or US English is acceptable,
but must be used consistently within a file.

### XML Documentation (4@106)

All public and protected types, non-trivial methods, fields, events, and
delegates must be documented with XML tags. This enables IntelliSense and
automatic documentation generation.

Required tags by location:

| Tag | Where |
|---|---|
| `<summary>` | All types and members |
| `<remarks>` | Types and members needing preconditions or extra context |
| `<param>` | Methods - one per parameter |
| `<returns>` | Methods that return a value |
| `<exception>` | Methods, events, or properties that can throw |
| `<value>` | Properties |

In an inheritance hierarchy, use `<see cref="..."/>` to reference the base
member instead of repeating the documentation.

### No Commented-Out Code (4@111)

Never commit commented-out code. Use a work item tracking system to record
deferred work. Commented-out code creates ambiguity for every future reader -
was it disabled for testing? Is it safe to delete?

---

## Control Flow

### Loop Variables (6@101)

Do not modify the loop variable inside a `for` or `foreach` loop body. Updating
it in more than one place makes the loop very hard to reason about.

### Exhaustive Switch (6@105)

A `switch` on an enum type must cover every value, either by listing all cases
explicitly or by including a `default` label. If no action is needed for the
default case, add a `// no action` comment. If the default is unreachable, add
an assertion. The `default` label must always be the last case.

### Single Return Points (6@109)

Minimise the number of `return` statements in a method. A method with many
early returns is harder to follow when reading from the bottom up. Use an early
return only when it genuinely enhances readability or avoids cleanup complexity.

### No Explicit Boolean Comparisons (6@112)

Do not compare a `bool` expression to `true` or `false`:

```csharp
// bad
while (condition == false) { }
while (condition != true) { }

// good
while (!condition) { }
while (condition) { }
```

Exception: nullable booleans (`bool?`) may be compared to `true` or `false`.

### Modify-Once Rule (6@115)

Do not access a variable that was modified more than once within the same
expression. Although the evaluation order is defined in C#, such code is hard
to understand:

```csharp
// bad
v[i] = ++i;   // which index is being assigned?
i = ++i + 1;  // use i += 2 instead

// good
v[i] = ++c;
i = i + 1;
```

### Locking (6@119)

Do not lock on a public type or an instance outside your control. The patterns
`lock (this)`, `lock (typeof(MyType))`, and `lock ("myLock")` all violate this
rule. Define a private `object` field specifically for locking:

```csharp
// bad
lock (this) { }
lock (typeof(MyType)) { }

// good
private readonly object _syncRoot = new object();
...
lock (_syncRoot) { }
```

### No Double Negatives (6@120)

Avoid negative conditions that contain a double negative. They are harder to
read and easy to misparse:

```csharp
// bad
bool hasOrders = !customer.HasNoOrders;

// good
bool hasOrders = customer.HasOrders;
```

### No Parameters as Temporaries (6@121)

Never reuse a parameter as a scratch variable. The parameter name communicates
its original purpose; overwriting it with unrelated state is confusing.

### Null Dereference Guard (6@191)

All code using reference types that can be `null` must be guarded before use:

```csharp
if (reference != null)
{
    // safe to use
}
```

### Cyclomatic Complexity (6@201)

The cyclomatic complexity of a method must not exceed the configured maximum.
High complexity is directly correlated with defect rates and poor testability.
Refactor into smaller methods when the limit is approached.

---

## Data Types

### Flags Enum Attribute (10@203)

Apply `[Flags]` to any enum intended for bitwise combination. Use a plural name
for the enum and define power-of-two values explicitly. Do not use `[Flags]` on
open-ended sets:

```csharp
[Flags]
public enum AccessPrivileges
{
    Read   = 0x1,
    Write  = 0x2,
    Append = 0x4,
    Delete = 0x8,
    All    = Read | Write | Append | Delete
}
```

### No Magic Numbers (10@301)

Do not use literal numeric or string values inline. Define named constants
instead. Express relationships between constants in code rather than in
comments:

```csharp
// bad
public const int HighWaterMark = 24; // at 75%

// good
public const int MaxItems = 32;
public const int HighWaterMark = 3 * MaxItems / 4; // at 75%
```

Exceptions: values whose meaning is unambiguous from context (`0`, `1`, `2`,
`90`, `180`, `270`, `360`, powers of two, powers of ten). Strings used only for
logging or tracing are also exempt.

### Floating-Point Comparison (10@401)

Never compare floating-point values with `==`, `!=`, or `Equals()`. Use a
tolerance-based helper instead:

```csharp
public static bool AlmostEquals(double a, double b, double precision)
    => Math.Abs(a - b) <= precision;
```

Do not use a fixed `epsilon` constant - the required precision depends on the
magnitude of the values being compared.

Exception: a float explicitly initialised to a literal (e.g. `0.0`) may be
compared to that same literal to detect whether it has changed.

### Meaningful Casts (10@404, 10@405)

Only implement casts that operate on the complete object. Do not cast a type to
another by extracting a single member (e.g. converting a `Button` to a `string`
by returning `Name`). Do not generate a semantically different value - a cast
must preserve the conceptual meaning of the data.

### Composite Format Arguments (10@406, 10@407)

Every indexed placeholder in a composite format string (e.g. `String.Format`,
`Console.WriteLine`) must have a corresponding argument, and every argument
must be referenced by a placeholder. Both a missing argument and an unreferenced
argument are errors.

```csharp
// bad - {1} has no matching argument
Console.WriteLine("Value is {0} not {1}", i);

// bad - j is supplied but never used
Console.WriteLine("Value is {0} not {0}", i, j);

// good
Console.WriteLine("Value is {0} not {1}", i, j);
```

---

## Delegates and Events

### Object State After Event (9@101)

Do not assume the object is in the same state after raising an event. An event
handler may have called methods or properties that changed the object's state,
including disposing fields. Raising the event should typically be the last
statement in a method.

### Thread Context Documentation (9@102)

Always document which thread an event handler is called from. When an event
fires from a background thread or thread pool, the handler must synchronise
access to shared data.

### Delegate Inference (9@108)

Use delegate inference rather than explicit delegate instantiation when
subscribing or unsubscribing:

```csharp
// bad
someClass.SomeEvent += new EventHandler(OnHandleSomeEvent);

// good
someClass.SomeEvent += OnHandleSomeEvent;
```

### Matching Unsubscribe (9@110)

Every event subscription must have a corresponding unsubscribe. A subscribed
object that is disposed but never unsubscribed will still receive events,
leading to calls on a disposed object and preventing garbage collection.
Implement `IDisposable` and unsubscribe in `Dispose()`.

### Generic Event Handlers (9@111)

Use `EventHandler<TEventArgs>` instead of declaring custom delegate types for
events. Static events pass `null` as the sender; instance events pass the
raising object.

### Non-Null Event Arguments (9@112)

For instance-based events, do not pass `null` as the sender or as the event
data argument. Use `EventArgs.Empty` when no data needs to accompany the event.

### Null-Check Before Raising (9@113)

Always check an event handler delegate for `null` before invoking it:

```csharp
SomeEvent?.Invoke(this, EventArgs.Empty);
```

### No Return Values from Events (9@114)

Do not use delegates with return types for events. Events may have multiple
subscribers, so return values have no reliable meaning. Declare event delegates
as returning `void`.

---

## Exceptions

### No Exceptions from Unexpected Locations (8@102)

Do not throw exceptions from any of the following locations:

| Location | Rule |
|---|---|
| Event accessors | Only `InvalidOperationException`, `NotSupportedException`, or `ArgumentException` (and their subtypes) are permitted |
| `Equals()` | Return `false` instead of throwing |
| `GetHashCode()` | Must always return a value |
| `ToString()` | Must not throw |
| Static constructors | Throwing makes the type permanently unusable |
| Finalizers | Can crash the process |
| `Dispose()` | Often called from `finally` and from finalizers |
| Equality operators (`==`, `!=`) | Return `true` or `false` only |
| Implicit cast operators | Caller is unaware the operator is invoked |
| Exception constructors | Throws an exception while creating an exception |

### Document Thrown Exceptions (8@104)

Describe all exceptions that a public or internal method or property explicitly
throws, using the `<exception>` XML tag. Framework exceptions thrown by methods
called internally do not need to be listed:

```csharp
/// <exception cref="FileNotFoundException">Thrown when somePath is not a valid file.</exception>
public void MyMethod(string somePath) { ... }
```

### Log Before Throwing (8@105)

Always log or trace before throwing an exception. If the caller catches and
discards the exception, the log entry provides the only record that it occurred.

### Use Standard Exceptions (8@107)

Do not raise `System.Exception` or `System.ApplicationException` directly. Use
the most appropriate specific exception:

| Exception | Use when |
|---|---|
| `InvalidOperationException` | Action is invalid for the object's current state |
| `NotSupportedException` | Action may be valid in future but is not supported now |
| `ArgumentException` | Incorrect argument supplied |
| `ArgumentNullException` | `null` supplied where it is not allowed |
| `ArgumentOutOfRangeException` | Argument is outside the required range |

### Descriptive Exception Messages (8@108, 8@109)

Set the `Message` property to a description that identifies which argument or
object caused the problem. Throw the most specific exception available rather
than a generic one.

### Do Not Silently Ignore Exceptions (8@110)

An empty `catch` block is forbidden. At minimum, the catch block must either
log the exception or wrap it in a more specific exception as an inner exception.
A bare re-throw (`throw;`) with no other statement is also forbidden - it adds
overhead without value. Never use `throw e;` as it discards the original stack
trace:

```csharp
// bad - silent
catch (Exception) { }

// bad - bare re-throw
catch (Exception) { throw; }

// good - log and rethrow
catch (Exception e)
{
    Trace.WriteLine(e.ToString());
    throw;
}

// good - wrap with context
catch (Exception e)
{
    throw new MySpecificException("context message", e);
}
```

### Throw Instead of Status Returns (8@111)

Use exceptions to signal unexpected failure rather than returning a status code
or boolean. Callers routinely forget to check return values, and nested
`if`-chains for error paths are harder to maintain than structured exception
handling.

### Object State on Recoverable Exceptions (8@203)

When throwing a recoverable exception, leave the object in a usable and
predictable state. The caller must be able to catch the exception and safely
attempt the operation again or continue using the object.

---

## General

### One Provider Per File (2@105)

Do not mix code from different providers in a single file. Third-party code
will generally not comply with this standard. Similarly, do not mix code from
different Philips business units in the same file.

### No Suppressed Compiler Warnings (2@107)

Do not suppress compiler warnings in code. Some warnings indicate serious
program flaws. Suppressing them obscures real problems and degrades reliability.

---

## Naming

### Namespace Pattern (3@109)

Namespaces must use PascalCase and follow the pattern:

```
<company>.<businessunit>.<technology>.<top-level-component>
```

Example: `Philips.MR.Cardio.IMM.Common.Logging`

### No Ambiguous Characters (3@204)

Do not use characters that can be mistaken for digits, or digits that can be
mistaken for characters. Specifically avoid `O`, `o`, `l`, `I` where they could
be confused with `0` and `1`.

### Assembly Naming (3@501)

Name DLL assemblies after their containing namespace. If multiple assemblies
share a namespace, append a unique suffix. This allows storing assemblies in
the Global Assembly Cache without name collisions.

### One Type Per File (3@504)

Name each source file after the primary type it contains. If a partial class
spans multiple files, name the additional files `MainClass.PostFix.cs` where
`PostFix` describes the contents meaningfully (not just a number):

```
// good
MyForm.cs
MyForm.Designer.cs
```

---

## Object Lifecycle

### Declare Variables Close to Use (5@101, 5@102)

Declare and initialise variables at the point where they are first needed.
Avoid C-style blocks that declare all variables at the top of a scope.

### Predefined Instances as Static Readonly (5@106)

Expose predefined object instances as `public static readonly` fields, not as
constants or properties that construct on every access:

```csharp
public struct Color
{
    public static readonly Color Red = new Color(0xFF0000);
    public static readonly Color Black = new Color(0x000000);
}
```

### Null Fields for GC Assistance (5@107)

Set reference fields to `null` when the referenced object is no longer needed
(but before the field goes out of scope). This allows the garbage collector to
reclaim the object earlier. Not required for variables about to go out of scope.

### No Name Shadowing (5@108)

Do not redeclare an identifier in a nested scope when the same name already
exists in an outer scope. The behaviour is defined, but it causes confusion
during maintenance:

```csharp
// bad
int foo = something;
if (whatever)
{
    double foo = 12.34; // shadows outer foo
}
```

### Avoid Finalizers (5@111)

Do not implement a finalizer unless the class holds unmanaged resources and
`IDisposable` is also being implemented (see rule 5@113). Finalizers impose a
significant GC performance penalty and execute at a non-deterministic time.

### IDisposable Pattern (5@113)

Implement `IDisposable` whenever a class holds unmanaged resources, owns
disposable objects, or subscribes to events on other objects.

Follow the appropriate variant of the Dispose pattern for the class:

**Inheritable class (general case):**

```csharp
public void Dispose()
{
    Dispose(true);
    GC.SuppressFinalize(this);
}

protected virtual void Dispose(bool disposing)
{
    if (disposing)
    {
        // dispose managed resources
        managedResource?.Dispose();
        managedResource = null;
    }
    // dispose unmanaged resources unconditionally
}

~MyDisposable() { Dispose(false); }
```

**Derived class:** override `Dispose(bool)`, clean up own resources, then call
`base.Dispose(disposing)`. Do not re-implement `IDisposable` or add a finalizer.

**Sealed class with managed resources only:** dispose directly in `Dispose()`,
no `Dispose(bool)` override needed, no finalizer needed.

`Dispose()` must be idempotent - safe to call multiple times without throwing.
Use a `bool isDisposed` flag for readonly fields, or null-check fields after
disposing for mutable fields.

### No Reference Access in Finalizers (5@114)

Do not access any reference-type fields or members from a finalizer. By the
time the GC calls a finalizer, referenced objects may already have been
collected. Only value-type local variables (stack-allocated) are safe to use.

### Document Returned Copies (5@116)

If a member returns a copy of a reference type or array rather than the
internal instance, document this explicitly. Callers must know whether
modifications to the returned value affect the object's internal state.

### Strings and Collections Must Not Be Null (5@117)

Methods, properties, and arguments that return a string or collection must
never return `null`. Return the empty string (`string.Empty`), empty list,
or empty dictionary instead. Document this guarantee in the member's XML
comment.

### No Virtual Calls in Constructors or Finalizers (5@118)

Do not call virtual methods from a constructor or finalizer. The derived class
may not be fully constructed or may have already been partially collected.
Virtual dispatch should only happen on fully constructed objects.

### Return Read-Only Collection Interfaces (5@119)

Do not expose internal collections by returning `List<T>`, `T[]`, or other
mutable types. Return `IEnumerable<T>`, `IReadOnlyCollection<T>`,
`IReadOnlyList<T>`, or `IReadOnlyDictionary<TKey, TValue>` instead.
Immutable collection types (`ImmutableArray<T>`, etc.) are also permitted.

### No Using Variables Outside Their Scope (5@121)

Do not return or access a variable that is declared inside a `using` statement
from outside that statement. The object has already been disposed:

```csharp
// bad
using (var tester = CreateTester())
{
    tester.Configure();
    return tester; // tester is disposed before the caller receives it
}
```

---

## Object Oriented

### Private Fields (7@101)

Declare all instance fields (data members) `private`. Expose state through
properties or methods.

### Static Classes for Static-Only Members (7@102)

If a class contains only static members, mark it `static` to prevent
instantiation. A static class cannot be inherited, which is also correct
since there is no instance to inherit.

### Protected Constructor on Abstract Classes (7@105)

Explicitly define a `protected` constructor on every abstract base class.
This improves readability and prevents compilers from inserting a `public`
constructor silently.

### Internal by Default (7@106)

Declare all types `internal` unless they must be public. Start with the most
restrictive access level, then consciously widen it only when required:

```csharp
// bad - implicit public
class BaseClass { }

// good - explicit internal
internal class BaseClass { }
```

### One Type Per File (7@107)

Limit each source file to a single type. Nested types are an exception and
remain in the same file as their containing type.

### using Directives Over Fully Qualified Names (7@108)

Use `using` directives at the top of the file rather than fully qualifying
type names inline. When a name clash requires disambiguation, use a `using`
alias:

```csharp
using WebLabel = System.Web.UI.WebControls.Label;
```

### Dynamic Binding Over Type Inspection (7@201)

Use class inheritance and virtual dispatch when control flow depends on an
object's type. Avoid `typeof` or `is` checks to branch on type. Querying the
type of an object and branching on it is usually a design error.

Exception: using `is` to test whether an object implements an optional
interface is a valid pattern.

### Consistent Overload Semantics (7@301)

All overloads of a method must serve the same purpose and exhibit similar
behaviour. Overloads that behave differently mislead callers and create
false assumptions about the API.

### Delegate to the Most Complete Overload (7@303)

When a method has multiple overloads, make only the most complete overload
virtual. Implement all other overloads by delegating to it. This ensures that
a derived class only needs to override one method:

```csharp
public int IndexOf(string s) => IndexOf(s, 0);
public int IndexOf(string s, int start) => IndexOf(s, start, someText.Length - start);
public virtual int IndexOf(string s, int start, int count) => someText.IndexOf(s, start, count);
```

### Liskov Substitution Principle (7@403)

A reference to a derived class must be usable anywhere a reference to its base
class is expected without altering the correctness of the program. This applies
to interfaces as well as concrete base classes.

### No new Keyword to Hide Members (7@404)

Do not use the `new` keyword to hide an inherited member. Hiding breaks
polymorphism and makes subclasses hard to reason about. Use `override` instead:

```csharp
// bad
public new void Print() { }

// good
public override void Print() { }
```

### No Modifying Operator Overloads on Classes (7@501)

Do not overload `+`, `-`, `*`, `/`, `%`, `&`, `|`, `^`, `<<`, or `>>` on a
class type. These operators have unexpected reference semantics on reference
types - the result is a new object, not a modification of the original.
Operator overloading on `struct` types is acceptable.

Exception: class types with complete value semantics (such as `System.String`).

### Do Not Modify Operands in Operator Implementations (7@502)

The implementation of an overloaded operator must not modify the value of
either operand. Doing so produces counter-intuitive results for callers.

### Equality Triad (7@503, 7@520, 7@521)

If you implement any one of `operator==`, `Equals`, or `GetHashCode`, you
should implement all three and keep them consistent. Two objects that are equal
according to `Equals` must return the same value from `GetHashCode`.

Reference types do not need to implement `operator==` unless value equality is
specifically required, because a default reference-equality implementation is
already provided.

### Relational Operator Completeness (7@530, 7@531, 7@532)

- If you implement `IComparable`, also implement `==`, `!=`, `<`, and `>`.
- If you overload `+` or `-`, also overload `==`.
- If you implement any relational operator (`<`, `<=`, `>`, `>=`), implement
  all four.

### Equals vs == for Value Types (7@533)

Do not use `Equals()` to compare different value types - use `==` instead.
`Equals()` returns `false` when called on two different value types even if
their values are numerically equal, because the runtime performs a type check
first.

### Stateless Properties (7@601)

Properties must be stateless with respect to each other. There must be no
observable difference between setting property A before B versus B before A.
Properties that require a specific set-order imply hidden coupling that should
be modelled as a method or constructor instead.

### Properties vs Methods (7@602, 7@603)

Use a property when the member represents a logical data attribute of the
object. Use a method when any of the following apply:

- The operation is a conversion (e.g. `ToString()`).
- The operation is expensive and callers should consider caching the result.
- Calling the getter has an observable side effect.
- Successive calls can return different results.
- The execution order relative to other operations matters.
- The member is static but returns a value that can change.
- The member returns a copy of an internal array or reference type.
- Only a setter would be provided (write-only properties are confusing).

### Fully Initialised Constructors (7@604)

Every constructor must produce a fully initialised object. Callers must not
need to set additional properties after construction to make the object usable.
Private constructors are exempt.

### Pattern Matching over as (7@608)

Use C# 7 pattern matching with `is` instead of casting with `as` followed by a
null check:

```csharp
// bad
string text = input as string;
if (text != null) { ... }

// good
if (input is string text) { ... }
```

### Correct Casting Technique (7@609)

Use explicit casting when the type is known by design. Use `as` with a null
check (or pattern matching per 7@608) when the type is uncertain. Do not
double-cast by first checking with `is` and then casting explicitly - this
performs the cast twice:

```csharp
// bad - double cast
if (x is ISomeInterface)
    y = (ISomeInterface)x;

// good - type known by design
ISomeInterface y = (ISomeInterface)x;

// good - type uncertain
ISomeInterface y = x as ISomeInterface;
if (y != null) { ... }
```

### Generic Constraints (7@611)

Use `where` constraints on generic types and methods instead of casting to and
from `object`. Constraints express the requirement statically and eliminate
runtime casts:

```csharp
// bad
class MyClass<T>
{
    void SomeMethod(T t)
    {
        SomeClass obj = (SomeClass)(object)t;
    }
}

// good
class MyClass<T> where T : SomeClass
{
    void SomeMethod(T t)
    {
        SomeClass obj = t;
    }
}
```

### Do Not Ignore Method Results (7@700)

Do not call a method and discard its return value unless the method is designed
to be called purely for its side effects. Specifically:

- A newly created object that is never assigned is unnecessary object churn.
- String methods return a new string - ignoring the result (e.g. calling
  `ToString()` without using the result) is always a bug.
- `HRESULT` and error code returns from COM/P-Invoke must be inspected.

If the return value is never needed, the method's return type should be `void`.

---

## Performance

### Avoid Boxing and Unboxing (12@101)

Boxing and unboxing value types is expensive. Replace non-generic collections
(`ArrayList`, `Hashtable`) with their generic equivalents (`List<T>`,
`Dictionary<TKey, TValue>`). When formatting value types into strings, call
`.ToString()` on the value type explicitly rather than relying on implicit
boxing through `{0}` placeholders.

### Case-Insensitive String Comparison (12@102)

Do not use `ToLower()` or `ToUpper()` to normalise strings before comparison.
These allocate a new string that is immediately discarded. Use
`String.Compare(x, y, StringComparison.OrdinalIgnoreCase)` or a
`StringComparer` instead.

### Use Any() for Emptiness Checks (12@103)

Use `Any()` to test whether an `IEnumerable` is non-empty rather than
`Count()`. `Count()` may iterate the entire sequence; `Any()` stops at the
first element.

### Test for Empty Strings by Length (12@104)

Use `string.IsNullOrEmpty(s)` or `s.Length == 0` rather than `s == ""` or
`s.Equals("")`. Length comparison is significantly faster than equality
comparison.

### Short-Circuit Evaluation Ordering (12@105)

Place the cheapest sub-expression first in `&&` and `||` conditions. `&&`
skips the right side when the left is `false`; `||` skips the right side when
the left is `true`. Put expensive calls (method invocations with significant
computation) last so they are avoided when possible.

### Use List<T> Instead of ArrayList (12@106)

Always use `List<T>` instead of `ArrayList`. For value types, `List<T>` is up
to 20x faster because it avoids boxing. For reference types the performance is
equivalent, but `List<T>` also provides compile-time type safety.

---

## What Claude Must Not Do

- Leave a file without a copyright header block
- Commit commented-out code
- Modify a loop variable inside the loop body
- Compare a `bool` directly to `true` or `false` (unless the bool is nullable)
- Access a modified variable more than once in the same expression
- Lock on `this`, a `Type`, or a string literal
- Use literal numeric or string values instead of named constants (except for
  the explicitly permitted values: `0`, `1`, `2`, powers of two, powers of ten,
  `90`/`180`/`270`/`360`, and strings used only for logging)
- Compare floating-point values with `==`, `!=`, or `Equals()`
- Pass too few or too many arguments to a composite format string
- Throw exceptions from finalizers, `Dispose()`, `ToString()`, `Equals()`,
  `GetHashCode()`, equality operators, implicit cast operators, static
  constructors, or exception constructors
- Use a bare `catch (Exception) { }` or `catch (Exception) { throw; }`
- Use `throw e;` to re-throw - always use `throw;`
- Throw `System.Exception` or `System.ApplicationException` directly
- Declare instance fields with any access level other than `private`
- Use the `new` keyword to hide an inherited member - always use `override`
- Implement `operator+` or `operator-` on a class type
- Modify operands inside an operator overload implementation
- Override `Equals()` without also overriding `GetHashCode()`
- Use `Equals()` to compare different value types - use `==`
- Implement `IComparable` without also implementing `==`, `!=`, `<`, `>`
- Return `null` from a method or property whose return type is `string` or a
  collection type
- Call virtual methods from a constructor or finalizer
- Return `List<T>`, `T[]`, or other mutable collection types from public
  members - return a read-only interface instead
- Return a `using`-scoped variable after the `using` block has closed
- Use `ArrayList` - always use `List<T>`
- Use `ToLower()` or `ToUpper()` for string comparison
- Suppress compiler warnings with `#pragma warning disable` or attributes
- Use tabs instead of spaces
