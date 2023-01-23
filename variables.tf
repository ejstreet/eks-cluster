variable "region" {
  description = "AWS region"
  type        = string
}

variable "cluster_name" {
  description = "The name of the cluster. This will be given a random suffix."
  type        = string
}

variable "kubernetes_version" {
  type        = string
  description = "The version to deploy on the EKS cluster."
}

variable "ami_type" {
  description = "The AMI type of the node groups. See EKS Node Group documentation for valid types."
  type        = string
}

variable "eks_managed_node_groups" {
  description = "A list of EKS managed node groups."
  type = list(object({
    name = string

    instance_types = list(string)

    min_size     = number
    max_size     = number
    desired_size = number

    capacity_type = optional(string, "ON_DEMAND") # Alternatively "SPOT"
    labels        = optional(map(string), {})

  }))
}

# VPC Config
variable "create_vpc" {
  type        = bool
  default     = true
  description = "Set to false and use the existing_vpc_* variables to deploy to an existing VPC."
}

variable "existing_vpc_id" {
  type        = string
  default     = null
  description = "Pass the vpc_id of an existing VPC."
}

variable "existing_vpc_subnet_ids" {
  type        = list(string)
  default     = []
  description = "Pass the subnet ids where the cluster will be deployed to."
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "private_subnets" {
  type = list(string)
}

variable "public_subnets" {
  type    = list(string)
  default = []
}
