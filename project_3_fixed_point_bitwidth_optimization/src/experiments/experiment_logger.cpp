#include "experiments/experiment_logger.hpp"

#include <chrono>
#include <ctime>
#include <filesystem>
#include <iomanip>
#include <iostream>
#include <sstream>
#include <string>
#include <vector>

#include "utils.hpp"


namespace
{
    std::string make_logger_timestamp()
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
        size_t pos =
            file_name.find_last_of('.');

        if (pos == std::string::npos)
        {
            return file_name;
        }

        return file_name.substr(0, pos);
    }
}

experiment_logger::experiment_logger(
    const std::string& file_name,
    const std::string& experiment_name,
    bool timestamp_output_file)
    : experiment_name(experiment_name)
{
    std::string output_file_name;

    if (timestamp_output_file)
    {
        std::filesystem::create_directories(
            "experiment_results");

        output_file_name =
            "experiment_results/" +
            remove_extension(file_name) +
            "_" +
            make_logger_timestamp() +
            ".csv";
    }
    else
    {
        std::filesystem::path path(file_name);

        if (path.has_parent_path())
        {
            std::filesystem::create_directories(
                path.parent_path());
        }

        output_file_name =
            file_name;
    }

    file.open(output_file_name);

    if (!file.is_open())
    {
        std::cerr << "Could not open CSV file: "
            << output_file_name
            << "\n";
    }

    file << "experiment_name,"
        << "sweep_parameter,"
        << "sweep_value,"
        << "algorithm,"
        << "circuit_id,"
        << "run_id,"
        << "population_size,"
        << "mutation_prob,"
        << "mutation_quantity,"
        << "tournament_size,"
        << "elite_count,"
        << "initial_temperature_factor,"
        << "cooling_rate,"
        << "neighbor_step_size,"
        << "iteration,"
        << "fitness_evaluations,"
        << "best_loss,"
        << "best_area,"
        << "best_penalized_error,"
        << "best_raw_error,"
        << "total_bits,"
        << "average_bits,"
        << "max_bits\n";

    std::cout << "Writing CSV: "
        << output_file_name
        << "\n";
}

void experiment_logger::set_sweep_info(
    const std::string& sweep_parameter,
    float sweep_value)
{
    this->sweep_parameter =
        sweep_parameter;

    this->sweep_value =
        sweep_value;
}

void experiment_logger::log(
    const std::string& algorithm_name,
    const sim_config& simulation_configuration,
    unsigned int run_id,
    unsigned int iteration,
    unsigned int fitness_evaluations,
    float best_loss,
    float best_area,
    float best_penalized_error,
    float best_raw_error,
    const std::vector<fixed_point_format>& best_config)
{
    file << experiment_name << ","
        << sweep_parameter << ","
        << sweep_value << ","
        << algorithm_name << ","
        << simulation_configuration.circuit_id << ","
        << run_id << ","
        << simulation_configuration.population_size << ","
        << simulation_configuration.mutation_prob << ","
        << simulation_configuration.mutation_quantity << ","
        << simulation_configuration.tournament_size << ","
        << simulation_configuration.elite_count << ","
        << simulation_configuration.initial_temperature_factor << ","
        << simulation_configuration.cooling_rate << ","
        << simulation_configuration.neighbor_step_size << ","
        << iteration << ","
        << fitness_evaluations << ","
        << best_loss << ","
        << best_area << ","
        << best_penalized_error << ","
        << best_raw_error << ","
        << get_total_bits(best_config) << ","
        << get_average_bits(best_config) << ","
        << get_max_bits(best_config)
        << "\n";
}

unsigned int experiment_logger::get_total_bits(
    const std::vector<fixed_point_format>& config) const
{
    unsigned int total = 0;

    for (const fixed_point_format& fpf : config)
    {
        total += 1 + fpf.whole_bits + fpf.frac_bits;
    }

    return total;
}

float experiment_logger::get_average_bits(
    const std::vector<fixed_point_format>& config) const
{
    if (config.empty())
    {
        return 0.0f;
    }

    return static_cast<float>(get_total_bits(config)) /
        static_cast<float>(config.size());
}

unsigned int experiment_logger::get_max_bits(
    const std::vector<fixed_point_format>& config) const
{
    unsigned int max_bits = 0;

    for (const fixed_point_format& fpf : config)
    {
        unsigned int bits =
            1 + fpf.whole_bits + fpf.frac_bits;

        if (bits > max_bits)
        {
            max_bits = bits;
        }
    }

    return max_bits;
}