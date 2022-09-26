# Note you should only source this .env file once as the CREATION_DATE will change! Alternatively, you can hardcode it.

# AWS Credentials (from the Terraform Service User)
export AWS_ACCESS_KEY_ID="<tf-service-user-credentials>"
export AWS_SECRET_ACCESS_KEY="<tf-service-user-credentials>"
export AWS_REGION="<tf-service-user-region>"

# environment Ids
export COMPANY_KEY="<developer-name>"
export CREATION_DATE=`date '+%d%H%M'`
export APPS_CLUSTER_NAME=$COMPANY_KEY-$CREATION_DATE-apps

#https://dash.cloudflare.com/profile/api-tokens
export CLOUDFLARE_API_TOKEN="<replace-with-your-token>"

#https://app.zerossl.com/developer
export ZEROSSL_EAB_KID="<replace-with-your-kid>"
export ZEROSSL_EAB_HMAC_KEY="<replace-with-your-hmac-key>"

#https://github.com/organizations/GlueOps/settings/applications/
#Create two oauth apps.

# App 1 is ArgoCD:
# Application Name: ArgoCD
# Homepage URL: https://argocd.gcp.glueops.rocks
# Authorization callback URL: https://argocd.gcp.glueops.rocks/api/dex/callback

export ARGO_CD_GITHUB_CLIENT_ID="<replace-with-your-client-id>"
export ARGO_CD_GITHUB_CLIENT_SECRET="<replace-with-your-client-secret>"

# App 2 is grafana:
# Application Name: grafana
# Homepage URL: https://grafana.gcp.glueops.rocks/login
# Authorization callback URL: https://argocd.gcp.glueops.rocks/login/github

export GRAFANA_GITHUB_CLIENT_ID="<replace-with-your-client-id>"
export GRAFANA_GITHUB_CLIENT_SECRET="<replace-with-your-client-secret>"



### AWS
### Use your OWN aws account credentials here!
export TF_VAR_MANAGEMENT_AWS_ACCESS_KEY_ID=""
export TF_VAR_MANAGEMENT_AWS_SECRET_ACCESS_KEY=""

### use the terraform-svc account 
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
