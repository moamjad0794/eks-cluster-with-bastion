resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Allow SSH access from local IP"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [data.external.myip.result["ip"]]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "bastion-sg"
    Environment = "dev"
    Project     = "eks-lab"
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

module "bastion" {
  source            = "../modules/bastion"
  ami_id            = data.aws_ami.amazon_linux.id
  instance_type     = "t3.micro"
  subnet_id         = module.vpc.public_subnet_ids[0]
  security_group_id = aws_security_group.bastion_sg.id
  key_name          = "my-bastionhost-key-01"
  user_data         = file("${path.module}/get-my-ip.sh")
  depends_on = [
    aws_security_group.bastion_sg,
    module.vpc
  ]
}
