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