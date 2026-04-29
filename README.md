# BalancedScheduler Lab

这是一个课程实验级 Kubernetes 自定义调度器项目，基于 kube-scheduler Scheduling Framework 实现 out-of-tree plugin。

自定义调度器作为第二调度器运行：

    schedulerName: balanced-scheduler

## 1. 实验目标

本项目实现一个最小可运行的自定义 kube-scheduler 插件。

核心命名：

- 插件名：BalancedScheduler
- 调度器名：balanced-scheduler
- 镜像名：balanced-scheduler:dev
- 运行方式：作为 Kubernetes 集群内的 Deployment 运行

已实现并验证的调度阶段：

- Filter
- Score
- NormalizeScore
- Reserve
- Permit
- Unreserve

Bind 阶段使用 Kubernetes 默认的 DefaultBinder。

## 2. 环境要求

推荐环境：

- Ubuntu 或 Windows + WSL2
- Docker
- kind
- kubectl
- Go 1.25+
- git

本实验已验证版本：

- kind：v0.31.0
- Kubernetes node image：kindest/node:v1.35.0
- kubectl：v1.35.x
- Go：1.25.5

环境检查：

    docker version
    kind version
    kubectl version --client
    go version
    git --version

## 3. 快速部署

克隆项目：

    git clone https://github.com/Karna-los/balanced-scheduler-lab.git
    cd balanced-scheduler-lab

一键部署：

    chmod +x scripts/*.sh
    scripts/all-in-one-deploy.sh

该脚本会自动完成：

1. 创建三节点 kind 集群
2. 编译 balanced-scheduler
3. 构建镜像 balanced-scheduler:dev
4. 将镜像加载进 kind
5. 部署 RBAC、ConfigMap、Deployment
6. 运行一次普通调度测试

## 4. 分步部署

如果不使用一键脚本，也可以分步执行：

    scripts/00-create-kind.sh
    scripts/01-build.sh
    scripts/02-load-image.sh
    scripts/03-deploy.sh

## 5. 测试命令

普通调度测试：

    scripts/04-test-normal.sh

Permit 拒绝测试：

    scripts/05-test-permit-deny.sh

Filter 禁用节点测试：

    scripts/06-test-filter-disabled-node.sh

查看调度器状态：

    kubectl get deployment balanced-scheduler -n kube-system
    kubectl get pods -n kube-system -l app=balanced-scheduler -o wide
    kubectl logs -n kube-system -l app=balanced-scheduler --tail=100

## 6. 可调整项

kind 集群配置文件：

    kind.yaml

可调整内容：

- 集群名：balanced-lab
- 节点数量
- Kubernetes node 镜像版本

调度器配置文件：

    deploy/configmap.yaml

核心配置：

    schedulerName: balanced-scheduler

可调整内容：

- schedulerName
- Score 权重 weight
- 启用或关闭插件阶段

镜像相关文件：

    Dockerfile
    deploy/deployment.yaml
    scripts/01-build.sh
    scripts/02-load-image.sh
    scripts/all-in-one-deploy.sh

默认镜像：

    balanced-scheduler:dev

插件代码：

    pkg/plugins/balanced/balanced.go

当前支持的自定义逻辑：

节点标签禁用：

    balanced-scheduler/disabled=true

Pod annotation 拒绝调度：

    balanced-scheduler/permit: "deny"

## 7. 清理命令

清理测试负载：

    scripts/99-cleanup.sh

删除 kind 集群：

    kind delete cluster --name balanced-lab

清理 Docker build cache：

    docker builder prune

## 8. 项目结构

    cmd/balanced-scheduler/main.go          调度器入口
    pkg/plugins/balanced/balanced.go        BalancedScheduler 插件实现
    deploy/rbac.yaml                        RBAC
    deploy/configmap.yaml                   scheduler 配置
    deploy/deployment.yaml                  scheduler Deployment
    workloads/                              测试负载
    scripts/                                部署与测试脚本
    kind.yaml                               kind 三节点集群配置
    Dockerfile                              调度器镜像构建文件
