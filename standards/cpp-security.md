# Security — C++

## Overview

C++-specific security checks run during spec close security analysis.
Extends the generic checks in `security-network.md` and `security-surface.md`,
and the same memory-safety class of risk as `c-security.md` - the checks
below focus on where modern C++'s safety idioms (RAII, smart pointers) are
bypassed or misused, not on manual `malloc`/`free` discipline. See
`CLAUDE.md → Security Analysis` for how this file is used.

Add new checks as they are discovered during project work.

---

## Memory Safety

| Category | What to look for | Severity |
|---|---|---|
| **Raw owning pointer** | `new`/`delete` used directly instead of a smart pointer or container - every raw `new` is a potential leak or double-free waiting to happen | CRITICAL |
| **Use-after-free / dangling reference** | A reference or raw pointer held past the lifetime of the object it refers to, especially a reference to a `std::vector` element invalidated by reallocation | CRITICAL |
| **Buffer overflow** | Raw array or C-string operations (`strcpy`, manual indexing past a fixed-size array) instead of `std::string`/`std::vector`/`std::array` with bounds-checked access (`.at()`) | CRITICAL |
| **Iterator invalidation** | Modifying a container (insert/erase) while holding an iterator into it obtained before the modification | CRITICAL |
| **Missing virtual destructor** | A base class with virtual methods but a non-virtual destructor, deleted through a base pointer - undefined behavior, potential resource leak | CRITICAL |
| **Slicing** | A derived object copied into a base-class value (not reference/pointer), losing derived state - can silently corrupt polymorphic invariants | WARNING |
| **Integer overflow feeding an allocation** | `new T[n]` or `std::vector::reserve(n)` where `n` is attacker-influenced and can overflow before the allocation size is computed | CRITICAL |

---

## Network and Input

| Category | What to look for | Severity |
|---|---|---|
| **Command injection** | `system()`, `popen()`, or `exec*()` called with a command string built from unsanitised external input | CRITICAL |
| **Path traversal** | File paths built from external input without resolving (`std::filesystem::canonical`) and verifying the result stays under an expected root | CRITICAL |
| **Format string vulnerability** | User-controlled data passed as the format argument to `printf`-family functions instead of `%s` with the data as an argument | CRITICAL |
| **Unvalidated input length** | Fixed-size stack buffers filled from network or file input without a length check against capacity before the copy | CRITICAL |

---

## Runtime and Build Hardening

| Category | What to look for | Severity |
|---|---|---|
| **Missing compiler hardening flags** | Project build files not enabling `-Wall -Wextra -Werror` plus `-fsanitize=address,undefined` in dev/test builds | INFO |
| **Insecure randomness** | `rand()`/`std::rand()` used to generate security tokens, nonces, or session IDs - use `<random>`'s cryptographic-grade sources or a platform CSPRNG instead | CRITICAL |
| **Secrets in source** | Hardcoded passwords, API keys, or tokens in any `.cpp`/`.h`/`.hpp` file - including values labelled as examples | CRITICAL |
| **Dependency vulnerabilities** | Vendored or linked third-party C++ libraries modified or added in this spec - flag for a CVE review | INFO |
