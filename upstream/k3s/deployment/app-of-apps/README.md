## Argo App of Apps

Helm chart for Argo App of Apps. Using app of apps pattern, we can create a single app which will manage all other apps (ingress-nginx, cert-manager etc).

Templates directory contains all Argo CRD application definitions including the `app-of-apps` itself. `app-of-apps` will automatically create and sync all application definitions in this directory.

By default, Argo can't read application definitions in other namespaces so they should be placed in the same namespace as ArgoCD (`argocd`). App of apps needs to be deployed only once using helm:

```bash
helm upgrade --install --namespace argocd app-of-apps .
```

