module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.5.1"

  cluster_name                   = local.unique_cluster_name
  cluster_version                = var.kubernetes_version
  vpc_id                         = var.create_vpc ? module.vpc.vpc_id : var.existing_vpc_id
  subnet_ids                     = var.create_vpc ? module.vpc.private_subnets : var.existing_vpc_subnet_ids
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = var.ami_type

  }

  eks_managed_node_groups = { for i, g in var.eks_managed_node_groups : g.name => g }

}
