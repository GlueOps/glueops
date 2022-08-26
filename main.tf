variable "GCP_ORGANIZATION_ID" {}
variable "COMPANY_KEY" {}
variable "TEST_NUMBER" {}


locals {
  org_id                   = var.GCP_ORGANIZATION_ID
  company_key              = var.COMPANY_KEY
  gcp_billing_account_name = "My Billing Account"
  environments             = toset(["orchestrator-${var.TEST_NUMBER}", "apps-${var.TEST_NUMBER}"])

  admins = [
    "user:venkata@venkatamutyala.com",
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
  ]


  gcp_folder_id = split("/", module.organization_and_project_bootstrap.gcp_folder_id)[1]
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

  depends_on = [
    module.vpc
  ]
}

