#!/usr/bin/env bash
set -euo pipefail

kubectl delete pod filter-test-pod --ignore-not-found
kubectl label node balanced-lab-worker balanced-scheduler/disabled=true --overwrite

kubectl apply -f workloads/filter-test-pod.yaml
sleep 5

echo "===== pod ====="
kubectl get pod filter-test-pod -o wide || true

echo "===== events ====="
kubectl describe pod filter-test-pod | sed -n '/Events:/,$p' || true

echo "===== scheduler logs ====="
kubectl logs -n kube-system -l app=balanced-scheduler --tail=200 \
  | grep -E "filter-test-pod|disabled node|BalancedScheduler Filter" || true

echo "===== remove disabled label ====="
kubectl label node balanced-lab-worker balanced-scheduler/disabled-
