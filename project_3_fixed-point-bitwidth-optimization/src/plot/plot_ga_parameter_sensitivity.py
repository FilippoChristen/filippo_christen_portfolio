import glob
import os
from collections import defaultdict

import matplotlib.pyplot as plt

from plot_common import (
    read_csv,
    get_final_rows,
    get_circuit_ids,
    get_circuit_name,
    mean,
)


CSV_FILE = max(
    glob.glob("../../out/build/x64-Debug/experiment_results/experiment_ga_sweeps_*.csv"),
    key=os.path.getmtime,
)


def main():
    rows = read_csv(CSV_FILE)
    final_rows = get_final_rows(rows)

    sweep_parameters = sorted(set(row["sweep_parameter"] for row in final_rows))
    circuit_ids = get_circuit_ids(final_rows)

    for sweep_parameter in sweep_parameters:
        selected_rows = [
            row for row in final_rows
            if row["sweep_parameter"] == sweep_parameter
        ]

        plt.figure(figsize=(10, 6))

        for circuit_id in circuit_ids:
            circuit_rows = [
                row for row in selected_rows
                if row["circuit_id"] == circuit_id
            ]

            value_to_losses = defaultdict(list)

            for row in circuit_rows:
                value_to_losses[row["sweep_value"]].append(row["best_loss"])

            xs = sorted(value_to_losses.keys())
            ys = [mean(value_to_losses[x]) for x in xs]

            plt.plot(
                xs,
                ys,
                marker="o",
                linewidth=2,
                label=get_circuit_name(circuit_id),
            )

        if sweep_parameter == "mutation_prob":
            plt.xscale("log")

        plt.xlabel(sweep_parameter)
        plt.ylabel("Average final best loss over runs")
        plt.title(f"GA Parameter Sensitivity per Circuit: {sweep_parameter}")
        plt.yscale("log")
        plt.grid(True)

        plt.legend(
            title="Circuit",
            loc="center left",
            bbox_to_anchor=(1.02, 0.5),
            borderaxespad=0.0,
        )

        plt.tight_layout()
        plt.show()


if __name__ == "__main__":
    main()