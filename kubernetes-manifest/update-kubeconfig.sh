#!/bin/bash
# aws eks update-kubeconfig --region <region> --name <cluster_name>
# kubectl config get-contexts
aws eks update-kubeconfig --region us-east-1 --name myekscluster
kubectl config use-context arn:aws:eks:us-east-1:580420848811:cluster/myekscluster
kubectl config use-context myekscluster

kubectl edit configmap aws-auth -n kube-system
