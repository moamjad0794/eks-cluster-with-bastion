#!/bin/bash

yum update -y --skip-broken
yum install -y git curl unzip bash-completion jq aws-cli --skip-broken

# Download latest kubectl
curl -LO "https://dl.k8s.io/release/v1.33.1/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip

# Install Docker
yum install -y docker
systemctl start docker
systemctl enable docker

# Add user to docker group
usermod -aG docker ec2-user
