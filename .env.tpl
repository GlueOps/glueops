# Note you should only source this .env file once as the CREATION_DATE will change! Alternatively, you can hardcode it.

export COMPANY_KEY="<developer-name>"
export CREATION_DATE=`date '+%d%H%M'`
export APPS_CLUSTER_NAME=$COMPANY_KEY-$CREATION_DATE-apps

#https://dash.cloudflare.com/profile/api-tokens
export CLOUDFLARE_API_TOKEN="<replace-with-your-token>"

#https://app.zerossl.com/developer
export ZEROSSL_EAB_KID="<replace-with-your-kid>"
export ZEROSSL_EAB_HMAC_KEY="<replace-with-your-hmac-key>"

#https://github.com/organizations/GlueOps/settings/applications/
export GITHUB_CLIENT_ID="<replace-with-your-client-id>"
export GITHUB_CLIENT_SECRET="<replace-with-your-client-secret>"