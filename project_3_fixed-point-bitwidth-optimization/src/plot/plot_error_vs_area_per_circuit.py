import glob
import os

import matplotlib.pyplot as plt

from plot_common import (
    read_csv,
    get_final_rows_baseline,
    get_algorithms,
    get_circuit_ids,
    get_circuit_name,
)


CSV_FILE = max(
    glob.glob("../../out/build/x64-Debug/experiment_results/experiment_baseline_*.csv"),
    key=os.path.getmtime,
)

TOLERANCE = 0.05


def main():
    rows = read_csv(CSV_FILE)
    final_rows = get_final_rows_baseline(rows)

    algorithms = get_algorithms(final_rows)
    circuit_ids = get_circuit_ids(final_rows)

    for circuit_id in circuit_ids:
        plt.figure(figsize=(10, 6))

        for algorithm in algorithms:
            selected_rows = [
                row for row in final_rows
                if row["algorithm"] == algorithm
                and row["circuit_id"] == circuit_id
            ]

            areas = [row["best_area"] for row in selected_rows]
            errors = [row["best_raw_error"] for row in selected_rows]

            plt.scatter(
                areas,
                errors,
                s=35,
                alpha=0.75,
                label=algorithm,
            )

        plt.axhline(
            TOLERANCE,
            linestyle="--",
            label="tolerance",
        )

        plt.xlabel("Final best area")
        plt.ylabel("Final raw average relative error")
        plt.title(f"Raw Error vs Area: {get_circuit_name(circuit_id)}")
        plt.grid(True)
        plt.legend()
        plt.tight_layout()
        plt.show()


if __name__ == "__main__":
    main()