import csv
from collections import defaultdict


STRING_COLUMNS = {
    "experiment_name",
    "sweep_parameter",
    "algorithm",
}


INT_COLUMNS = {
    "circuit_id",
    "run_id",
    "population_size",
    "mutation_quantity",
    "tournament_size",
    "elite_count",
    "neighbor_step_size",
    "iteration",
    "fitness_evaluations",
    "total_bits",
    "max_bits",
}


def get_circuit_name(circuit_id):
    names = {
        1: "adder_tree",
        2: "multiplier_chain",
        3: "mac_chain",
        4: "polynomial",
        5: "fir_like",
        6: "deep_mixed_dag",
        7: "balanced_tree",
        8: "unbalanced_chain",
    }

    return names.get(circuit_id, f"circuit_{circuit_id}")


def read_csv(file_name):
    rows = []

    with open(file_name, "r") as file:
        reader = csv.DictReader(file)

        for row in reader:
            converted = {}

            for key, value in row.items():
                if value is None or value == "":
                    continue

                if key in STRING_COLUMNS:
                    converted[key] = value
                elif key in INT_COLUMNS:
                    converted[key] = int(float(value))
                else:
                    converted[key] = float(value)

            if "best_penalized_error" not in converted:
                if "best_error" in converted:
                    converted["best_penalized_error"] = converted["best_error"]
                elif "best_loss" in converted and "best_area" in converted:
                    converted["best_penalized_error"] = (
                        converted["best_loss"] - converted["best_area"]
                    )

            if "best_raw_error" not in converted:
                converted["best_raw_error"] = converted.get(
                    "best_penalized_error",
                    0.0,
                )

            rows.append(converted)

    return rows


def read_multiple_csv(csv_files):
    rows = []

    for csv_file in csv_files:
        try:
            rows.extend(read_csv(csv_file))
        except FileNotFoundError:
            print(f"Warning: CSV file not found: {csv_file}")

    return rows


def group_by_algorithm_circuit_run(rows):
    grouped = defaultdict(list)

    for row in rows:
        key = (
            row["algorithm"],
            row["circuit_id"],
            row["run_id"],
        )
        grouped[key].append(row)

    for key in grouped:
        grouped[key].sort(key=lambda r: r["iteration"])

    return grouped


def group_by_sweep_algorithm_circuit_run(rows):
    grouped = defaultdict(list)

    for row in rows:
        key = (
            row.get("sweep_parameter", "none"),
            row.get("sweep_value", 0.0),
            row["algorithm"],
            row["circuit_id"],
            row["run_id"],
        )
        grouped[key].append(row)

    for key in grouped:
        grouped[key].sort(key=lambda r: r["iteration"])

    return grouped

def convert_csv_row(row):
    converted = {}

    for key, value in row.items():
        if value is None or value == "":
            continue

        if key in STRING_COLUMNS:
            converted[key] = value
        elif key in INT_COLUMNS:
            converted[key] = int(float(value))
        else:
            converted[key] = float(value)

    if "best_penalized_error" not in converted:
        if "best_error" in converted:
            converted["best_penalized_error"] = converted["best_error"]
        elif "best_loss" in converted and "best_area" in converted:
            converted["best_penalized_error"] = (
                converted["best_loss"] - converted["best_area"]
            )

    if "best_raw_error" not in converted:
        converted["best_raw_error"] = converted.get(
            "best_penalized_error",
            0.0,
        )

    return converted


def get_final_rows_streaming(file_name):
    final_by_key = {}

    with open(file_name, "r") as file:
        reader = csv.DictReader(file)

        for row in reader:
            converted = convert_csv_row(row)

            key = (
                converted.get("sweep_parameter", "none"),
                converted.get("sweep_value", 0.0),
                converted["algorithm"],
                converted["circuit_id"],
                converted["run_id"],
            )

            if key not in final_by_key:
                final_by_key[key] = converted
            elif converted["iteration"] > final_by_key[key]["iteration"]:
                final_by_key[key] = converted

    return list(final_by_key.values())


def get_final_rows_baseline(rows):
    grouped = group_by_algorithm_circuit_run(rows)
    return [run_rows[-1] for run_rows in grouped.values()]


def get_final_rows(rows):
    grouped = group_by_sweep_algorithm_circuit_run(rows)
    return [run_rows[-1] for run_rows in grouped.values()]


def get_algorithms(rows):
    return sorted(set(row["algorithm"] for row in rows))


def get_circuit_ids(rows):
    return sorted(set(row["circuit_id"] for row in rows))


def get_sweep_parameters(rows):
    return sorted(set(row.get("sweep_parameter", "none") for row in rows))


def mean(values):
    if not values:
        return 0.0

    return sum(values) / len(values)


def median(values):
    if not values:
        return 0.0

    values = sorted(values)
    n = len(values)

    if n % 2 == 1:
        return values[n // 2]

    return 0.5 * (values[n // 2 - 1] + values[n // 2])