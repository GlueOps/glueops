
## Steps to bring up the environment:

#### Notes:

- All projects above will be under the glueops.rocks gcp organization. It's a pure dev org so don't expect to not lose any work.
- If you are using GitHub codespaces, We recommend adjusting your idle settings so that your codespace doesn't stop running while you wait for things to spin up. As of 2022-09, the terraform takes about 15-25minutes to finish running.

#### First authenticate TWICE. 

`task gcp_auth`
- Note: you do not need to create a project, you just need to auth and then you can cancel out or say no to creating a project.

#### Create all your configs.

- Copy `.env.tpl` to create an `.env` file with the correct secrets.
- Run `source .env` to populate your environment with the newly created variables and secrets
- Run `task configs`

#### Bring up new clusters in gke:

`task gke_up`

#### Bootstrap admiral cluster:

`task gke_bootstrap_argocd`

#### Bootstrap apps cluster:

`task gke_bootstrap_apps_cluster`

#### Get logins for argocd deployments:
`task get_argocd_logins`

#### Cleanup:
`task clean`




