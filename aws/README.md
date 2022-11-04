
## Steps to bring up the environment:

#### Notes:

Before you begin make sure your Taskfile.yaml has the proper environment variables set:

Notes:
- Also, be sure you don't let your codespaces go idle. I recommend increasing your codespace timeout and running this all inside of tmux. Otherwise expect to monitor the gke_up for at least 15-25mins.

#### set your environment

- Copy `.env.tpl` to create an `.env` file with the correct secrets.
- Run `source .env` to populate your environment with the newly created variables and secrets

#### Bring up new clusters in eks:

`task eks_up`

#### create configs

`task configs`


#### Bootstrap admiral cluster:

`task eks_bootstrap_argocd`

#### Bootstrap captain cluster:

`task eks_bootstrap_apps_cluster`

#### Get logins for argocd deployments:
`task get_argocd_logins`

#### Cleanup:
`task clean`




