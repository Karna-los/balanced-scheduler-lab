#!/usr/bin/env bash
set -euo pipefail

kubectl apply -f workloads/balanced-scheduler-normal.yaml
kubectl rollout status deployment/balanced-scheduler-normal --timeout=120s

echo "===== pods ====="
kubectl get pods -l app=balanced-scheduler-normal -o wide

echo "===== node distribution ====="
kubectl get pods -l app=balanced-scheduler-normal -o wide --no-headers \
  | awk '{count[$7]++} END {for (node in count) print node, count[node]}'

echo "===== scheduler logs ====="
kubectl logs -n kube-system -l app=balanced-scheduler --tail=200 \
  | grep -E "balanced-scheduler-normal|BalancedScheduler" || true
