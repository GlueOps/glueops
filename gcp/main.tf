variable "GCP_ORGANIZATION_ID" {}
variable "COMPANY_KEY" {}
variable "CAPTAIN_CLUSTER_NAME" {}
variable "UNIQUE_IDENTIFIER" {}
variable "ENVIRONMENT_SPECIFIC_EMAIL_GROUP" {}



locals {
  org_id                   = var.GCP_ORGANIZATION_ID
  company_key              = var.COMPANY_KEY
  gcp_billing_account_name = "My Billing Account"
  environments             = toset(["${var.UNIQUE_IDENTIFIER}-admiral", "${var.UNIQUE_IDENTIFIER}-captain"])

  apps_project_name = var.CAPTAIN_CLUSTER_NAME

  admins = [
    "group:${var.ENVIRONMENT_SPECIFIC_EMAIL_GROUP}",
  ]

  # ref: https://cloud.google.com/iam/docs/understanding-roles
  admin_roles = [
    "roles/owner",
    "roles/resourcemanager.folderAdmin",
    "roles/iam.serviceAccountUser",
    "roles/logging.admin",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/orgpolicy.policyAdmin",
    "roles/servicemanagement.quotaAdmin",
    "roles/resourcemanager.projectCreator", #added
    "roles/billing.admin",                  #added
  ]


  gcp_folder_id = split("/", module.organization_and_project_bootstrap.gcp_folder_id)[1]
}

variable "VAULT_ADDR" {}
module "tfc" {
  source = "github.com/GlueOps/terraform-tfc-captain-team-api-token.git"
  org_name = var.CAPTAIN_CLUSTER_NAME
  email = var.ENVIRONMENT_SPECIFIC_EMAIL_GROUP
  VAULT_ADDR = var.VAULT_ADDR
}



module "organization_and_project_bootstrap" {
  source                   = "github.com/GlueOps/terraform-gcp-organization-bootstrap.git?ref=disable-kms-protection"
  org_id                   = local.org_id
  company_key              = local.company_key
  admins                   = local.admins
  admin_roles              = local.admin_roles
  gcp_billing_account_name = local.gcp_billing_account_name
  environments             = local.environments
}



locals {
  network_prefixes = {
    kubernetes_pods          = "10.65.0.0/16"
    gcp_private_connect      = "10.64.128.0/19"
    kubernetes_services      = "10.64.224.0/20"
    private_primary          = "10.64.0.0/23"
    public_primary           = "10.64.64.0/23"
    serverless_vpc_connector = "10.64.96.0/28"
    kubernetes_master_nodes  = "10.64.96.16/28"
  }
}

module "vpc" {
  source    = "git::https://github.com/GlueOps/terraform-gcp-vpc-module.git"
  for_each  = local.environments
  workspace = each.key
  region    = "us-central1"

  network_prefixes                   = local.network_prefixes
  gcp_folder_id                      = local.gcp_folder_id
  enable_google_vpc_access_connector = false
  depends_on = [
    module.organization_and_project_bootstrap
  ]
}


module "gke" {
  source                     = "git::https://github.com/GlueOps/terraform-gcp-gke-module.git"
  for_each                   = local.environments
  workspace                  = each.key
  region                     = "us-central1"
  gcp_folder_id              = local.gcp_folder_id
  run_masters_in_single_zone = true
  spot_instances             = true
  kubernetes_version_prefix  = "1.22.15-gke.100"

  depends_on = [
    module.vpc
  ]
}


module "svc_accounts" {
  source = "git::https://github.com/GlueOps/terraform-gcp-captain-service-accounts.git"
  svc_accounts_and_roles = {
    terraform-cloud-operator = toset(["roles/cloudsql.admin"])
    hashicorp-vault          = toset(["roles/cloudkms.cryptoKeyEncrypterDecrypter","roles/cloudkms.viewer"])
  }
  gcp_project_name = local.apps_project_name
}