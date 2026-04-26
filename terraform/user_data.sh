#!/bin/bash
# File: terraform/user_data.sh
# This script runs on EC2 instance startup to install basic dependencies

set -e

echo "=== Online Boutique EC2 Bootstrap ==="
echo "Project: ${project_name}"

# Update system
echo "Updating system packages..."
apt-get update
apt-get upgrade -y

# Install Docker
echo "Installing Docker..."
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Start Docker and enable at boot
systemctl start docker
systemctl enable docker

# Add ubuntu user to docker group (allows running docker without sudo)
usermod -aG docker ubuntu

# Install required tools
echo "Installing additional tools..."
apt-get install -y \
    git \
    curl \
    wget \
    unzip \
    jq \
    python3-pip \
    apt-transport-https

# Install kubectl
echo "Installing kubectl..."
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubectl

# Install microk8s (lightweight Kubernetes)
echo "Installing microk8s..."
apt-get install -y microk8s

# Start microk8s and enable at boot
systemctl start microk8s
systemctl enable microk8s

# Add ubuntu user to microk8s group
usermod -aG microk8s ubuntu

# Wait for microk8s to be ready
echo "Waiting for microk8s to be ready..."
microk8s status --wait-ready

# Enable necessary addons
echo "Enabling microk8s addons..."
microk8s enable dns
microk8s enable storage
microk8s enable ingress
microk8s enable rbac

# Create kubeconfig for ubuntu user
echo "Setting up kubeconfig..."
mkdir -p /home/ubuntu/.kube
microk8s config > /home/ubuntu/.kube/config
chown -R ubuntu:ubuntu /home/ubuntu/.kube

# Install Helm (package manager for Kubernetes)
echo "Installing Helm..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install ArgoCD
echo "Installing ArgoCD..."
microk8s kubectl create namespace argocd || true
microk8s kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
echo "Waiting for ArgoCD to be ready..."
sleep 30

# Create ArgoCD ingress
echo "Creating ArgoCD ingress..."
cat > /tmp/argocd-ingress.yaml <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-server-ingress
  namespace: argocd
spec:
  ingressClassName: nginx
  rules:
  - host: argocd.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: argocd-server
            port:
              number: 80
EOF
microk8s kubectl apply -f /tmp/argocd-ingress.yaml || true

# Get initial ArgoCD password
echo "Retrieving ArgoCD initial admin password..."
ARGOCD_PASSWORD=$(microk8s kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d) || true
echo "ArgoCD Password: $ARGOCD_PASSWORD" > /tmp/argocd-credentials.txt

# Create application manifest directory
mkdir -p /home/ubuntu/manifests
chown -R ubuntu:ubuntu /home/ubuntu/manifests

# Pull microservices-demo repository
echo "Cloning Online Boutique repository..."
cd /home/ubuntu
git clone https://github.com/GoogleCloudPlatform/microservices-demo.git
chown -R ubuntu:ubuntu microservices-demo

echo "=== Bootstrap Complete ==="
echo "Docker: $(docker --version)"
echo "kubectl: $(kubectl version --client --short 2>/dev/null || echo 'Installed')"
echo "microk8s: Installed and running"
echo "Helm: Installed"
echo "ArgoCD: Deployed to namespace 'argocd'"
