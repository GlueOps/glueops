#### ONLY FOR AWS:
# AWS Credentials (from the Terraform Service User)
export AWS_ACCESS_KEY_ID="<tf-service-user-credentials>"
export AWS_SECRET_ACCESS_KEY="<tf-service-user-credentials>"
export AWS_REGION="<tf-service-user-region>"

#### END AWS


#Slack incoming webhook:
export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/XXXXXXXXX/XXXXXXXXX/XXXXXXXXXXXXXXXXXXXXXXXX"


# Please check the team wiki page for some of these values.
export TF_VAR_ENVIRONMENT_SPECIFIC_EMAIL_GROUP="<ask-org-admins-for-an-email-group>"
export CUSTOMER_GITHUB_ORG_NAME="<customer-github-org-name>"
export CUSTOMER_GITHUB_ORG_TEAM_NAME="<customer-github-org-team-name>"
export UNIQUE_IDENTIFIER=$(date '+%d%H%M')
export COMPANY_KEY="<developer-name>"


#Note you need to add this as an edge SSL cert to cloudflare
#Example: "us-central1.gcp.example.glueops.rocks"
export CAPTAIN_DOMAIN="<set-domain-suffix-here>"

# https://dash.cloudflare.com/profile/api-tokens
# Ensure your tokens are RESTRICTED to EDIT/READ on the $CAPTAIN_DOMAIN above.
# DO NOT use a cloudflare token that gives you full access to everything in your account.
export CLOUDFLARE_API_TOKEN="<replace-with-your-token>"

# https://app.zerossl.com/developer
export ZEROSSL_EAB_KID="<replace-with-your-kid>"
export ZEROSSL_EAB_HMAC_KEY="<replace-with-your-hmac-key>"

# https://github.com/organizations/GlueOps/settings/applications/
# Create two oauth apps in your own github organization.
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



