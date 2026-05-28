#pragma once

#include <fstream>
#include <string>
#include <vector>

#include "utils.hpp"

class experiment_logger
{
public:
    experiment_logger(
        const std::string& file_name,
        const std::string& experiment_name,
        bool timestamp_output_file);

    void set_sweep_info(
        const std::string& sweep_parameter,
        float sweep_value);

    void log(
        const std::string& algorithm_name,
        const sim_config& simulation_configuration,
        unsigned int run_id,
        unsigned int iteration,
        unsigned int fitness_evaluations,
        float best_loss,
        float best_area,
        float best_penalized_error,
        float best_raw_error,
        const std::vector<fixed_point_format>& best_config);

private:
    std::ofstream file;

    std::string experiment_name;
    std::string sweep_parameter = "none";
    float sweep_value = 0.0f;

    unsigned int get_total_bits(
        const std::vector<fixed_point_format>& config) const;

    float get_average_bits(
        const std::vector<fixed_point_format>& config) const;

    unsigned int get_max_bits(
        const std::vector<fixed_point_format>& config) const;
};
