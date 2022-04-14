from dataclasses import dataclass
from pathlib import Path
from rich import print

import hcl as parser

from lab.consul import install_consul_on_kubernetes, uninstall_consul_on_kubernetes
from lab.kubernetes import install_kubernetes_resources, uninstall_kubernetes_resources


@dataclass
class Experiment:
    name: str
    description: str
    consul_values: Path
    environment: str
    kubernetes_resources: list[Path]

    def up(self):
        print(f"Running {self.name}")

        if self.environment == "kubernetes":
            install_consul_on_kubernetes(self.consul_values)
            install_kubernetes_resources(self.kubernetes_resources)

    def down(self):
        print(f"Stopping {self.name}")

        if self.environment == "kubernetes":
            uninstall_consul_on_kubernetes()
            uninstall_kubernetes_resources(self.kubernetes_resources)

    @staticmethod
    def from_hcl(hcl: Path) -> "Experiment":
        with open(hcl) as f:
            parsed = parser.loads(f.read())

        path_to = hcl.cwd() / hcl.parent

        return Experiment(
            name=parsed["name"],
            description=parsed["description"],
            consul_values=path_to / Path(parsed["consul-values"]),
            environment=parsed["environment"],
            kubernetes_resources=[
                path_to / Path(f"{kubernetes_resource}.yaml")
                for kubernetes_resource in parsed["kubernetes"]["resources"]
            ],
        )


def list_all() -> dict[str, Experiment]:
    experiments = [
        Experiment.from_hcl(path) for path in Path("./experiments").glob("*/*.hcl")
    ]

    return {experiment.name: experiment for experiment in experiments}
