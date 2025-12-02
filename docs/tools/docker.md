# 📄 Docker Installation (docker-setup.sh)

--8<-- "includes/preflight.md"
--8<-- "includes/system-requirements.md"
--8<-- "includes/cli-flags.md"
--8<-- "includes/error-handling.md"

---

## 🧭 Overview

The Docker installer sets up the official **Docker Engine** on Ubuntu-based systems using Docker’s recommended package repositories.
This installer ensures a **predictable, repeatable, and clean** installation process suitable for:

* Container development
* Kubernetes lab environments
* CI/CD build nodes
* Disposable cloud and VM environments

Docker installed via this script includes the full engine, CLI, containerd, Buildx, and Docker Compose v2.

---

## 📦 Components Installed

The script installs the following official Docker packages:

| Component               | Description                                |
| ----------------------- | ------------------------------------------ |
| `docker-ce`             | Docker Engine (Community Edition)          |
| `docker-ce-cli`         | Docker CLI tools                           |
| `containerd.io`         | Container runtime used by Docker           |
| `docker-buildx-plugin`  | Buildx extension for multi-platform builds |
| `docker-compose-plugin` | Docker Compose v2 plugin                   |

These packages come directly from Docker’s official APT repositories.

---

## 🚀 Installation Command

```bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/docker-setup.sh | sudo bash
```

### With optional flags

```bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/docker-setup.sh | sudo bash -s -- -q --no-update
```

---

## 🛠 How the Installer Works (Step-by-Step Breakdown)

### **1. System Update (unless skipped)**

--8<-- "includes/system-update.md"

---

### **2. Detect Existing Installation**

If Docker is already installed, the script prints the installed version and exits safely without making changes.

---

### **3. Add Docker’s Official GPG Key**

Creates the secure keyring directory and retrieves Docker’s trusted signing key.

```
/etc/apt/keyrings/docker.asc
```

This ensures packages come from the genuine Docker repository.

---

### **4. Add Docker APT Repository**

Adds the OS-specific Docker repository using system release data:

```
stable https://download.docker.com/linux/ubuntu
```

---

### **5. Install Docker Engine & Dependencies**

Runs:

```
apt-get install docker-ce docker-ce-cli containerd.io ...
```

This installs the complete Docker runtime stack.

---

### **6. Add User to the docker Group**

The script identifies the *real* logged-in user (important when running under sudo):

```
REAL_USER=${SUDO_USER:-$USER}
```

If the user is not already part of the `docker` group, they are added:

```
sudo usermod -aG docker $REAL_USER
```

This allows Docker to run **without sudo**.

---

### **7. Enable & Start Docker Service**

The script ensures Docker starts automatically on boot:

```
systemctl enable docker
systemctl restart docker
```

---

## 🧪 Post-Installation Verification

--8<-- "includes/post-installation.md"

### Docker-specific checks

#### Check Docker version:

```bash
docker --version
```

#### Run a test container:

```bash
docker run hello-world
```

#### Check service health:

```bash
systemctl status docker
```

#### If you can’t run Docker without sudo:

```bash
newgrp docker
```

---

## 🧹 Uninstallation / Cleanup

To remove Docker and all related components:

```bash
sudo apt remove -y docker-ce docker-ce-cli containerd.io
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
```

---

## 🐛 Troubleshooting

### Docker service not running

```bash
sudo systemctl restart docker
sudo systemctl status docker
```

### GPG key issues

```bash
sudo rm /etc/apt/keyrings/docker.asc
```

Then rerun installer.

### Cannot access registry / TLS errors

Update CA certificates:

```bash
sudo apt install --reinstall ca-certificates
```

---

## 📘 Official Documentation

Docker Engine Installation:
[https://docs.docker.com/engine/install/](https://docs.docker.com/engine/install/)
