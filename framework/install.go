package framework

import (
	"os/exec"
)

func Install(pathToValues string) error {
	return exec.Command("helm", "install", "consul", HelmChartPath, "-f", pathToValues, "-n", "consul", "--create-namespace").Run()
}
