data "external" "myip" {
  program = ["bash", "${path.module}/get-my-ip.sh"]
}

module "eks_cluster" {
  source             = "../modules/eks_cluster"
  cluster_name       = "myekscluster"
  private_subnet_ids = module.vpc.private_subnet_ids
  allowed_cidrs      = [data.external.myip.result["ip"]]
  vpc_cidr_block     = module.vpc.vpc_cidr_block
}
