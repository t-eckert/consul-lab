from pathlib import Path
from rich import print

import os


def install_kubernetes_resources(resources: list[Path]):
    print("Installing Kubernetes resources")

    for resource in resources:
        os.system(f"kubectl apply -f {resource}")


def uninstall_kubernetes_resources(resources: list[Path]):
    print("Uninstalling Kubernetes resources")

    for resource in resources:
        os.system(f"kubectl delete -f {resource}")
