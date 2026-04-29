#!/usr/bin/env bash
set -euo pipefail

kubectl apply -f deploy/rbac.yaml
kubectl apply -f deploy/configmap.yaml
kubectl apply -f deploy/deployment.yaml

kubectl rollout status deployment/balanced-scheduler -n kube-system --timeout=120s
kubectl get pods -n kube-system -l app=balanced-scheduler -o wide
