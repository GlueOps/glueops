
## Steps to bring up the environment:

#### Notes:

Before you begin make sure your Taskfile.yaml has the proper environment variables set:

```
TF_VAR_COMPANY_KEY - this should be your name or another unique identifier that won't collide with another team member
TF_VAR_TEST_NUMBER - this should be incremented based on how many times you have run gke_up
```
Notes:
- All projects above will be under the glueops.rocks gcp organization. It's a pure dev org so don't expect to not lose any work.
- ALso sure you don't let your codespaces go idle. I recommend increasing your codespace timeout and running this all inside of tmux. Otherwise expect to monitor the gke_up for at least 15-25mins.

#### First authenticate TWICE. 

`task auth`
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




