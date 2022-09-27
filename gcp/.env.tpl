# Note you should only source this .env file once as the CREATION_DATE will change! Alternatively, you can hardcode it.

export TF_VAR_ENVIRONMENT_SPECIFIC_EMAIL_GROUP="<ask-org-admins-for-an-email-group>"


export COMPANY_KEY="<developer-name>"
export CREATION_DATE=`date '+%d%H%M'`
export APPS_CLUSTER_NAME=$COMPANY_KEY-$CREATION_DATE-apps


#Note you need to add this as an edge SSL cert to cloudflare
#Example: "*.us-central1.gcp.example.glueops.rocks"
export CAPTAIN_DOMAIN="us-central1.gcp."$COMPANY_KEY".glueops.rocks"

#https://dash.cloudflare.com/profile/api-tokens
export CLOUDFLARE_API_TOKEN="<replace-with-your-token>"

#https://app.zerossl.com/developer
export ZEROSSL_EAB_KID="<replace-with-your-kid>"
export ZEROSSL_EAB_HMAC_KEY="<replace-with-your-hmac-key>"

#https://github.com/organizations/GlueOps/settings/applications/
#Create two oauth apps in your own github organization. 
## Do not:
### use the GlueOps account as we use this for GitHub actions and/or automated testing.
### use a personal account. It must be a github organization.

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