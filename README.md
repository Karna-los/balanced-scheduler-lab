# BalancedScheduler Lab

A course-level Kubernetes custom scheduler experiment based on kube-scheduler Scheduling Framework.

## Overview

This project implements an out-of-tree kube-scheduler plugin named `BalancedScheduler`.

It runs as a second scheduler in a kind cluster.

Pods using this custom scheduler should set:

    spec:
      schedulerName: balanced-scheduler

## Implemented extension points

- Filter
- Score
- NormalizeScore
- Reserve
- Permit
- Unreserve

Bind is handled by the default Kubernetes `DefaultBinder`.

## Environment

- Windows + WSL2
- Docker Desktop
- kind
- Kubernetes node image: `kindest/node:v1.35.0`
- Go: `1.25.5`
- Cluster name: `balanced-lab`
- Scheduler image: `balanced-scheduler:dev`

## Quick start

Run these scripts in order:

    scripts/00-create-kind.sh
    scripts/01-build.sh
    scripts/02-load-image.sh
    scripts/03-deploy.sh

## Test

    scripts/04-test-normal.sh
    scripts/05-test-permit-deny.sh
    scripts/06-test-filter-disabled-node.sh

## Cleanup test workloads

    scripts/99-cleanup.sh

## Current status

The project has been verified in a 3-node kind cluster.

The custom scheduler can:

- run as a Kubernetes Deployment in `kube-system`
- schedule Pods with `schedulerName: balanced-scheduler`
- reject Pods in Permit phase using annotation
- reject disabled nodes in Filter phase using node label
- execute Reserve and Unreserve visibly in logs
