# ---------- IAM Role for Bastion ----------
resource "aws_iam_role" "bastion_role" {
  name = "bastionRole"

  assume_role_policy = data.aws_iam_policy_document.bastion_assume.json
}

data "aws_iam_policy_document" "bastion_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Since you're giving full permissions on ec2 bation make sure to grant full permissions using aws-auth as well
# - rolearn: arn:aws:iam::<your-account-id>:role/bastionRole
#   username: bastion
#   groups:
#     - system:masters

# ---------- Inline Policy for Full EKS Access ----------
resource "aws_iam_policy" "eks_kubectl_access" {
  name = "BastionEKSFullAccess"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "eks:*",
        Resource = "*"
      }
    ]
  })
}

# ---------- Attach the Inline Policy ----------
resource "aws_iam_role_policy_attachment" "bastion_eks_policy_attach" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = aws_iam_policy.eks_kubectl_access.arn
}

# ---------- IAM Instance Profile ----------
resource "aws_iam_instance_profile" "bastion_profile" {
  name = "bastionProfile"
  role = aws_iam_role.bastion_role.name
}

# ---------- Bastion EC2 Instance ----------
resource "aws_instance" "bastion" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.bastion_profile.name
  key_name                    = var.key_name
  user_data                   = file("${path.module}/user_data.sh")

  tags = {
    Name = "BastionHost"
  }
}
