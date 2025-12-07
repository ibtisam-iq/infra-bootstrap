!!! note "Preflight Validation"

Before any infra-bootstrap component begins installation, a full **system preflight check** is executed using `preflight.sh`.

```
The preflight check ensures:

- The script is executed with **root privileges**
- Required dependencies (`curl`, `bash`) are available
- The system has **working internet connectivity**
- The operating system is officially supported (Ubuntu and its derivatives line Linux Mint, Pop!_OS etc.)
- The architecture is compatible (`x86_64` / `amd64`)

Installation will continue **only if all checks pass**, ensuring predictable, safe execution on clean or disposable environments.
```
