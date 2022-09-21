terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

data "aws_iam_account_alias" "current" {}

output "account_alias" {
  value = data.aws_iam_account_alias.current.id
}


# resource "aws_organizations_account" "account" {
#   name  = "rocks_nonprod"
#   email = "rocks@glueops.dev"
#   close_on_deletion = true
#   role_name = module.organization_access_role.role_name
# }

# module "organization_access_role" {
#   source            = "git::https://github.com/cloudposse/terraform-aws-organization-access-role.git?ref=master"
#   master_account_id = "XXXXXXXXXXXX"
#   role_name         = "OrganizationAccountAccessRole"
#   policy_arn        = "arn:aws:iam::aws:policy/AdministratorAccess"
# }