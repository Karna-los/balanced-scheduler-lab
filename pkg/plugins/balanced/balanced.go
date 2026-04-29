package balanced

import (
	"context"
	"time"

	v1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/klog/v2"
	"k8s.io/kube-scheduler/framework"
)

const Name = "BalancedScheduler"

type BalancedScheduler struct{}

var _ framework.FilterPlugin = &BalancedScheduler{}
var _ framework.ScorePlugin = &BalancedScheduler{}
var _ framework.ScoreExtensions = &BalancedScheduler{}
var _ framework.ReservePlugin = &BalancedScheduler{}
var _ framework.PermitPlugin = &BalancedScheduler{}

func New(_ context.Context, _ runtime.Object, _ framework.Handle) (framework.Plugin, error) {
	return &BalancedScheduler{}, nil
}

func (b *BalancedScheduler) Name() string {
	return Name
}

func (b *BalancedScheduler) Filter(
	ctx context.Context,
	state framework.CycleState,
	pod *v1.Pod,
	nodeInfo framework.NodeInfo,
) *framework.Status {
	node := nodeInfo.Node()
	klog.InfoS("BalancedScheduler Filter", "pod", pod.Name, "node", node.Name)

	if node.Labels["balanced-scheduler/disabled"] == "true" {
		klog.InfoS("BalancedScheduler Filter rejected disabled node", "pod", pod.Name, "node", node.Name)
		return framework.NewStatus(framework.Unschedulable, "node disabled by balanced-scheduler/disabled label")
	}

	return framework.NewStatus(framework.Success)
}

func (b *BalancedScheduler) Score(
	ctx context.Context,
	state framework.CycleState,
	pod *v1.Pod,
	nodeInfo framework.NodeInfo,
) (int64, *framework.Status) {
	node := nodeInfo.Node()
	klog.InfoS("BalancedScheduler Score", "pod", pod.Name, "node", node.Name)
	return 50, framework.NewStatus(framework.Success)
}

func (b *BalancedScheduler) ScoreExtensions() framework.ScoreExtensions {
	return b
}

func (b *BalancedScheduler) NormalizeScore(
	ctx context.Context,
	state framework.CycleState,
	pod *v1.Pod,
	scores framework.NodeScoreList,
) *framework.Status {
	klog.InfoS("BalancedScheduler NormalizeScore", "pod", pod.Name)
	return framework.NewStatus(framework.Success)
}

func (b *BalancedScheduler) Reserve(
	ctx context.Context,
	state framework.CycleState,
	pod *v1.Pod,
	nodeName string,
) *framework.Status {
	klog.InfoS("BalancedScheduler Reserve", "pod", pod.Name, "node", nodeName)
	return framework.NewStatus(framework.Success)
}

func (b *BalancedScheduler) Unreserve(
	ctx context.Context,
	state framework.CycleState,
	pod *v1.Pod,
	nodeName string,
) {
	klog.InfoS("BalancedScheduler Unreserve", "pod", pod.Name, "node", nodeName)
}

func (b *BalancedScheduler) Permit(
	ctx context.Context,
	state framework.CycleState,
	pod *v1.Pod,
	nodeName string,
) (*framework.Status, time.Duration) {
	klog.InfoS("BalancedScheduler Permit", "pod", pod.Name, "node", nodeName)

	if pod.Annotations["balanced-scheduler/permit"] == "deny" {
		klog.InfoS("BalancedScheduler Permit denied by annotation", "pod", pod.Name, "node", nodeName)
		return framework.NewStatus(framework.Unschedulable, "denied by balanced-scheduler/permit annotation"), 0
	}

	return framework.NewStatus(framework.Success), 0
}
