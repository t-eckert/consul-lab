package main

import (
	"github.com/hashicorp/consul/api"
)

func main() {

	client, err := api.NewClient(&api.Config{
		Address: "192.168.47.216:8500",
	})
	if err != nil {
		panic(err)
	}

	reg := &api.AgentServiceRegistration{
		Name: "cartel-env-kind",
		ID:   "cartel-env-kind-0",
	}

	if err := client.Agent().ServiceRegister(reg); err != nil {
		panic(err)
	}
}
