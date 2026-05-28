import glob
import os
from collections import defaultdict

import matplotlib.pyplot as plt

from plot_common import read_csv, get_algorithms, mean


CSV_FILE = max(
    glob.glob("../../out/build/x64-Debug/experiment_results/experiment_baseline_*.csv"),
    key=os.path.getmtime,
)


def main():
    rows = read_csv(CSV_FILE)

    algorithms = get_algorithms(rows)

    plt.figure(figsize=(10, 6))

    for algorithm in algorithms:
        algo_rows = [
            row for row in rows
            if row["algorithm"] == algorithm
        ]

        eval_to_losses = defaultdict(list)

        for row in algo_rows:
            eval_to_losses[row["fitness_evaluations"]].append(row["best_loss"])

        xs = sorted(eval_to_losses.keys())
        ys = [mean(eval_to_losses[x]) for x in xs]

        plt.plot(xs, ys, label=algorithm, linewidth=2)

    plt.xlabel("Fitness evaluations")
    plt.ylabel("Average best loss")
    plt.title("Convergence Over All Circuits and Runs")
    plt.yscale("log")
    plt.grid(True)
    plt.legend()
    plt.tight_layout()
    plt.show()


if __name__ == "__main__":
    main()