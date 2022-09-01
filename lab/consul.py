from pathlib import Path
from rich import print

import os


def install_consul_on_kubernetes(values: Path):
    print("Installing Consul on Kubernetes")
    os.system(f"consul-k8s install -f {values} -auto-approve")


def upgrade_consul_on_kubernetes(values: Path):
    print("Upgrading Consul on Kubernetes")
    os.system(f"consul-k8s upgrade -f {values} -auto-approve")


def uninstall_consul_on_kubernetes():
    print("Uninstalling Consul on Kubernetes")

    os.system("consul-k8s uninstall -auto-approve -wipe-data")
