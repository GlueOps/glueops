
## Steps to bring up the environment:

#### Notes:

- All projects above will be under the glueops.rocks gcp organization. It's a pure dev org so don't expect to not lose any work.
- If you are using GitHub codespaces, We recommend adjusting your idle settings so that your codespace doesn't stop running while you wait for things to spin up. As of 2022-09, the terraform takes about 15-25minutes to finish running.

#### First authenticate TWICE. 

`task gcp_auth`
- Note: you do not need to create a project, you just need to auth and then you can cancel out or say no to creating a project.

#### Start creating your configs:

- Copy `.env.tpl` to create an `.env` file with the correct secrets.
- Run `source .env` to populate your environment with the newly created variables and secrets

#### Bring up new clusters in gke:

`task gke_up`


- Run `task configs` to generate all the configs for the next steps

#### Bootstrap admiral cluster:

`task gke_bootstrap_argocd`

#### Bootstrap apps cluster:

`task gke_bootstrap_apps_cluster`

#### Get logins for argocd deployments:
`task get_argocd_logins`


#### Login to App Cluster using GlueOps SSO:

Create a new app to initialize Vault:

```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: vault-init
  namespace: glueops-core
spec:
  destination:
    namespace: glueops-core-vault-init
    server: https://kubernetes.default.svc
  project: glueops-core
  source:
    chart: vault-init
    helm:
      parameters:
      - name: TFC_ORG_NAME
        value: yolo3-190345-apps
      - name: VAULT_ADDR
        value: https://vault.gcp.yolo1.glueops.rocks
    repoURL: https://glueops.github.io/helm-charts
    targetRevision: 0.1.0
  syncPolicy:
    automated: {}
    syncOptions:
    - CreateNamespace=true

```

Note: Update the TFC_ORG_NAME and update VAULT_ADDR

*Once You deploy the app go to TFC and check to see it successfully applied in the TFC Org. Grab the VAULT_ADDR and VAULT_TOKEN and create a global variable set for all workspaces in TFC.*

global variable set name: tfc_core:

| key | value | category | sensitive |
|---|---| ---| ---|
| VAULT_ADDR | ex. "https://vault.gcp.yolo1.glueops.rocks" | Environment Variable | no |
| VAULT_TOKEN | ex. "hvs.XXXXXXXXXX" | Environment Variable | yes |


#### Configure vault:

Create a new app in argocd:

```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: vault-configuration
  namespace: glueops-core
spec:
  destination:
    namespace: glueops-core-vault-configuration
    server: https://kubernetes.default.svc
  project: glueops-core
  source:
    chart: vault-configuration
    helm:
      parameters:
      - name: TFC_ORG_NAME
        value: yolo3-190345-apps
      - name: TOGGLE_TO_RERUN
        value: "1"
      - name: GLUEOPS_ENV
        value: yolo3-190345-apps
    repoURL: https://glueops.github.io/helm-charts
    targetRevision: 0.5.0
  syncPolicy:
    syncOptions:
    - CreateNamespace=true
```

Note: Update the TFC_ORG_NAME and GLUEOPS_ENV, at this time they should be the same.


#### Cleanup:
`task clean`




