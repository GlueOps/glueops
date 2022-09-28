apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: $APPS_CLUSTER_NAME
spec:
  destination:
    name: $APPS_CLUSTER_NAME
    namespace: glueops-core
    server: ''
  source:
    path: .
    repoURL: 'https://github.com/GlueOps/platform.git'
    targetRevision: HEAD
    helm:
      parameters:
        - name: argo-cd.glueops.app_cluster_name
          value: $APPS_CLUSTER_NAME
        - name: certManager.cloudflare_api_token
          value: $CLOUDFLARE_API_TOKEN
        - name: externalDns.cloudflare_api_token
          value: $CLOUDFLARE_API_TOKEN
        - name: certManager.zerossl_eab_kid
          value: $ZEROSSL_EAB_KID
        - name: certManager.zerossl_eab_hmac_key
          value: >-
            $ZEROSSL_EAB_HMAC_KEY
        - name: gitHub.k8sBootstrapRepo
          value: aHR0cHM6Ly9naXRodWIuY29tL0dsdWVPcHMvcGxhdGZvcm0uZ2l0
      values: |-
        vault:
          hostname: vault.$CAPTAIN_DOMAIN
        grafana:
          root_url: "https://grafana.$CAPTAIN_DOMAIN"
          github_client_id: $GRAFANA_GITHUB_CLIENT_ID
          github_client_secret: $GRAFANA_GITHUB_CLIENT_SECRET
          hostname: grafana.$CAPTAIN_DOMAIN
          github_org_names: GlueOps $CUSTOMER_GITHUB_ORG_NAME
        argo-cd:
          server:
            service:
              annotations:
                external-dns.alpha.kubernetes.io/hostname: "argocd.$CAPTAIN_DOMAIN"
            ingress:
              hosts: ["argocd.$CAPTAIN_DOMAIN"]
              tls: 
                - 
                  hosts: 
                    - argocd.$CAPTAIN_DOMAIN
            config:
              url: "https://argocd.$CAPTAIN_DOMAIN"
              dex.config: |
                connectors:
                  # GitHub GlueOps
                  - type: github
                    id: github
                    name: GitHub
                    config:
                      clientID: $ARGO_CD_GITHUB_CLIENT_ID
                      clientSecret: $ARGO_CD_GITHUB_CLIENT_SECRET
                      orgs:
                      - name: GlueOps
                        teams:
                        - argocd_super_admins
                      - name: $CUSTOMER_GITHUB_ORG_NAME
                        teams:
                        - $CUSTOMER_GITHUB_ORG_TEAM_NAME
                      # Flag which indicates that all user groups and teams should be loaded.
                      loadAllGroups: false
            rbacConfig:
              policy.csv: |
                g, GlueOps:argocd_super_admins, role:admin
                g, demo-antoniostacos:developers, role:developers
                p, role:developers, clusters, get, *, allow
                p, role:developers, *, get, antonios-developers-project, allow
                p, role:developers, repositories, *, *, allow
                p, role:developers, applications, *, antonios-developers-project/*, allow
                p, role:developers, exec, *, antonios-developers-project/*, allow
  project: default
  syncPolicy:
    retry:
      limit: 2
      backoff:
        duration: 5s
        maxDuration: 3m0s
        factor: 2
    automated:
      prune: false
      selfHeal: true
    syncOptions:
      - CreateNamespace=true