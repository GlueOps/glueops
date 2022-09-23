terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# # Everything commented below was pretty much a one-time setup.
# variable "MANAGEMENT_AWS_ACCESS_KEY_ID" {}
# variable "MANAGEMENT_AWS_SECRET_ACCESS_KEY" {}
# provider "aws" {
#     alias = "management_account"
#     region     = "us-west-2"
#     access_key = var.MANAGEMENT_AWS_ACCESS_KEY_ID
#     secret_key = var.MANAGEMENT_AWS_SECRET_ACCESS_KEY
# }
# data "aws_caller_identity" "current" {
#   provider = aws.management_account
# }


# ## Commented out to prevent redeployment of the organization, and it can't be destroyed due to SUSPENDED accounts.
# ## This only needs to be done one time since it converts the aws account into a organization management account
# resource "aws_organizations_organization" "org" {
#   aws_service_access_principals = [
#     "cloudtrail.amazonaws.com",
#     "config.amazonaws.com",
#   ]

#   feature_set = "ALL"
# }

# ## This role gets created in the root/management organization account and should be used for all sub accounts that get created. 
# ## This role has already been created so you shouldn't need to ever create this rsource again.
# module "organization_access_role" {
#   source            = "git::https://github.com/glueops/terraform-aws-organization-access-role.git?ref=master"
#   providers = {
#     aws = aws.management_account
#   }
#   master_account_id = data.aws_caller_identity.current.account_id
#   role_name         = "OrganizationAccountAccessRole"
#   policy_arn        = "arn:aws:iam::aws:policy/ReadOnlyAccess"
# }


# # Given the limits of account creation in AWS we are just creating an admiral/captain account and plan to use a third party OSS solution to nuke what's in the accounts whenever we want to reset them.
# resource "aws_organizations_account" "account_admiral" {
#   provider = aws.management_account
#   name  = "fernando_admiral"
#   email = "rodriguez.fernandoa+aws-admiral@gmail.com" #${formatdate("YYYYMMDD", timestamp())}
#   close_on_deletion = true
#   role_name = "OrganizationAccountAccessRole"
# }

# resource "aws_organizations_account" "account_captain" {
#   provider = aws.management_account
#   name  = "fernando_captain"
#   email = "rodriguez.fernandoa+aws-captain@gmail.com" #${formatdate("YYYYMMDD", timestamp())}
#   close_on_deletion = true
#   role_name = "OrganizationAccountAccessRole"
# }







# locals {
#   admiral_arn = "arn:aws:iam::394776142380:role/OrganizationAccountAccessRole"
#   captain_arn = "arn:aws:iam::816624901837:role/OrganizationAccountAccessRole"
# }

provider "aws" {
  alias = "admiral"
  assume_role {
    role_arn     = "arn:aws:iam::539362929792:role/OrganizationAccountAccessRole"
  }
}

provider "aws" {
  alias = "captain"
  assume_role {
    role_arn     = "arn:aws:iam::723876146658:role/OrganizationAccountAccessRole"
  }
}

#read ak sak st < <(echo $(aws sts assume-role --role-arn "arn:aws:iam::723876146658:role/OrganizationAccountAccessRole" --role-session-name k8s-test | jq -r '.Credentials | "\(.AccessKeyId) \(.SecretAccessKey) \(.SessionToken)"')) && export AWS_ACCESS_KEY_ID=$ak AWS_SECRET_ACCESS_KEY=$sak AWS_SESSION_TOKEN=$st


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


locals {
  vpc = {
    cidr_block = "10.65.0.0/16"
  }
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

    tags    = local.tags
    context = module.label.context
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

      tags    = local.tags
      context = module.label.context
      availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  }
  


  locals {
    eks_node_group = {
      instance_types = ["t3a.medium"]
    }
  }

  module "eks_node_group_admiral" {
    providers = {
      aws = aws.admiral
    }
    source = "cloudposse/eks-node-group/aws"
    # Cloud Posse recommends pinning every module to a specific version
    # version     = "x.x.x"

    instance_types                     = local.eks_node_group.instance_types
    subnet_ids                         = module.subnets_admiral.public_subnet_ids
    #health_check_type                  = var.health_check_type
    desired_size                       = 3
    min_size                           = 3
    max_size                           = 4
    cluster_name                       = module.eks_cluster_admiral.eks_cluster_id

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

    instance_types                     = local.eks_node_group.instance_types
    subnet_ids                         = module.subnets_captain.public_subnet_ids
    #health_check_type                  = var.health_check_type
    desired_size                       = 3
    min_size                           = 3
    max_size                           = 4
    cluster_name                       = module.eks_cluster_captain.eks_cluster_id

    # Enable the Kubernetes cluster auto-scaler to find the auto-scaling group
    cluster_autoscaler_enabled = true

    context = module.label.context

    # Ensure the cluster is fully created before trying to add the node group
    module_depends_on = module.eks_cluster_captain.kubernetes_config_map_id
  }


  locals {
    eks_cluster = {
      cluster_version = "1.22"
      region = "us-west-2"
    }
  }

  module "eks_cluster_admiral" {
    providers = {
      aws = aws.admiral
    }
    source = "cloudposse/eks-cluster/aws"
    # Cloud Posse recommends pinning every module to a specific version
    # version = "x.x.x"
    region = local.eks_cluster.region
    vpc_id     = module.vpc_admiral.vpc_id
    subnet_ids = module.subnets_admiral.public_subnet_ids

    oidc_provider_enabled = true

    context = module.label.context
    kubernetes_version = local.eks_cluster.cluster_version
  }



  module "eks_cluster_captain" {
    providers = {
      aws = aws.captain
    }
    source = "cloudposse/eks-cluster/aws"
    # Cloud Posse recommends pinning every module to a specific version
    # version = "x.x.x"
    region = local.eks_cluster.region
    vpc_id     = module.vpc_captain.vpc_id
    subnet_ids = module.subnets_captain.public_subnet_ids

    oidc_provider_enabled = true

    context = module.label.context
    kubernetes_version = local.eks_cluster.cluster_version
  }
