from pathlib import Path
from rich import print

import os


def install_consul_on_kubernetes(values: Path):
    print("Installing Consul on Kubernetes")
    ex = f"consul-k8s install -f {values} -auto-approve"

    os.system(ex)


def uninstall_consul_on_kubernetes():
    print("Uninstalling Consul on Kubernetes")

    os.system("consul-k8s uninstall -auto-approve")
