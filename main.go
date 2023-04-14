package main

import (
	apigatewayforconsulonkubernetes "github.com/t-eckert/consul-lab/experiments/api-gateway-for-consul-on-kubernetes"
)

func main() {
	if err := apigatewayforconsulonkubernetes.Experiment.Run(); err != nil {
		panic(err)
	}
}
