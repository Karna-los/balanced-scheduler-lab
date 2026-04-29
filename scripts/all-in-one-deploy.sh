#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="balanced-lab"
IMAGE_NAME="balanced-scheduler:dev"

echo "===== BalancedScheduler all-in-one deploy ====="

echo "===== check commands ====="
for cmd in docker kind kubectl go; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "ERROR: command not found: $cmd"
    echo "Please install $cmd first."
    exit 1
  fi
done

echo "===== versions ====="
docker version --format 'Docker client {{.Client.Version}}, server {{.Server.Version}}' || docker version
kind version
kubectl version --client
go version

echo "===== check docker is running ====="
docker info >/dev/null

echo "===== create kind cluster if needed ====="
if kind get clusters | grep -qx "$CLUSTER_NAME"; then
  echo "kind cluster $CLUSTER_NAME already exists, skip create."
else
  kind create cluster --config kind.yaml
fi

echo "===== wait nodes ready ====="
kubectl wait --for=condition=Ready nodes --all --timeout=180s
kubectl get nodes -o wide

echo "===== build scheduler binary ====="
go build -o bin/balanced-scheduler ./cmd/balanced-scheduler

echo "===== build docker image ====="
docker build -t "$IMAGE_NAME" .

echo "===== load image into kind ====="
kind load docker-image "$IMAGE_NAME" --name "$CLUSTER_NAME"

echo "===== deploy scheduler ====="
kubectl apply -f deploy/rbac.yaml
kubectl apply -f deploy/configmap.yaml
kubectl apply -f deploy/deployment.yaml

echo "===== wait scheduler rollout ====="
kubectl rollout status deployment/balanced-scheduler -n kube-system --timeout=120s
kubectl get pods -n kube-system -l app=balanced-scheduler -o wide

echo "===== run normal test ====="
kubectl delete -f workloads/balanced-scheduler-normal.yaml --ignore-not-found
kubectl apply -f workloads/balanced-scheduler-normal.yaml
kubectl rollout status deployment/balanced-scheduler-normal --timeout=120s

echo "===== test pods ====="
kubectl get pods -l app=balanced-scheduler-normal -o wide

echo "===== node distribution ====="
kubectl get pods -l app=balanced-scheduler-normal -o wide --no-headers \
  | awk '{count[$7]++} END {for (node in count) print node, count[node]}'

echo "===== scheduler plugin logs ====="
kubectl logs -n kube-system -l app=balanced-scheduler --tail=200 \
  | grep -E "balanced-scheduler-normal|BalancedScheduler" || true

echo "===== success ====="
echo "BalancedScheduler has been built, deployed, and tested successfully."
