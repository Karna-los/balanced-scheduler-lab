#!/usr/bin/env bash
set -euo pipefail

kind create cluster --config kind.yaml
kubectl wait --for=condition=Ready nodes --all --timeout=180s
kubectl get nodes -o wide
