
## Steps to bring up the environment:

#### Notes:

- All projects above will be under the glueops.rocks gcp organization. It's a pure dev org so don't expect to not lose any work.
- If you are using GitHub codespaces, We recommend adjusting your idle settings so that your codespace doesn't stop running while you wait for things to spin up. As of 2022-09, the terraform takes about 15-25minutes to finish running.


#### First authenticate TWICE. 

`task auth`
- Note: you do not need to create a project, you just need to auth and then you can cancel out or say no to creating a project.

#### Start creating your configs:

- Copy `.env.tpl` to create an `.env` file with the correct secrets.
- Run `source .env` to populate your environment with the newly created variables and secrets

#### Bring up new clusters in gke:

`task gke_up`


#### Update the .env file with the gcp-service-account keys:
- Run `echo $CREATION_DATE` and take the numeric value and update your `.env` so that `CREATION_DATE=` whatever the numeric value from the echo was.
- Take the value from `./gcp-service-account-keys/hashicorp-vault.jb64` and in the `.env` set the value of `VAULT_GOOGLE_CREDENTIALS`
- Take the value from `./gcp-service-account-keys/terraform-cloud-operator.jb64` and in the `.env` set the value of `TFC_GOOGLE_CREDENTIALS`
- Run `source.env` to populate your environment variables. Note: Your `CREATION_DATE` should be hardcoded to the value that was generated earlier to see what it was.
- Run `task configs` to generate all the configs for the next steps

#### Bootstrap admiral cluster:

`task gke_bootstrap_argocd`

#### Bootstrap apps cluster:

`task gke_bootstrap_apps_cluster`

#### Get logins for argocd deployments:
`task get_argocd_logins`

#### Cleanup:
`task clean`




