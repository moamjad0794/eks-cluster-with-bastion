module "node_group" {
  source             = "../modules/node_group"
  cluster_name       = module.eks_cluster.cluster_name
  private_subnet_ids = module.vpc.private_subnet_ids
}
