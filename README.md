
# ☁️ AWS EKS Cluster with Bastion Access - Terraform Project

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
- Configured to allow public access only from your IP (Picksup Automatically)
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
