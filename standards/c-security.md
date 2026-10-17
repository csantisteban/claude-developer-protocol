# Security — C

## Overview

C-specific security checks run during spec close security analysis. Extends
the generic checks in `security-network.md` and `security-surface.md`. The
checklist framework is **CERT C Secure Coding** - chosen over full MISRA C,
which is built for regulated industries (automotive/aerospace/medical) with
dedicated compliance tooling. See `CLAUDE.md → Security Analysis` for how
this file is used.

Add new checks as they are discovered during project work.

---

## Memory Safety

| Category | What to look for | Severity |
|---|---|---|
| **Buffer overflow** | `strcpy`, `strcat`, `sprintf`, or `gets` used on any buffer not proven large enough at compile time - use `strncpy`/`strncat`/`snprintf`/`fgets` and verify the result was not truncated | CRITICAL |
| **Use-after-free** | A pointer read or written after the memory it points to has been `free()`d - set freed pointers to `NULL` immediately after freeing | CRITICAL |
| **Double free** | `free()` called twice on the same pointer, including via two different variables that alias the same allocation | CRITICAL |
| **Out-of-bounds access** | Array or pointer arithmetic indexing outside the allocated range, especially in loops with an off-by-one bound (`<=` where `<` was intended) | CRITICAL |
| **Uninitialized memory read** | A `malloc`-returned buffer or stack variable read before being fully initialized | CRITICAL |
| **Integer overflow feeding an allocation** | `malloc(a * b)` or similar where `a`/`b` are attacker-influenced and the multiplication can overflow `size_t`, resulting in a too-small allocation | CRITICAL |
| **Format string vulnerability** | User-controlled data passed as the format argument to `printf`/`fprintf`/`syslog` family functions instead of as an argument (`printf(user_input)` instead of `printf("%s", user_input)`) | CRITICAL |

---

## Network and Input

| Category | What to look for | Severity |
|---|---|---|
| **Command injection** | `system()`, `popen()`, or `exec*()` called with a command string built from unsanitised external input | CRITICAL |
| **Path traversal** | File paths built from external input without resolving (`realpath`) and verifying the result stays under an expected root | CRITICAL |
| **Unvalidated input length** | Fixed-size stack buffers filled from network or file input without a length check against the buffer's capacity before the copy | CRITICAL |
| **Integer signedness errors** | A signed value from external input compared or cast in a context expecting unsigned (or vice versa), especially as a size or length argument | WARNING |

---

## Runtime and Build Hardening

| Category | What to look for | Severity |
|---|---|---|
| **Missing compiler hardening flags** | Project build files not enabling `-Wall -Wextra -Werror` plus `-fsanitize=address,undefined` in dev/test builds - flag as a hardening gap, not a code-level finding | INFO |
| **Insecure randomness** | `rand()`/`srand()` used to generate security tokens, nonces, or session IDs - use a CSPRNG (`arc4random`, `/dev/urandom`, or a platform crypto API) instead | CRITICAL |
| **Secrets in source** | Hardcoded passwords, API keys, or tokens in any `.c`/`.h` file - including values labelled as examples | CRITICAL |
| **Dependency vulnerabilities** | Vendored or linked third-party C libraries modified or added in this spec - flag for a CVE review | INFO |
