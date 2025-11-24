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
