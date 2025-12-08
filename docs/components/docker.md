---
title: Docker
---

# Docker

Container engine for building/running images. Installs daemon + CLI for local dev/labs.

--8<-- "includes/common-header.md"
--8<-- "includes/system-requirements.md"

## Installation Command

```bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/scripts/components/docker-setup.sh | sudo bash
```

### Optional Flags

| Flag          | Description                                |
| ------------- | ------------------------------------------ |
| `-q`          | Quiet mode (suppress non-essential output) |
| `--no-update` | Skips `apt update` and dependency refresh  |
| `-h`          | help                                       |

**Example:**

```bash
# Skip package updates
curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/scripts/components/docker-setup.sh | sudo bash -s -- --no-update
```

```bash
# Quiet mode
curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/scripts/components/docker-setup.sh | sudo bash -s -- -q
```

______________________________________________________________________

## What It Installs

The script installs the following official Docker packages:

| Component               | Description                                |
| ----------------------- | ------------------------------------------ |
| `docker-ce`             | Docker Engine (Community Edition)          |
| `docker-ce-cli`         | Docker CLI tools                           |
| `containerd.io`         | Container runtime used by Docker           |
| `docker-buildx-plugin`  | Buildx extension for multi-platform builds |
| `docker-compose-plugin` | Docker Compose v2 plugin                   |

## Verify

```bash
docker info
docker --version  # e.g., Docker version 24.x
docker run hello-world  # Test pull/run
systemctl status docker  # Active
```

## If you can’t run Docker without sudo:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

--8<-- "includes/post-installation.md"

**Official Docs:** [docs.docker.com/engine/install](https://docs.docker.com/engine/install/)

______________________________________________________________________
