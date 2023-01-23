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

# Module details

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.50 |
| <a name="requirement_cloudinit"></a> [cloudinit](#requirement\_cloudinit) | ~> 2.2 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.16 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.4 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.51.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.4.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | 19.5.1 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 3.19.0 |

## Resources

| Name | Type |
|------|------|
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_type"></a> [ami\_type](#input\_ami\_type) | The AMI type of the node groups. See EKS Node Group documentation for valid types. | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the cluster. This will be given a random suffix. | `string` | n/a | yes |
| <a name="input_create_vpc"></a> [create\_vpc](#input\_create\_vpc) | Set to false and use the existing\_vpc\_* variables to deploy to an existing VPC. | `bool` | `true` | no |
| <a name="input_eks_managed_node_groups"></a> [eks\_managed\_node\_groups](#input\_eks\_managed\_node\_groups) | A list of EKS managed node groups. | <pre>list(object({<br>    name = string<br><br>    instance_types = list(string)<br><br>    min_size     = number<br>    max_size     = number<br>    desired_size = number<br><br>    capacity_type = optional(string, "ON_DEMAND") # Alternatively "SPOT"<br>    labels        = optional(map(string), {})<br><br>  }))</pre> | n/a | yes |
| <a name="input_existing_vpc_id"></a> [existing\_vpc\_id](#input\_existing\_vpc\_id) | Pass the vpc\_id of an existing VPC. | `string` | `null` | no |
| <a name="input_existing_vpc_subnet_ids"></a> [existing\_vpc\_subnet\_ids](#input\_existing\_vpc\_subnet\_ids) | Pass the subnet ids where the cluster will be deployed to. | `list(string)` | `[]` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | The version to deploy on the EKS cluster. | `string` | n/a | yes |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | n/a | `list(string)` | n/a | yes |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | n/a | `list(string)` | `[]` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | n/a | `string` | `"10.0.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Endpoint for EKS control plane |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Kubernetes Cluster Name |
| <a name="output_cluster_security_group_id"></a> [cluster\_security\_group\_id](#output\_cluster\_security\_group\_id) | Security group ids attached to the cluster control plane |
| <a name="output_region"></a> [region](#output\_region) | AWS region |
