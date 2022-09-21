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
    region     = "us-west-2"
    access_key = var.MANAGEMENT_AWS_ACCESS_KEY_ID
    secret_key = var.MANAGEMENT_AWS_ACCESS_SECRET_KEY
}

### use the terraform-svc account 
## export AWS_ACCESS_KEY_ID=""
## export AWS_SECRET_ACCESS_KEY=""
provider "aws" {
  alias  = "nonprod"
  assume_role {
    role_arn     = "arn:aws:iam::041618144804:role/OrganizationAccountAccessRole"
  }
}

data "aws_caller_identity" "current" {}


# resource "aws_organizations_organization" "org" {
#   aws_service_access_principals = [
#     "cloudtrail.amazonaws.com",
#     "config.amazonaws.com",
#   ]

#   feature_set = "ALL"
# }

resource "aws_organizations_account" "account" {
  name  = "rocks_nonprod"
  email = "rocks+202209213@glueops.dev" #${formatdate("YYYYMMDD", timestamp())}
  close_on_deletion = true
  role_name = module.organization_access_role.role_name
}

module "organization_access_role" {
  source            = "git::https://github.com/maxgio92/terraform-aws-organization-access-role.git?ref=feature/012-upgrade"
  master_account_id = data.aws_caller_identity.current.account_id
  role_name         = "OrganizationAccountAccessRole"
  policy_arn        = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

