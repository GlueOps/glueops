terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

variable "COMPANY_KEY" {}


data "aws_organizations_organization" "org" {}

output "org_data" {
  value = data.aws_organizations_organization.org.non_master_accounts
}

locals {
  admiral_id = "${var.COMPANY_KEY}-admiral"
  captain_id = "${var.COMPANY_KEY}-captain"

  admiral_account_id = [
    for d in data.aws_organizations_organization.org.non_master_accounts :
    d.id if d.name == local.admiral_id
  ][0]

  captain_account_id = [
    for d in data.aws_organizations_organization.org.non_master_accounts :
    d.id if d.name == local.captain_id
  ][0]

  eks_cluster = {
    cluster_version = "1.22"
    region          = "us-west-2"
  }

  vpc = {
    cidr_block = "10.65.0.0/16"
  }

  eks_node_group = {
    instance_types = ["t3a.medium"]
    desired_size   = 3
    min_size       = 3
    max_size       = 4
  }
}


provider "aws" {
  alias = "admiral"
  assume_role {
    role_arn = "arn:aws:iam::${local.admiral_account_id}:role/OrganizationAccountAccessRole"
  }
}

provider "aws" {
  alias = "captain"
  assume_role {
    role_arn = "arn:aws:iam::${lcoal.captain_account_id}:role/OrganizationAccountAccessRole"
  }
}

# #=== CloudPosse EKS


module "label" {
  source = "cloudposse/label/null"
  # Cloud Posse recommends pinning every module to a specific version
  # version  = "x.x.x"

  # TODO - figure out what these variables do
  namespace  = "test-nonprod"
  name       = "test-name"
  stage      = "test-stage"
  delimiter  = "-"
  attributes = ["cluster"]
  tags       = { "tag" : "test-tag" }
}

locals {
  # Prior to Kubernetes 1.19, the usage of the specific kubernetes.io/cluster/* resource tags below are required
  # for EKS and Kubernetes to discover and manage networking resources
  # https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html#base-vpc-networking
  # TODO = still needed?
  tags = { "kubernetes.io/cluster/${module.label.id}" = "shared" }
}


module "vpc_admiral" {
  providers = {
    aws = aws.admiral
  }
  source = "cloudposse/vpc/aws"
  # Cloud Posse recommends pinning every module to a specific version
  # version     = "x.x.x"
  cidr_block = local.vpc.cidr_block

  tags    = local.tags
  context = module.label.context
}

module "vpc_captain" {
  providers = {
    aws = aws.captain
  }
  source = "cloudposse/vpc/aws"
  # Cloud Posse recommends pinning every module to a specific version
  # version     = "x.x.x"
  cidr_block = local.vpc.cidr_block

  tags    = local.tags
  context = module.label.context
}

module "subnets_admiral" {
  providers = {
    aws = aws.admiral
  }
  source = "cloudposse/dynamic-subnets/aws"
  # Cloud Posse recommends pinning every module to a specific version
  # version     = "x.x.x"

  vpc_id               = module.vpc_admiral.vpc_id
  igw_id               = [module.vpc_admiral.igw_id]
  nat_gateway_enabled  = true
  nat_instance_enabled = false

  tags               = local.tags
  context            = module.label.context
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

module "subnets_captain" {
  providers = {
    aws = aws.captain
  }
  source = "cloudposse/dynamic-subnets/aws"
  # Cloud Posse recommends pinning every module to a specific version
  # version     = "x.x.x"

  vpc_id               = module.vpc_captain.vpc_id
  igw_id               = [module.vpc_captain.igw_id]
  nat_gateway_enabled  = true
  nat_instance_enabled = false

  tags               = local.tags
  context            = module.label.context
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
}


module "eks_node_group_admiral" {
  providers = {
    aws = aws.admiral
  }
  source = "cloudposse/eks-node-group/aws"
  # Cloud Posse recommends pinning every module to a specific version
  # version     = "x.x.x"

  instance_types = local.eks_node_group.instance_types
  subnet_ids     = module.subnets_admiral.public_subnet_ids
  #health_check_type                  = var.health_check_type
  desired_size = local.eks_node_group.desired_size
  min_size     = local.eks_node_group.min_size
  max_size     = local.eks_node_group.max_size
  cluster_name = module.eks_cluster_admiral.eks_cluster_id

  # Enable the Kubernetes cluster auto-scaler to find the auto-scaling group
  cluster_autoscaler_enabled = true

  context = module.label.context

  # Ensure the cluster is fully created before trying to add the node group
  module_depends_on = module.eks_cluster_admiral.kubernetes_config_map_id
}


module "eks_node_group_captain" {
  providers = {
    aws = aws.captain
  }
  source = "cloudposse/eks-node-group/aws"
  # Cloud Posse recommends pinning every module to a specific version
  # version     = "x.x.x"

  instance_types = local.eks_node_group.instance_types
  subnet_ids     = module.subnets_captain.public_subnet_ids
  #health_check_type                  = var.health_check_type
  desired_size = local.eks_node_group.desired_size
  min_size     = local.eks_node_group.min_size
  max_size     = local.eks_node_group.max_size
  cluster_name = module.eks_cluster_captain.eks_cluster_id

  # Enable the Kubernetes cluster auto-scaler to find the auto-scaling group
  cluster_autoscaler_enabled = true

  context = module.label.context

  # Ensure the cluster is fully created before trying to add the node group
  module_depends_on = module.eks_cluster_captain.kubernetes_config_map_id
}


module "eks_cluster_admiral" {
  providers = {
    aws = aws.admiral
  }
  source = "cloudposse/eks-cluster/aws"
  # Cloud Posse recommends pinning every module to a specific version
  # version = "x.x.x"
  region     = local.eks_cluster.region
  vpc_id     = module.vpc_admiral.vpc_id
  subnet_ids = module.subnets_admiral.public_subnet_ids

  oidc_provider_enabled = true

  context            = module.label.context
  kubernetes_version = local.eks_cluster.cluster_version
}



module "eks_cluster_captain" {
  providers = {
    aws = aws.captain
  }
  source = "cloudposse/eks-cluster/aws"
  # Cloud Posse recommends pinning every module to a specific version
  # version = "x.x.x"
  region     = local.eks_cluster.region
  vpc_id     = module.vpc_captain.vpc_id
  subnet_ids = module.subnets_captain.public_subnet_ids

  oidc_provider_enabled = true

  context            = module.label.context
  kubernetes_version = local.eks_cluster.cluster_version
}
