package apigatewayforconsulonkubernetes

import (
	_ "embed"
	"fmt"
	"os/exec"

	"github.com/t-eckert/consul-lab/framework"
)

//go:embed consul-values.yaml
var consulValues string

var Experiment = &framework.Experiment{
	Name:     "api-gateway-for-consul-on-kubernetes",
	Setup:    setup,
	Execute:  execute,
	Teardown: teardown,
}

func setup() error {
	fmt.Println("Setup")

	compile := exec.Command("make control-plane-dev-docker")
	compile.Dir = framework.ConsulK8sPath
	if err := compile.Run(); err != nil {
		return err
	}

	if err := exec.Command("kind load docker-image consul-k8s-control-plane-dev:latest --name consul-lab").Run(); err != nil {
		return err
	}

	load := exec.Command("helm install consul ./charts/consul --values ~/repos/consul-lab/experiments/api-gateway-for-consul-on-kubernetes/consul-values.yaml --namespace consul --create-namespace")
	load.Dir = framework.ConsulK8sPath
	if err := load.Run(); err != nil {
		return err
	}

	return nil
}

func execute() error {
	fmt.Println("Execute")
	return nil
}

func teardown() error {
	fmt.Println("Teardown")
	return nil
}
