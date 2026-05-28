#include "experiments/experiment_baseline.hpp"

#include <algorithm>
#include <iostream>
#include <mutex>
#include <random>
#include <string>
#include <thread>
#include <vector>

#include "circuits/circuit_registry.hpp"
#include "experiments/experiment_common.hpp"
#include "experiments/experiment_logger.hpp"
#include "optimizers/genetic_algorithm.hpp"
#include "optimizers/simulated_annealing.hpp"
#include "utils.hpp"

namespace
{
    std::mutex cout_mutex;

    void print_status(
        const std::string& text)
    {
        std::lock_guard<std::mutex> lock(cout_mutex);
        std::cout << text << std::endl;
    }

    void run_baseline_worker(
        unsigned int worker_id,
        unsigned int worker_count,
        const std::string& shard_file)
    {
        experiment_logger logger(
            shard_file,
            "baseline",
            false);

        logger.set_sweep_info("none", 0.0f);

        const unsigned int run_count =
            get_run_count();

        fixed_point_format init_format;
        init_format.whole_bits = 64;
        init_format.frac_bits = 64;

        for (unsigned int circuit_id = get_first_circuit_id();
            circuit_id <= get_last_circuit_id();
            circuit_id++)
        {
            for (unsigned int run_id = worker_id;
                run_id < run_count;
                run_id += worker_count)
            {
                sim_config config =
                    get_base_sim_config();

                config.circuit_id =
                    circuit_id;

                print_status(
                    "Baseline: circuit " +
                    std::to_string(circuit_id) +
                    ", run " +
                    std::to_string(run_id));

                //
                // GA
                //

                std::vector<fixed_point_format> ga_block_formats(
                    get_circuit_op_num(config),
                    init_format);

                std::mt19937 ga_rng(
                    make_experiment_seed(
                        circuit_id,
                        run_id,
                        1,
                        "none",
                        0.0f));

                genetic_algorithm(
                    ga_block_formats,
                    config,
                    &logger,
                    run_id,
                    ga_rng);

                //
                // SA
                //

                std::vector<fixed_point_format> sa_block_formats(
                    get_circuit_op_num(config),
                    init_format);

                config.max_it =
                    get_sa_iterations_for_equal_budget(config);

                std::mt19937 sa_rng(
                    make_experiment_seed(
                        circuit_id,
                        run_id,
                        2,
                        "none",
                        0.0f));

                simulated_annealing(
                    sa_block_formats,
                    config,
                    &logger,
                    run_id,
                    sa_rng);
            }
        }
    }
}

void experiment_baseline(
    unsigned int worker_count)
{
    if (worker_count == 0)
    {
        worker_count = 1;
    }

    worker_count =
        std::min(worker_count, get_run_count());

    std::string temp_folder =
        create_temp_experiment_folder("baseline");

    std::vector<std::string> shard_files;
    std::vector<std::thread> threads;

    for (unsigned int worker_id = 0;
        worker_id < worker_count;
        worker_id++)
    {
        std::string shard_file =
            temp_folder +
            "/shard_" +
            std::to_string(worker_id) +
            ".csv";

        shard_files.push_back(shard_file);

        threads.emplace_back(
            run_baseline_worker,
            worker_id,
            worker_count,
            shard_file);
    }

    for (std::thread& t : threads)
    {
        t.join();
    }

    std::string final_csv =
        make_result_csv_path(
            "experiment_baseline.csv");

    merge_csv_files(
        shard_files,
        final_csv);

    delete_folder_recursive(
        temp_folder);
}