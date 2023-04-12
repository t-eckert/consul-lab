package main

import (
	"fmt"
	"os"

	"github.com/t-eckert/consul-lab/framework"
)

const values = "./experiments/api-gateway-for-consul-on-kubernetes/consul-values.yaml"

func main() {
	err := framework.Install(values)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}
