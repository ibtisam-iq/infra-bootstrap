---
title: Preflight
---

# Preflight

Initial system validation before bootstrapping. Checks root, deps (curl/bash), internet, OS (Ubuntu/Linux Mint), arch (x86_64/amd64). Fails fast if not ready.

--8\<-- "includes/common-header.md"
--8\<-- "includes/system-requirements.md"

## Installation Command

```bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/scripts/system-checks/preflight.sh | sudo bash
```

## What It Verifies

- Root privileges.
- curl/bash installed.
- Internet (ping 8.8.8.8).
- OS compatibility.
- Architecture.

## Output Example

```
========================================
🚀 infra-bootstrap - System Preflight Checks
========================================

✅ Running as root.

✅ curl is already installed.
✅ bash is already installed.

✅ Internet connection verified.

✅ Detected OS: Ubuntu 22.04.4 LTS

✅ Architecture supported: x86_64

🚀 Preflight checks completed successfully! Your system is ready.
```

Run early—ensures safe execution.

______________________________________________________________________

*Last updated: {{ git_revision_date_localized }}*
