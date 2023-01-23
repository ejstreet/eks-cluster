# EKS Cluster from scratch

This module deploys a complete publicly accessible EKS cluster in an empty AWS account. All that is required is to have an AWS account and user created, `awscli` configured, and `kubectl` installed.

By leveraging existing [EKS](https://github.com/terraform-aws-modules/terraform-aws-eks) and [VPC](https://github.com/terraform-aws-modules/terraform-aws-vpc) modules from the terraform modules registry, this module itself is kept relatively simple.

## Deploying this module


Use the following `terraform.auto.tfvars` to deploy a VPC, EIP, NAT gateway, routes, public/private subnets, security groups, NAT gateway, IAM roles & policies, EKS backplane, and two worker groups (one using on-demand instances, the other on spot instances).

> NOTE: If you wish to deploy to an existing VPC, the VPC module can be disabled by adding `create_vpc = false` in the `.tfvars` and then existing VPC referenced using the `existing_vpc_*` variables. Note that all resources that would have been created by the VPC module must be present.

```hcl
# terraform.auto.tfvars

region = "us-east-1"

cluster_name       = "demo"
kubernetes_version = "1.24"
ami_type           = "BOTTLEROCKET_x86_64"

vpc_cidr        = "10.0.0.0/16"
private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

eks_managed_node_groups = [
  {
    name           = "demo-on-demand"
    instance_types = ["t3.small"]

    min_size     = 1
    max_size     = 1
    desired_size = 1
  },
  {
    name           = "demo-spot"
    instance_types = ["t3.small"]

    capacity_type = "SPOT"

    min_size     = 1
    max_size     = 1
    desired_size = 1
  },
]

```
Once the file has been added, run `terraform plan` to see what will be deployed. Then run `terraform apply -auto-approve` to deploy the infrastructure. This will take around 10-15 minutes.

## Configuring `kubectl`
After the apply is complete, run the following to configure the Kubernetes client:
```bash
aws eks update-kubeconfig --name $(terraform output -raw cluster_name)
```
The nodes and pods can then be checked by running the following:
```bash
kubectl get nodes
kubectl get pod -A
```

Finally, run `terraform destroy -auto-approve` when you are ready to destroy all the created resources.