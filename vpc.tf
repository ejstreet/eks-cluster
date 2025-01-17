module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  create_vpc = var.create_vpc

  name = "${local.unique_cluster_name}-vpc"

  cidr = var.vpc_cidr
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.unique_cluster_name}" = "shared"
    "kubernetes.io/role/elb"                             = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.unique_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"                    = 1
  }
}
