#!/usr/bin/env bash
set -euo pipefail

go build -o bin/balanced-scheduler ./cmd/balanced-scheduler
docker build -t balanced-scheduler:dev .
docker images | grep balanced-scheduler || true
