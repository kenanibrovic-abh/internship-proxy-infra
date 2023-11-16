#!/bin/bash

set -ex

__check_is_installed(){
  declare package="${1:-}"

  "$package" version

  exit_code=$?

  if [[ $exit_code -ne 0 ]]; then
      echo "$package is not installed"
  fi
  return $exit_code
}

__check_is_installed helm

curl -sfL https://get.k3s.io | sh -s - --disable=traefik

sudo cat /etc/rancher/k3s/k3s.yaml | tee ~/.kube/k3s.yaml
chmod 600 ~/.kube/k3s.yaml

export KUBECONFIG="$HOME/.kube/k3s.yaml"

# Setup ArgoCD
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm upgrade argocd --install --namespace argocd --create-namespace --values deployment/argocd/values.yaml argo/argo-cd

# Add argo app of apps
helm upgrade app-of-apps --install --namespace argocd deployment/app-of-apps/

# Wait for ingress-nginx to be ready
while [[ -z $(kubectl get service -n ingress-nginx ingress-nginx-controller -o jsonpath="{.status.loadBalancer}" 2>/dev/null) ]]; do
  echo "waiting for ingress-nginx load balancer"
  sleep 10
done
echo "ingress-nginx is now available"
