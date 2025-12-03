# 📄 Terraform Installation (terraform-setup.sh)

--8<-- "includes/preflight.md"
--8<-- "includes/system-requirements.md"
--8<-- "includes/cli-flags.md"
--8<-- "includes/error-handling.md"

---

## 🧭 Overview

This installer configures the official **HashiCorp Terraform** package repository and installs Terraform through the system package manager (`apt`).

The goal is a **clean, repeatable, and trusted** installation process suitable for:

* Infrastructure automation
* Cloud provisioning
* Lab and training environments
* CI/CD workflows
* Disposable VM environments

Terraform is installed directly from **HashiCorp’s official repository**, ensuring authenticity and latest stable releases.

---

## 🚀 Installation Command

```bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/terraform-setup.sh | sudo bash
```

---

## 🛠 How the Installer Works (Step-by-Step Breakdown)

### **1. Preflight Validation**

--8<-- "includes/preflight.md"

---

### **2. Existing Installation Check**

If Terraform already exists, the installer:

* Prints the installed version
* Exits cleanly without making changes

This ensures idempotent (repeatable) behavior.

---

### **3. Install Package Dependencies**

The script installs required system dependencies:

* `software-properties-common`
* `lsb-release`
* `gnupg`
* `curl`
* `wget`

These packages enable:

* Repository signing
* Key installation
* OS codename detection
* Reliable downloads

---

### **4. Add HashiCorp’s Official GPG Key**

The installer retrieves and stores the key securely:

```
/usr/share/keyrings/hashicorp-archive-keyring.gpg
```

This ensures all HashiCorp packages are validated cryptographically before installation.

---

### **5. Add HashiCorp APT Repository**

The script adds:

```
deb [arch=amd64 signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com <ubuntu-codename> main
```

This ensures Terraform is always installed from an **authentic, trusted source**.

---

### **6. Install Terraform**

Runs a final update and installs:

```
terraform
```

After installation, it verifies the installed version automatically.

---

## 🧪 Post-Installation Verification

--8<-- "includes/post-installation.md"

### Terraform-specific checks

#### Check version:

```bash
terraform version
```

#### Verify plugin system:

```bash
terraform -help
```

#### Run a quick init:

```bash
mkdir test-tf && cd test-tf
echo 'terraform {}' > main.tf
terraform init
```

---

## 🧹 Uninstallation / Cleanup

```bash
sudo apt remove -y terraform
sudo rm /etc/apt/sources.list.d/hashicorp.list
sudo rm /usr/share/keyrings/hashicorp-archive-keyring.gpg
```

---

## 🐛 Troubleshooting

### Repository key issues

```bash
sudo rm /usr/share/keyrings/hashicorp-archive-keyring.gpg
```

Then rerun installer.

### apt errors

Ensure your system clock is correct:

```bash
timedatectl
```

### Terraform not found after install

Make sure `/usr/bin` is in PATH:

```bash
echo $PATH
```

---

## 📘 Official Documentation

HashiCorp Terraform Installation:
[https://developer.hashicorp.com/terraform/downloads](https://developer.hashicorp.com/terraform/downloads)

