---
title: Version Check
---

# Version Check

Audits installed DevOps tools. Runs preflight, lists versions (Ansible, AWS CLI, Docker, Containerd, Runc, Git, Python, Node.js, npm, Helm, Jenkins, kubectl, eksctl, Terraform).

--8<-- "includes/common-header.md"
--8<-- "includes/system-requirements.md"

## Installation Command

```bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/scripts/system-checks/version-check.sh | sudo bash
```

## What It Verifies

- Tool presence + versions.
- Preflight first.

## Output Example

```
📌 Installed Tools and Versions:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 🔹 Ansible: 2.15.3
 🔹 AWS CLI: 2.15.30
 🔹 Docker: 24.0.7
 🔹 Containerd: 1.7.11
 🔹 Runc: 1.1.9
 🔹 Git: 2.34.1
 🔹 Python: 3.10.12
 🔹 Node.js: v18.19.0
 🔹 npm: 9.6.7
 🔹 Helm: v3.14.3
 🔹 Jenkins: 2.426.3
 🔹 kubectl: v1.29.3
 🔹 eksctl: 0.174.0
 🔹 Terraform: v1.6.6
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Use for audits—outputs to console.
