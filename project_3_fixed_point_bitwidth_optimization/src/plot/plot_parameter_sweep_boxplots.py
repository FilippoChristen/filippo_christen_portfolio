import glob
import os
from collections import defaultdict

import matplotlib.pyplot as plt

from plot_common import read_csv, get_final_rows, get_final_rows_streaming


CSV_FILES = [
    max(
        glob.glob(
            "../../out/build/x64-Debug/experiment_results/experiment_ga_sweeps_*.csv"
        ),
        key=os.path.getmtime,
    ),
    max(
        glob.glob(
            "../../out/build/x64-Debug/experiment_results/experiment_sa_sweeps_*.csv"
        ),
        key=os.path.getmtime,
    ),
]


def plot_file(csv_file):
    final_rows = get_final_rows_streaming(csv_file)

    experiment_name = final_rows[0]["experiment_name"] if final_rows else "experiment"

    sweep_parameters = sorted(set(row["sweep_parameter"] for row in final_rows))

    for sweep_parameter in sweep_parameters:
        selected_rows = [
            row for row in final_rows
            if row["sweep_parameter"] == sweep_parameter
        ]

        value_to_losses = defaultdict(list)

        for row in selected_rows:
            value_to_losses[row["sweep_value"]].append(row["best_loss"])

        values = sorted(value_to_losses.keys())
        data = [value_to_losses[value] for value in values]

        plt.figure(figsize=(10, 6))

        plt.boxplot(
            data,
            labels=[str(value) for value in values],
            showfliers=False,
            showmeans=True,
            meanprops={
                "marker": "^",
                "markerfacecolor": "red",
                "markeredgecolor": "red",
            },
        )

        plt.xlabel(sweep_parameter)
        plt.ylabel("Final best loss")
        plt.title(f"{experiment_name}: Final Loss Distribution: {sweep_parameter}")
        plt.grid(True, axis="y")
        plt.tight_layout()
        plt.show()


def main():
    for csv_file in CSV_FILES:
        plot_file(csv_file)


if __name__ == "__main__":
    main()