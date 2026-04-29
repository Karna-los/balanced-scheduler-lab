#!/usr/bin/env bash
set -euo pipefail

kind load docker-image balanced-scheduler:dev --name balanced-lab

docker exec balanced-lab-control-plane crictl images | grep balanced-scheduler || true
docker exec balanced-lab-worker crictl images | grep balanced-scheduler || true
docker exec balanced-lab-worker2 crictl images | grep balanced-scheduler || true
