from lab.experiment.experiment import Experiment


def format_experiment_table(experiments: dict[str, Experiment]) -> str:
    table = "NAME\t\tENVIRONMENT\tDESCRIPTION\n"

    for name, experiment in experiments.items():
        table += f"{name}\t{experiment.environment}\t{experiment.description}\n"

    return table
