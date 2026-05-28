import glob
import os
from collections import defaultdict

import matplotlib.pyplot as plt

from plot_common import read_csv, get_final_rows_baseline


CSV_FILE = max(
    glob.glob("../../out/build/x64-Debug/experiment_results/experiment_baseline_*.csv"),
    key=os.path.getmtime,
)

TOLERANCE = 0.05


def main():
    rows = read_csv(CSV_FILE)
    final_rows = get_final_rows_baseline(rows)

    success_by_algorithm = defaultdict(list)

    for row in final_rows:
        success = 1.0 if row["best_raw_error"] <= TOLERANCE else 0.0
        success_by_algorithm[row["algorithm"]].append(success)

    algorithms = sorted(success_by_algorithm.keys())
    rates = [
        sum(success_by_algorithm[algorithm]) / len(success_by_algorithm[algorithm])
        for algorithm in algorithms
    ]

    plt.figure(figsize=(8, 5))
    plt.bar(algorithms, rates)

    plt.ylabel("Success rate")
    plt.title("Success Rate Over All Circuits and Runs")
    plt.ylim(0.0, 1.0)
    plt.grid(True, axis="y")
    plt.tight_layout()
    plt.show()


if __name__ == "__main__":
    main()