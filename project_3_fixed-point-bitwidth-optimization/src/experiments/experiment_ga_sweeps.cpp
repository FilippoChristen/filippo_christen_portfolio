#include "experiments/experiment_ga_sweeps.hpp"

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
#include "utils.hpp"

namespace
{
    std::mutex cout_mutex;

    struct ga_sweep_case
    {
        sim_config config;
        std::string sweep_parameter;
        float sweep_value;
    };

    void print_status(
        const std::string& text)
    {
        std::lock_guard<std::mutex> lock(cout_mutex);
        std::cout << text << std::endl;
    }

    std::vector<ga_sweep_case> make_ga_sweep_cases()
    {
        std::vector<ga_sweep_case> cases;

        {
            std::vector<unsigned int> values =
            {
                10,
                20,
                40,
                80,
                160
            };

            for (unsigned int value : values)
            {
                ga_sweep_case c;
                c.config = get_base_sim_config();
                c.config.population_size = value;
                c.sweep_parameter = "population_size";
                c.sweep_value = static_cast<float>(value);
                cases.push_back(c);
            }
        }

        {
            std::vector<float> values =
            {
                0.001f,
                0.005f,
                0.01f,
                0.03f,
                0.1f,
                0.3f
            };

            for (float value : values)
            {
                ga_sweep_case c;
                c.config = get_base_sim_config();
                c.config.mutation_prob = value;
                c.sweep_parameter = "mutation_prob";
                c.sweep_value = value;
                cases.push_back(c);
            }
        }

        {
            std::vector<unsigned int> values =
            {
                1,
                2,
                5,
                10,
                20
            };

            for (unsigned int value : values)
            {
                ga_sweep_case c;
                c.config = get_base_sim_config();
                c.config.mutation_quantity = value;
                c.sweep_parameter = "mutation_quantity";
                c.sweep_value = static_cast<float>(value);
                cases.push_back(c);
            }
        }

        {
            std::vector<unsigned int> values =
            {
                1,
                2,
                3,
                5,
                10
            };

            for (unsigned int value : values)
            {
                ga_sweep_case c;
                c.config = get_base_sim_config();
                c.config.tournament_size = value;
                c.sweep_parameter = "tournament_size";
                c.sweep_value = static_cast<float>(value);
                cases.push_back(c);
            }
        }

        return cases;
    }

    void run_ga_sweep_worker(
        unsigned int worker_id,
        unsigned int worker_count,
        const std::string& shard_file)
    {
        experiment_logger logger(
            shard_file,
            "ga_sweeps",
            false);

        const unsigned int run_count =
            get_run_count();

        std::vector<ga_sweep_case> cases =
            make_ga_sweep_cases();

        fixed_point_format init_format;
        init_format.whole_bits = 64;
        init_format.frac_bits = 64;

        for (const ga_sweep_case& sweep_case : cases)
        {
            logger.set_sweep_info(
                sweep_case.sweep_parameter,
                sweep_case.sweep_value);

            for (unsigned int circuit_id = get_first_circuit_id();
                circuit_id <= get_last_circuit_id();
                circuit_id++)
            {
                for (unsigned int run_id = worker_id;
                    run_id < run_count;
                    run_id += worker_count)
                {
                    sim_config config =
                        sweep_case.config;

                    config.circuit_id =
                        circuit_id;

                    print_status(
                        "GA sweep: " +
                        sweep_case.sweep_parameter +
                        " = " +
                        std::to_string(sweep_case.sweep_value) +
                        ", circuit " +
                        std::to_string(circuit_id) +
                        ", run " +
                        std::to_string(run_id));

                    std::vector<fixed_point_format> block_formats(
                        get_circuit_op_num(config),
                        init_format);

                    std::mt19937 rng(
                        make_experiment_seed(
                            circuit_id,
                            run_id,
                            1,
                            sweep_case.sweep_parameter,
                            sweep_case.sweep_value));

                    genetic_algorithm(
                        block_formats,
                        config,
                        &logger,
                        run_id,
                        rng);
                }
            }
        }
    }
}

void experiment_ga_sweeps(
    unsigned int worker_count)
{
    if (worker_count == 0)
    {
        worker_count = 1;
    }

    worker_count =
        std::min(worker_count, get_run_count());

    std::string temp_folder =
        create_temp_experiment_folder("ga_sweeps");

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
            run_ga_sweep_worker,
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
            "experiment_ga_sweeps.csv");

    merge_csv_files(
        shard_files,
        final_csv);

    delete_folder_recursive(
        temp_folder);
}