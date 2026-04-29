package main

import (
	"os"

	"balanced-scheduler-lab/pkg/plugins/balanced"

	"k8s.io/component-base/cli"
	"k8s.io/kubernetes/cmd/kube-scheduler/app"
)

func main() {
	command := app.NewSchedulerCommand(
		app.WithPlugin(balanced.Name, balanced.New),
	)

	code := cli.Run(command)
	os.Exit(code)
}
