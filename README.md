# Automated Multi-Tier Application Deployment - Online Boutique

## Project Overview
This project deploys Google's **Online Boutique** microservices application on AWS using a complete infrastructure automation stack.

### Architecture Stack
- **Containerization**: Docker (container images)
- **IaC**: Terraform (AWS resources)
- **Configuration**: Ansible (EC2 setup & Kubernetes initialization)
- **Orchestration**: Kubernetes (microk8s on EC2)
- **CI/CD**: GitHub Actions + ArgoCD (automated deployment)

---

## Prerequisites

### Required AWS Setup (BEFORE starting this guide)
1. **AWS Account**: Must have an active AWS account
2. **IAM User**: Create an IAM user with these permissions:
   - EC2 full access
   - VPC full access
   - Security Groups full access
3. **AWS CLI Credentials**: Configure credentials locally
   ```bash
   aws configure
   # Enter: Access Key ID, Secret Access Key, Region (us-east-1), Output format (json)
   ```
4. **EC2 Key Pair**: Create a key pair in AWS console
   - Go to EC2 → Key Pairs → Create key pair
   - Download and save as `~/.ssh/online-boutique.pem`
   - Set permissions: `chmod 600 ~/.ssh/online-boutique.pem`

### Required Local Tools
- Docker (installed and running)
- Terraform (v1.0+)
- Ansible (v2.9+)
- kubectl (v1.20+)
- git
- GitHub account

### Installation Commands (if needed)
```bash
# macOS
brew install terraform ansible kubectl

# Ubuntu/Debian
sudo apt-get install terraform ansible kubectl

# Windows (using Chocolatey)
choco install terraform ansible kubectl
```

---

## Project Structure
```
online-boutique-deployment/
├── README.md                          # This file
├── src/                              # Application source code
│   ├── frontend/
│   ├── backend/
│   └── ... (other microservices)
├── docker/                           # Dockerfiles for each service
│   ├── Dockerfile.frontend
│   ├── Dockerfile.backend
│   └── ... (one per microservice)
├── terraform/                        # AWS infrastructure
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars
├── ansible/                          # EC2 configuration
│   ├── playbook.yml
│   ├── inventory.ini
│   └── roles/
├── kubernetes/                       # K8s manifests
│   ├── namespace.yaml
│   ├── services/
│   ├── deployments/
│   └── argocd/
└── .github/workflows/                # CI/CD pipelines
    └── deploy.yml
```

---

## Step-by-Step Deployment Guide

### PHASE 1: Clone Application & Setup Repository

#### Step 1a: Clone Online Boutique
```bash
cd ~
git clone https://github.com/GoogleCloudPlatform/microservices-demo.git
cd microservices-demo
```

#### Step 1b: Explore the microservices
```bash
# See what microservices are included
ls src/
# You'll see: adservice, cartservice, checkoutservice, currencyservice, 
#            emailservice, frontend, loadgenerator, orderingservice, 
#            paymentservice, productcatalogservice, recommendationservice, shippingservice
```

#### Step 1c: Create your deployment repository
```bash
# Create new repo on GitHub:
# 1. Go to github.com → New Repository
# 2. Name it: "online-boutique-deployment"
# 3. Clone it locally
git clone https://github.com/YOUR-USERNAME/online-boutique-deployment.git
cd online-boutique-deployment
```

---

### PHASE 2: Containerization (Docker)

#### Step 2a: Create Dockerfile for Each Microservice

For each microservice in src/, create a Dockerfile. Here are the templates:

**Frontend Service** (Node.js + React)
```dockerfile
# File: docker/Dockerfile.frontend
FROM node:16-alpine AS builder
WORKDIR /app
COPY ./src/frontend/package*.json ./
RUN npm install
COPY ./src/frontend .
RUN npm run build

FROM node:16-alpine
WORKDIR /app
RUN npm install -g serve
COPY --from=builder /app/build ./build
EXPOSE 3000
CMD ["serve", "-s", "build", "-l", "3000"]
```

**Backend Services** (Python/Go - varies by service)

---

### PHASE 3: Infrastructure as Code (Terraform)

#### Step 3a: Set up Terraform directory
```bash
mkdir -p terraform
cd terraform
```

#### Step 3b: Create Terraform configuration files
(See detailed files in next section)

#### Step 3c: Deploy infrastructure
```bash
terraform init
terraform plan
terraform apply
```

This creates:
- VPC with public/private subnets
- Security groups (ports 22, 80, 443, 8080, etc.)
- EC2 instance (Ubuntu 20.04, t3.medium)
- Elastic IP

---

### PHASE 4: Configuration Management (Ansible)

#### Step 4a: Update inventory with EC2 IP
After Terraform completes, get the EC2 IP:
```bash
terraform output ec2_public_ip
```

Update `ansible/inventory.ini` with this IP.

#### Step 4b: Run Ansible playbook
```bash
cd ansible
ansible-playbook -i inventory.ini playbook.yml -u ubuntu
```

This installs:
- Docker
- Kubernetes (microk8s)
- kubectl
- ArgoCD
- Git

---

### PHASE 5: Kubernetes Manifests

#### Step 5a: Create Kubernetes manifests for each service
```bash
mkdir -p kubernetes/deployments
mkdir -p kubernetes/services
mkdir -p kubernetes/configmaps
```

For each microservice, create:
- `deployment.yaml` (Kubernetes Deployment)
- `service.yaml` (Kubernetes Service)
- `configmap.yaml` (if needed for config)

#### Step 5b: Apply manifests to cluster
```bash
kubectl apply -f kubernetes/
```

---

### PHASE 6: CI/CD Pipeline (GitHub Actions + ArgoCD)

#### Step 6a: Set up GitHub Actions
Create `.github/workflows/deploy.yml` that:
1. Triggers on push to main
2. Builds Docker images
3. Pushes to Docker Hub/ECR
4. Updates Kubernetes manifests with new image tags
5. Commits changes to repo

#### Step 6b: Configure ArgoCD
ArgoCD will monitor the repo and automatically:
1. Detect manifest changes
2. Sync with Kubernetes cluster
3. Deploy new versions automatically

---

### PHASE 7: Verification & Testing

#### Step 7a: Verify EC2 instance
```bash
ssh -i ~/.ssh/online-boutique.pem ubuntu@<EC2-IP>
kubectl get pods
kubectl get services
```

#### Step 7b: Access the application
```bash
# Get the LoadBalancer IP
kubectl get svc -A

# Open in browser: http://<FRONTEND-IP>:80
```

#### Step 7c: Test CI/CD
1. Make a change to the code
2. Push to GitHub
3. GitHub Actions builds Docker image
4. ArgoCD detects changes and deploys
5. Application updates automatically

---

## Key Concepts Explained

### 1. Docker
- **What**: Containers package your application + dependencies
- **Why**: Consistent behavior across dev, test, and production
- **How**: Dockerfile → Docker image → Docker container

### 2. Terraform
- **What**: Infrastructure as Code for AWS
- **Why**: Version control your infrastructure, reproducible deployments
- **How**: .tf files → `terraform apply` → AWS resources created

### 3. Ansible
- **What**: Configuration management tool
- **Why**: Automate EC2 setup (install software, configure services)
- **How**: YAML playbooks → SSH into EC2 → Execute commands

### 4. Kubernetes
- **What**: Container orchestration platform
- **Why**: Manages containers, scaling, networking, storage
- **How**: YAML manifests → `kubectl apply` → Pods/Services created

### 5. GitHub Actions
- **What**: CI/CD pipeline that runs on GitHub
- **Why**: Automated testing and deployment on code changes
- **How**: Triggered by git push → runs jobs (build, test, deploy)

### 6. ArgoCD
- **What**: GitOps tool for Kubernetes
- **Why**: Git becomes source of truth; ArgoCD keeps cluster in sync
- **How**: Monitors repo → detects changes → auto-syncs cluster

---

## Common Issues & Solutions

### Issue: `terraform init` fails
**Solution**: Check AWS credentials
```bash
aws configure
```

### Issue: Ansible can't connect to EC2
**Solution**: Check security group allows SSH (port 22) and update inventory IP

### Issue: Pods stuck in Pending
**Solution**: Check resources
```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Issue: ArgoCD can't access repo
**Solution**: Generate GitHub personal access token and configure in ArgoCD

---

## Cleanup (Delete all resources)

```bash
# Delete Kubernetes resources
kubectl delete -f kubernetes/

# Delete EC2 and networking
cd terraform
terraform destroy

# Delete GitHub webhook (manual in ArgoCD UI)
```

---

## Next Steps

1. ✅ Follow PHASE 1-7 in order
2. ✅ Replace placeholder values with your actual AWS/GitHub info
3. ✅ Test each phase before moving to the next
4. ✅ Document any custom configurations in this README
5. ✅ Keep the repository updated as you make changes

---

## Support Resources

- Terraform Docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- Ansible Docs: https://docs.ansible.com/
- Kubernetes Docs: https://kubernetes.io/docs/
- ArgoCD Docs: https://argo-cd.readthedocs.io/
- Online Boutique Repo: https://github.com/GoogleCloudPlatform/microservices-demo

---

**Last Updated**: 2026
**Maintainer**: NIMRA ASLAM
