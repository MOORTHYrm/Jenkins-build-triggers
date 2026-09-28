#!/bin/bash
echo "Build started at $(date)"
echo "KUBECONFIG path: $KUBECONFIG"
if command -v kubectl >/dev/null 2>&1; then
  echo "Current context: $(kubectl config current-context)"
  kubectl get nodes
  kubectl get namespaces
else
  echo "kubectl not installed, skipping cluster check"
  exit 1
fi
