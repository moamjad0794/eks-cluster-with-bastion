
## ☁️ AWS EKS Cluster with Bastion Access - Terraform Project

This project provisions a complete Kubernetes environment on AWS using Terraform. It includes a secure VPC, a managed EKS cluster with public and private subnets, a Bastion Host for secure access, sample web applications, ingress routing, and monitoring with Prometheus and Grafana.

---

## Architecture Overview

### AWS Resources Created

#### 1. **VPC**
- A custom Virtual Private Cloud with CIDR block `10.0.0.0/16`
- Created using the `modules/vpc/` module

#### 2. **Subnets**
- **Public Subnets** (e.g., `10.0.1.0/24`, `10.0.2.0/24`)
  - Used for:
    - Bastion Host
    - NAT Gateway
    - Load Balancer (Ingress)
- **Private Subnets** (e.g., `10.0.3.0/24`, `10.0.4.0/24`)
  - Used for:
    - EKS Worker Nodes
    - Kubernetes workloads

#### 3. **Internet Gateway (IGW)**
- Allows traffic from Public Subnets to access the internet

#### 4. **NAT Gateway**
- Placed in a public subnet
- Allows private subnet resources (e.g., EKS nodes) to access the internet securely (e.g., for pulling container images)

#### 5. **Route Tables**
- One for public subnets: routes traffic via IGW
- One for private subnets: routes traffic via NAT Gateway

---

## 🔐 SSH Key-Based Access to Bastion Host

### Why We Use It

To securely access the Bastion Host (deployed in a public subnet), we use **pre-generated SSH key pairs** managed via AWS EC2. This avoids hardcoding sensitive credentials and ensures secure authentication.

---

### 🔧 How It Works

1. **Create a Key Pair in AWS Console**:

   - Go to: **EC2 → Network & Security → Key Pairs**
   - Click **Create Key Pair**
   - Name it: `my-bastionhost-key-01` (or match the name used in your Terraform code)
   - Download the `.pem` file and save it securely (e.g., `~/.ssh/my-bastionhost-key-01.pem`)

2. **Reference This Key in Terraform**:

   In your `development/bastion.tf`, you reference this key by name:

   ```hcl
   module "bastion" {
     source            = "../modules/bastion"
     ami_id            = data.aws_ami.amazon_linux.id
     instance_type     = "t3.micro"
     subnet_id         = module.vpc.public_subnet_ids[0]
     security_group_id = aws_security_group.bastion_sg.id
     key_name          = "my-bastionhost-key-01"  # Pre-created in AWS
     user_data         = file("${path.module}/get-my-ip.sh")

     depends_on = [
       aws_security_group.bastion_sg,
       module.vpc
     ]
   }
   ```

3. **Connect to Bastion via SSH**:

   Once deployed, SSH into the instance:

   ```bash
   ssh -i ~/.ssh/my-bastionhost-key-01.pem ec2-user@<bastion-public-ip>
   ```

   Ensure proper permissions:

   ```bash
   chmod 400 ~/.ssh/my-bastionhost-key-01.pem
   ```

   From the Bastion, you can run:

   ```bash
   aws eks update-kubeconfig --region us-east-1 --name myekscluster
   kubectl get nodes
   ```

---

#### 6. **Bastion Host**
- EC2 instance in a public subnet
- Accessed using SSH from your local machine
- Configured with EKS access policies
- Used by other users (non-creators) to interact with the EKS cluster securely

#### 7. **IAM Roles and Policies**
- Cluster Role (`eksClusterRole`)
- Node Group Role
- Bastion Host Instance Role with policies to assume role and access EKS

#### 8. **EKS Cluster**
- Control Plane is managed by AWS
- Configured to allow public access only from your IP (Picks up Automatically)
- Private endpoint for internal communications

#### 9. **EKS Managed Node Group**
- Worker nodes in private subnets
- Auto-scaling enabled
- Nodes automatically join the cluster

---

## 👩‍💻 Access Strategy

- **You (Cluster Creator)**:
  - IP is added to public access CIDRs of EKS during provisioning
  - Use AWS STS credentials to update kubeconfig and access the cluster

- **Others (Team Members)**:
  - Must SSH into the Bastion Host
  - From there, can run `aws eks update-kubeconfig` and use `kubectl`

---

## 🌍 Applications Deployed

- `home`: Serves root endpoint `/`
- `food`: Serves `/food`
- `travel`: Serves `/travel`

Deployed using:

- Kubernetes `Deployment` + `Service` (ClusterIP)
- Single `Ingress` resource routing to all three apps

---

## 📊 Monitoring Stack

- Installed via `monitoring-eks/monitoring-stack.sh`
- Deploys:
  - Prometheus
  - Alertmanager
  - Grafana

Accessible via LoadBalancer service once deployed.
Metrics include:
- Node/Pod/Cluster CPU, memory usage
- Ingress logs
- (Note: App-level metrics not yet exposed)

---

## 🧽 Clean-Up

```bash
cd development/
terraform destroy -auto-approve

kubectl delete -f kubernetes-manifest/all-deployments/
kubectl delete -f kubernetes-manifest/common-ingress/ingress.yaml
kubectl delete namespace monitoring
```

---

## 🛠️ Useful Commands and Explanations

Below is a set of essential commands used throughout this project, along with what each command does.

---

### 🔁 AWS EKS Access and Context Management

```bash
aws eks update-kubeconfig --region us-east-1 --name myekscluster
kubectl config get-contexts
kubectl config use-context arn:aws:eks:us-east-1:580420848811:cluster/myekscluster
kubectl config use-context myekscluster
kubectl edit configmap aws-auth -n kube-system
```

---

### 🚀 Ingress Controller Installation (NGINX)

```bash
# Install Helm
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

# Add and update repo
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Install NGINX Ingress
helm install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace

# Uninstall
helm uninstall ingress-nginx -n ingress-nginx
kubectl delete namespace ingress-nginx
```

---

### 📈 Monitoring Stack (Prometheus + Grafana)

```bash
# Add Prometheus Helm repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install monitoring stack
helm install monitoring prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace

# Uninstall
helm uninstall monitoring -n monitoring
kubectl delete namespace monitoring
```

---

### 🌐 Accessing Grafana Dashboard

```bash
# Get LoadBalancer URL
kubectl get svc -n monitoring

# Get Grafana admin password
kubectl get secret -n monitoring monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 --decode && echo
```
