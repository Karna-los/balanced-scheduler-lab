#!/usr/bin/env bash
set -euo pipefail

CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o bin/balanced-scheduler ./cmd/balanced-scheduler
docker build -t balanced-scheduler:dev .
docker images | grep balanced-scheduler || true
