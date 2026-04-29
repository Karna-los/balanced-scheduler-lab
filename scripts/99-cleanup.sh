#!/usr/bin/env bash
set -euo pipefail

kubectl delete -f workloads/balanced-scheduler-normal.yaml --ignore-not-found
kubectl delete -f workloads/baseline-default-scheduler.yaml --ignore-not-found
kubectl delete -f workloads/permit-deny-pod.yaml --ignore-not-found
kubectl delete -f workloads/filter-test-pod.yaml --ignore-not-found
kubectl delete -f workloads/incluster-test-pod.yaml --ignore-not-found
kubectl delete -f workloads/balanced-test-pod.yaml --ignore-not-found
kubectl label node balanced-lab-worker balanced-scheduler/disabled- || true

echo "===== default namespace ====="
kubectl get pods -o wide

echo "===== scheduler ====="
kubectl get deployment balanced-scheduler -n kube-system
kubectl get pods -n kube-system -l app=balanced-scheduler -o wide
