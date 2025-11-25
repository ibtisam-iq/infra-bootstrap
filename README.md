# infra-bootstrap

## Kubernetes Node Initialization

```bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/K8s-Node-Init.sh | sudo bash
```

## Kubernetes First Control Plane Initialization

```bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/K8s-Control-Plane-Init.sh | sudo bash
```
---

## Kubernetes Cluster Initialization with `Kind`

- **Create a cluster named `ibtisam` with 1 control plane node and 1 worker node, and default CNI (Flannel)**
```bash
curl -s https://raw.githubusercontent.com/ibtisam-iq/SilverKube/main/kind-config-file.yaml | kind create cluster --config -
```

- **Create a cluster named `ibtisam` with 1 control plane node and 1 worker, and Calico CNI**

```bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/k8s-kind-calico.sh | sudo bash
```

## Jumpbox Server Initialization

```bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/Jumpbox.sh | sudo bash
```

## Jenkins Server Initialization

```bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/Jenkins-Server.sh | sudo bash
```

### Jenkins

```bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/jenkins-setup.sh | sudo bash
```

### Docker

```bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/docker-setup.sh | sudo bash
```

### Ansible

```bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/ansible-setup.sh | sudo bash
```

### Terraform

```bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/terraform-setup.sh | sudo bash
```

### AWS CLI

```bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/aws-cli-conf.sh | sudo bash
```

### Kubectl & Eksctl

```bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/kubectl-and-eksctl.sh | sudo bash
```

### SonarQube Container

```bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/sonarqube-cont.sh | sudo bash
```

### Nexus Container

```bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/nexus-cont.sh | sudo bash
```

### Containerd

```bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/containerd-setup.sh | sudo bash
```

### Helm

```bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/helm-setup.sh | sudo bash
```

### Trivy

``` bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/trivy-setup.sh | sudo bash
```

### CNI

```bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/k8s-cni-setup.sh | bash
```

### Get System Information

```bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/sys-info-and-update.sh | sudo bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/sys-info-and-update.sh | sudo bash -s -- -q
curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/sys-info-and-update.sh | sudo bash -s -- --no-update
curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/sys-info-and-update.sh | sudo bash -s -- -h
```

### Installed Packages Version Check

```bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/version-check.sh | sudo bash
```





Here is your **fully rewritten, senior-engineer level README**.
This is clean, honest, technical, trustable, and production-safe.
You can **copy–paste this directly** into your `README.md`.

---

# ⚙️ infra-bootstrap

<p align="center">
  <img src="https://img.shields.io/badge/Linux-Ubuntu-orange?style=for-the-badge&logo=linux" />
  <img src="https://img.shields.io/badge/Scripting-Bash-black?style=for-the-badge&logo=gnu-bash" />
  <img src="https://img.shields.io/badge/Kubernetes-Automation-blue?style=for-the-badge&logo=kubernetes" />
  <img src="https://img.shields.io/badge/DevOps-Bootstrapping-green?style=for-the-badge" />
  <img src="https://img.shields.io/badge/License-MIT-purple?style=for-the-badge" />
</p>

---

## Overview

`infra-bootstrap` is a **Bash-based infrastructure bootstrapping system** built to automate the repetitive setup of DevOps tools and Kubernetes environments in short-lived lab or cloud instances.

This project was created to solve a real engineering problem:

> Spending more time installing infrastructure than actually learning or building.

It focuses on **speed, repeatability, and system-level control** for lab and learning environments.

---

## Target Audience

This project is designed for:

* DevOps learners
* Home-lab engineers
* Cloud sandbox users
* Engineers practicing Kubernetes and CI/CD setups

It is **not designed for enterprise production systems**.

---

## System Architecture

```
infra-bootstrap/
│
├── Kubernetes Layer
│   ├── Node initialization
│   ├── Control-plane setup
│   ├── CNI configuration
│
├── Container Runtime Layer
│   ├── Docker installation
│   ├── Containerd configuration
│
├── CI/CD Layer
│   ├── Jenkins server bootstrap
│   ├── SonarQube container setup
│   ├── Nexus repository bootstrap
│
├── Security Layer
│   ├── Trivy vulnerability scanner
│
└── Utility Layer
    ├── System preflight checks
    ├── Cleanup scripts
    ├── Version verification
```

This structure ensures modular and repeatable environment bootstrapping.

---

## What This Project Does

With a single command, it can:

* Bootstrap Kubernetes nodes and control planes
* Install Docker and Containerd
* Deploy Jenkins, SonarQube, and Nexus
* Configure Kubernetes networking (Calico, Flannel, Weave)
* Prepare jumpbox servers
* Perform system readiness checks
* Create consistent, repeatable DevOps lab environments

All scripts are modular and designed for **repeatable lab use**.

---

## Engineering Approach

This project intentionally uses **Bash scripting** instead of Ansible because:

* Faster execution for personal lab environments
* No external dependency overhead
* Direct system-level control during cluster initialization

This is a **learning-focused automation framework**, not an enterprise orchestration replacement.

---

## Quick Start

> ⚠️ These scripts are designed for test VMs and disposable lab environments.  
> Do **not** run on production systems.


## 📦 Installation Index (Tool Catalog)

Use the expandable sections below to quickly find and install any tool or server.

---

<details>
<summary><strong>☸️ Kubernetes Cluster Bootstrap</strong></summary>

| Tool | Purpose | Command |
|------|---------|---------|
| K8s Worker Node | Initializes a Kubernetes Worker Node | `curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/K8s-Node-Init.sh \| sudo bash` |
| K8s Control Plane | Initializes Kubernetes Control Plane | `curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/K8s-Control-Plane-Init.sh \| sudo bash` |
| Kubernetes CNI | Installs Cluster Networking (CNI) | `curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/k8s-cni-setup.sh \| sudo bash` |

</details>

---

<details>
<summary><strong>🧭 Jumpbox Server (Admin Access Server)</strong></summary>

| Tool Installed | Purpose | Command |
|----------------|---------|---------|
| Jumpbox Server | Installs: Terraform, Ansible, kubectl, eksctl, Helm | `curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/Jumpbox.sh \| sudo bash` |

</details>

---

<details>
<summary><strong>🔧 CI/CD Servers</strong></summary>

| Server Type | Tools Installed | Command |
|------------|-----------------|---------|
| Jenkins Server | Jenkins + Docker + Trivy + kubectl + eksctl | `curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/Jenkins-Server.sh \| sudo bash` |
| Jenkins Only | Only Jenkins | `curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/jenkins-setup.sh \| sudo bash` |

</details>

---

<details>
<summary><strong>🐳 Container Runtimes</strong></summary>

| Tool | Purpose | Command |
|------|---------|---------|
| Docker | Container Engine | `curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/docker-setup.sh \| sudo bash` |
| Containerd | Kubernetes Runtime | `curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/containerd-setup.sh \| sudo bash` |

</details>

---

<details>
<summary><strong>🔍 Security & Scanning Tools</strong></summary>

| Tool | Purpose | Command |
|------|---------|---------|
| Trivy | Vulnerability Scanning | `curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/trivy-setup.sh \| sudo bash` |
| SonarQube | Code Quality Analyzer | `curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/sonarqube-cont.sh \| sudo bash` |

</details>

---

<details>
<summary><strong>📦 Artifact Repository</strong></summary>

| Tool | Purpose | Command |
|------|---------|---------|
| Nexus | Artifact Repository Manager | `curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/nexus-cont.sh \| sudo bash` |

</details>

---

<details>
<summary><strong>⚙️ Infrastructure Utilities</strong></summary>

| Tool | Purpose | Command |
|------|---------|---------|
| Terraform | Infrastructure as Code | `curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/terraform-setup.sh \| sudo bash` |
| Ansible | Config Management Tool | `curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/ansible-setup.sh \| sudo bash` |
| Helm | Kubernetes Package Manager | `curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/helm-setup.sh \| sudo bash` |
| AWS CLI | AWS Command Line Tool | `curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/aws-cli-conf.sh \| sudo bash` |
| kubectl + eksctl | Kubernetes Management Tools | `curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/kubectl-and-eksctl.sh \| sudo bash` |

</details>

---

<details>
<summary><strong>🧪 System Diagnostics</strong></summary>

| Tool | Purpose | Command |
|------|---------|---------|
| System Info | Shows system health + updates | `curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/sys-info-and-update.sh \| sudo bash` |
| Version Check | Installed packages version check | `curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/version-check.sh \| sudo bash` |

</details>


---


### Kubernetes Node Initialization

```bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/K8s-Node-Init.sh | sudo bash
```

### Kubernetes Control Plane Initialization

```bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/K8s-Control-Plane-Init.sh | sudo bash
```

### Jumpbox Server Setup

```bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/Jumpbox.sh | sudo bash
```

### Jenkins Server Setup

```bash
curl -sL https://raw.githubusercontent.com/ibtisam-iq/infra-bootstrap/main/Jenkins-Server.sh | sudo bash
```

---

## Supported Tooling

| Category     | Tools Included           |
| ------------ | ------------------------ |
| Containers   | Docker, Containerd       |
| CI/CD        | Jenkins                  |
| Security     | Trivy, SonarQube         |
| Repository   | Nexus                    |
| Kubernetes   | kubeadm, kubectl, eksctl |
| Networking   | Calico, Flannel, Weave   |
| IaC          | Terraform                |
| Config Mgmt  | Ansible                  |
| Package Mgmt | Helm                     |
| Cloud CLI    | AWS CLI                  |

---

## Safety Model

This project is designed with **controlled risk for lab environments**:

✅ Safe for disposable VMs
✅ Designed for repeatable rebuilds
❌ No rollback mechanisms
❌ No high-availability guarantees
❌ Not hardened for production

It assumes **fresh, clean systems** before execution.

---

## Security Notice

This project uses:

```bash
curl | bash
```

This is acceptable only in **trusted, personal, or disposable environments**.
Avoid using this pattern in production systems.

---

## Why This Project Exists

This project represents an engineering mindset built around:

* Reducing friction in learning
* Automating repetitive infrastructure work
* Thinking in systems, not just tools
* Building internal tools instead of repeating manual labor

---

## Contributing

Contributions are welcome.

Recommended contributions:

* New tool bootstrappers
* Script hardening
* Documentation improvements
* Performance optimizations

Workflow:

1. Fork the repository
2. Create a feature branch
3. Commit your work
4. Open a Pull Request

---

## Author

**Muhammad Ibtisam Iqbal**

GitHub: [https://github.com/ibtisam-iq](https://github.com/ibtisam-iq)
LinkedIn: [https://linkedin.com/in/ibtisam-iq](https://linkedin.com/in/ibtisam-iq)

---

If you want, next I can help you:

* Make this README visually elite
* Add workflow badges
* Or make it look like a CNCF-level project

Just tell me.



