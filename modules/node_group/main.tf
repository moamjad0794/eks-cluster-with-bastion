# IAM Role for Node Group
resource "aws_iam_role" "node_role" {
  name = "eksNodeGroupRole"
  assume_role_policy = data.aws_iam_policy_document.node_assume_role.json
}

# Assume Role Policy Document
data "aws_iam_policy_document" "node_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Attach Required Policies to Node Role
resource "aws_iam_role_policy_attachment" "worker_node_policies" {
  count      = length(var.worker_node_policies)
  role       = aws_iam_role.node_role.name
  policy_arn = var.worker_node_policies[count.index]
}

# EKS Node Group
resource "aws_eks_node_group" "node_group" {
  cluster_name    = var.cluster_name
  node_group_name = "eks-node-group"
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }
  instance_types = ["t3.medium"]
  capacity_type  = "ON_DEMAND"

  depends_on = [aws_iam_role_policy_attachment.worker_node_policies]
}
