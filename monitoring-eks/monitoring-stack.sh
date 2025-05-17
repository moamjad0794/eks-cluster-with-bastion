#!/bin/bash

set -e

# Function to install Helm
install_helm() {
  echo "Installing Helm..."
  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
  echo "Helm installed successfully."
}

# Check if Helm is installed
if ! command -v helm &> /dev/null; then
  echo "Helm not found."
  install_helm
else
  echo "Helm is already installed: $(helm version --short)"
fi

# Add Prometheus Community repo
echo "Adding prometheus-community Helm repo..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Create monitoring namespace
echo "Creating namespace 'monitoring'..."
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Install kube-prometheus-stack
echo "Installing kube-prometheus-stack..."
helm install kube-prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set grafana.service.type=LoadBalancer \
  --set prometheus.service.type=LoadBalancer

# Wait for services to get external IP
echo "Waiting for Grafana service external IP..."
sleep 20
kubectl get svc -n monitoring

# Get Grafana admin password
echo "Grafana admin password:"
kubectl get secret -n monitoring kube-prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode
echo -e "\n"

echo "Access Grafana and Prometheus:"
echo "  - Run: kubectl get svc -n monitoring"
echo "  - Look for external IPs on 'kube-prometheus-grafana' and 'kube-prometheus-prometheus'"
