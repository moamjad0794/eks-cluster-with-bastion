output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks_cluster.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = module.eks_cluster.cluster_endpoint
}

output "eks_cluster_ca" {
  description = "EKS cluster certificate authority data"
  value       = module.eks_cluster.cluster_certificate_authority
}

output "node_group_name" {
  description = "EKS node group name"
  value       = module.node_group.node_group_name
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = module.bastion.bastion_public_ip
}

# output "eks_admin_role_arn" {
#   description = "ARN of the EKS admin IAM role"
#   value       = aws_iam_role.admin_role.arn
# }

# output "eks_dev_role_arn" {
#   description = "ARN of the EKS developer IAM role"
#   value       = aws_iam_role.dev_role.arn
# }

# output "eks_readonly_role_arn" {
#   description = "ARN of the EKS read-only IAM role"
#   value       = aws_iam_role.ro_role.arn
# }
