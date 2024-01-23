package main

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"time"
)

var useEnterprise = false
var k8sClusterName = "api-gateway-conformance"

const (
	ConsulRepo           = "https://github.com/hashicorp/consul"
	ConsulEnterpriseRepo = "https://github.com/hashicorp/consul-enterprise"
	ConsulK8sRepo        = "https://github.com/hashicorp/consul-k8s"
	GatewayAPIRepo       = "https://github.com/kubernetes-sigs/gateway-api"

	GatewayAPIRef = "release-0.8"
)

func main() {
	failOnError(cloneRepo(ConsulRepo, "consul"))
	failOnError(cloneRepo(ConsulK8sRepo, "consul-k8s"))
	failOnError(cloneRepo(fmt.Sprintf("%s@%s", GatewayAPIRepo, GatewayAPIRef), "gateway-api"))

	failOnError(buildConsul())
	failOnError(buildConsulK8s())

	time.Sleep(5 * time.Second)

	cleanupRepo("consul")
	cleanupRepo("consul-k8s")
	cleanupRepo("gateway-api")
}

func failOnError(err error) {
	if err != nil {
		log.Fatal(err)
	}
}

func cloneRepo(repo, dest string) error {
	cmd := exec.Command("git", "clone", repo, dest)

	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	return cmd.Run()
}

func cleanupRepo(dest string) func() {
	return func() {
		cmd := exec.Command("rm", "-rf", dest)

		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr

		cmd.Run()
	}
}

func buildConsul() error {
	return nil
}

func buildConsulK8s() error {
	return nil
}

func createK8sCluster() error {
	return nil
}
