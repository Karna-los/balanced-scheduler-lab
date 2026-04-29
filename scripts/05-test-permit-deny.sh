#!/usr/bin/env bash
set -euo pipefail

kubectl delete pod permit-deny-pod --ignore-not-found

kubectl apply -f workloads/permit-deny-pod.yaml
sleep 5

echo "===== pod ====="
kubectl get pod permit-deny-pod -o wide || true

echo "===== events ====="
kubectl describe pod permit-deny-pod | sed -n '/Events:/,$p' || true

echo "===== scheduler logs ====="
kubectl logs -n kube-system -l app=balanced-scheduler --tail=200 \
  | grep -E "permit-deny-pod|Permit denied|Unreserve" || true
