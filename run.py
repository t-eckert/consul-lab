from rich import print

import click
import lab.experiment.experiment
import lab.format


@click.group()
def cli():
    pass


@click.command("up")
@click.option(
    "--experiment",
    prompt=f"""Which experiment would you like to run?

{lab.format.format_experiment_table(lab.experiment.experiment.list_all())}
Select by NAME""",
    help="The Consul experiment to run.",
)
def up(experiment: str):
    experiments = lab.experiment.experiment.list_all()

    exp = experiments.get(experiment)
    if not exp:
        print(f"Could not find experiment {experiment}")
        return

    exp.up()


@click.command("down")
@click.option(
    "--experiment",
    help="The Consul experiment to stop.",
)
def down(experiment: str):
    experiments = lab.experiment.experiment.list_all()

    exp = experiments.get(experiment)
    if not exp:
        print(f"Could not find experiment {experiment}")
        return

    exp.down()


cli.add_command(up)
cli.add_command(down)

if __name__ == "__main__":
    cli()
