#include "experiments/experiment_common.hpp"

#include <chrono>
#include <cmath>
#include <cstdint>
#include <ctime>
#include <filesystem>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <sstream>
#include <string>
#include <vector>

namespace
{
    std::string make_common_timestamp()
    {
        auto now = std::chrono::system_clock::now();
        std::time_t time =
            std::chrono::system_clock::to_time_t(now);

        std::tm tm_buf;

#ifdef _WIN32
        localtime_s(&tm_buf, &time);
#else
        localtime_r(&time, &tm_buf);
#endif

        std::ostringstream oss;
        oss << std::put_time(
            &tm_buf,
            "%Y-%m-%d_%H-%M-%S");

        return oss.str();
    }

    std::string remove_extension(
        const std::string& file_name)
    {
        size_t pos = file_name.find_last_of('.');

        if (pos == std::string::npos)
        {
            return file_name;
        }

        return file_name.substr(0, pos);
    }

    void mix_seed(
        uint32_t& seed,
        uint32_t value)
    {
        seed ^= value + 0x9e3779b9u + (seed << 6) + (seed >> 2);
    }

    uint32_t stable_string_hash(
        const std::string& text)
    {
        uint32_t hash = 2166136261u;

        for (char c : text)
        {
            hash ^= static_cast<uint8_t>(c);
            hash *= 16777619u;
        }

        return hash;
    }
}

sim_config get_base_sim_config()
{
    sim_config config;

    config.circuit_id = 1;

    config.toll = 0.05f;
    config.data_num = 500;
    config.min_input = -2.0f;
    config.max_input = 2.0f;
    config.max_it = 100;

    config.population_size = 40;
    config.mutation_prob = 0.01f;
    config.mutation_quantity = 5;
    config.tournament_size = 2;
    config.elite_count = 5;

    config.initial_temperature_factor = 10.0f;
    config.cooling_rate = 0.995f;
    config.neighbor_step_size = 1;

    return config;
}

unsigned int get_first_circuit_id()
{
    return 1;
}

unsigned int get_last_circuit_id()
{
    return 8;
}

unsigned int get_run_count()
{
    return 100;
}

unsigned int get_sa_iterations_for_equal_budget(
    const sim_config& config)
{
    if (config.population_size == 0)
    {
        return 0;
    }

    if (config.population_size <= config.elite_count)
    {
        return config.population_size - 1;
    }

    unsigned int ga_budget =
        config.population_size +
        (config.population_size - config.elite_count) * config.max_it;

    if (ga_budget == 0)
    {
        return 0;
    }

    return ga_budget - 1;
}

unsigned int make_experiment_seed(
    unsigned int circuit_id,
    unsigned int run_id,
    unsigned int algorithm_id,
    const std::string& sweep_parameter,
    float sweep_value)
{
    uint32_t seed = 2166136261u;

    uint32_t sweep_value_int =
        static_cast<uint32_t>(
            std::round(sweep_value * 1000000.0f));

    mix_seed(seed, circuit_id);
    mix_seed(seed, run_id);
    mix_seed(seed, algorithm_id);
    mix_seed(seed, stable_string_hash(sweep_parameter));
    mix_seed(seed, sweep_value_int);

    return seed;
}

std::string create_temp_experiment_folder(
    const std::string& experiment_name)
{
    std::filesystem::create_directories(
        "experiment_results");

    std::string folder =
        "experiment_results/tmp_" +
        experiment_name +
        "_" +
        make_common_timestamp();

    std::filesystem::create_directories(folder);

    return folder;
}

std::string make_result_csv_path(
    const std::string& file_name)
{
    std::filesystem::create_directories(
        "experiment_results");

    std::string output =
        "experiment_results/" +
        remove_extension(file_name) +
        "_" +
        make_common_timestamp() +
        ".csv";

    return output;
}

void merge_csv_files(
    const std::vector<std::string>& input_files,
    const std::string& output_file)
{
    std::ofstream out(output_file);

    if (!out.is_open())
    {
        std::cerr << "Could not open merged CSV: "
            << output_file
            << "\n";
        return;
    }

    bool header_written = false;

    for (const std::string& input_file : input_files)
    {
        std::ifstream in(input_file);

        if (!in.is_open())
        {
            std::cerr << "Could not open shard CSV: "
                << input_file
                << "\n";
            continue;
        }

        std::string line;
        bool first_line = true;

        while (std::getline(in, line))
        {
            if (first_line)
            {
                if (!header_written)
                {
                    out << line << "\n";
                    header_written = true;
                }

                first_line = false;
                continue;
            }

            if (!line.empty())
            {
                out << line << "\n";
            }
        }
    }

    std::cout << "Merged CSV written to: "
        << output_file
        << "\n";
}

void delete_folder_recursive(
    const std::string& folder_path)
{
    std::error_code ec;
    std::filesystem::remove_all(folder_path, ec);

    if (ec)
    {
        std::cerr << "Could not delete temporary folder: "
            << folder_path
            << "\n";
    }
}
