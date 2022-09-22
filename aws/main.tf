terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

### Use your OWN aws account credentials here!
## export TF_VAR_MANAGEMENT_AWS_ACCESS_KEY_ID=""
## export TF_VAR_MANAGEMENT_AWS_ACCESS_SECRET_KEY=""
variable "MANAGEMENT_AWS_ACCESS_KEY_ID" {}
variable "MANAGEMENT_AWS_ACCESS_SECRET_KEY" {}

provider "aws" {
    alias = "management_account"
    region     = "us-west-2"
    access_key = var.MANAGEMENT_AWS_ACCESS_KEY_ID
    secret_key = var.MANAGEMENT_AWS_ACCESS_SECRET_KEY
}

### use the terraform-svc account 
## export AWS_ACCESS_KEY_ID=""
## export AWS_SECRET_ACCESS_KEY=""
provider "aws" {
  assume_role {
    role_arn     = "arn:aws:iam::041618144804:role/OrganizationAccountAccessRole"
  }
}

data "aws_caller_identity" "current" {
  provider = aws.management_account
}


# resource "aws_organizations_organization" "org" {
#   aws_service_access_principals = [
#     "cloudtrail.amazonaws.com",
#     "config.amazonaws.com",
#   ]

#   feature_set = "ALL"
# }

resource "aws_organizations_account" "account" {
  provider = aws.management_account
  name  = "rocks_nonprod"
  email = "rocks+202209213@glueops.dev" #${formatdate("YYYYMMDD", timestamp())}
  close_on_deletion = true
  role_name = module.organization_access_role.role_name
}

module "organization_access_role" {
  source            = "git::https://github.com/glueops/terraform-aws-organization-access-role.git?ref=master"
  providers = {
    aws = aws.management_account
  }
  master_account_id = data.aws_caller_identity.current.account_id
  role_name         = "OrganizationAccountAccessRole"
  policy_arn        = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

#=== CloudPosse EKS


  module "label" {
    source = "cloudposse/label/null"
    # Cloud Posse recommends pinning every module to a specific version
    # version  = "x.x.x"

    namespace  = "test-nonprod"
    name       = "test-name"
    stage      = "test-stage"
    delimiter  = "-"
    attributes = ["cluster"]
    tags       = {"tag": "test-tag"}
  }

  locals {
    # Prior to Kubernetes 1.19, the usage of the specific kubernetes.io/cluster/* resource tags below are required
    # for EKS and Kubernetes to discover and manage networking resources
    # https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html#base-vpc-networking
    tags = { "kubernetes.io/cluster/${module.label.id}" = "shared" }
  }

  module "vpc" {
    source = "cloudposse/vpc/aws"
    # Cloud Posse recommends pinning every module to a specific version
    # version     = "x.x.x"
    cidr_block = "10.65.0.0/16"

    tags    = local.tags
    context = module.label.context
  }

  module "subnets" {
    source = "cloudposse/dynamic-subnets/aws"
    # Cloud Posse recommends pinning every module to a specific version
    # version     = "x.x.x"

    vpc_id               = module.vpc.vpc_id
    igw_id               = [module.vpc.igw_id]
    nat_gateway_enabled  = true
    nat_instance_enabled = false

    tags    = local.tags
    context = module.label.context
    availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  }

  module "eks_node_group" {
    source = "cloudposse/eks-node-group/aws"
    # Cloud Posse recommends pinning every module to a specific version
    # version     = "x.x.x"

    instance_types                     = ["t3a.xlarge"]
    subnet_ids                         = module.subnets.public_subnet_ids
    #health_check_type                  = var.health_check_type
    desired_size                       = 3
    min_size                           = 3
    max_size                           = 4
    cluster_name                       = module.eks_cluster.eks_cluster_id

    # Enable the Kubernetes cluster auto-scaler to find the auto-scaling group
    cluster_autoscaler_enabled = true

    context = module.label.context

    # Ensure the cluster is fully created before trying to add the node group
    module_depends_on = module.eks_cluster.kubernetes_config_map_id
  }

  module "eks_cluster" {
    source = "cloudposse/eks-cluster/aws"
    # Cloud Posse recommends pinning every module to a specific version
    # version = "x.x.x"
    region = "us-west-2"
    vpc_id     = module.vpc.vpc_id
    subnet_ids = module.subnets.public_subnet_ids

    oidc_provider_enabled = true

    context = module.label.context
    kubernetes_version = "1.22"
  }