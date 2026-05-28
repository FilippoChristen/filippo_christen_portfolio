import glob
import os
from collections import defaultdict

import matplotlib.pyplot as plt

from plot_common import read_csv, get_final_rows_baseline


CSV_FILE = max(
    glob.glob("../../out/build/x64-Debug/experiment_results/experiment_baseline_*.csv"),
    key=os.path.getmtime,
)


def main():
    rows = read_csv(CSV_FILE)
    final_rows = get_final_rows_baseline(rows)

    losses_by_algorithm = defaultdict(list)

    for row in final_rows:
        losses_by_algorithm[row["algorithm"]].append(row["best_loss"])

    algorithms = sorted(losses_by_algorithm.keys())
    data = [losses_by_algorithm[algorithm] for algorithm in algorithms]

    plt.figure(figsize=(10, 6))

    plt.boxplot(
        data,
        labels=algorithms,
        showfliers=False,
        showmeans=True,
        meanprops={
            "marker": "^",
            "markerfacecolor": "red",
            "markeredgecolor": "red",
        },
    )

    plt.ylabel("Final best loss")
    plt.title("Final Loss Distribution Over All Circuits and Runs")
    plt.grid(True, axis="y")
    plt.tight_layout()
    plt.show()


if __name__ == "__main__":
    main()