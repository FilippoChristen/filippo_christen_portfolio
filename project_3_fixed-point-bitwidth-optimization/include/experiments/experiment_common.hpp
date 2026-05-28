#pragma once

#include <string>
#include <vector>

#include "utils.hpp"

sim_config get_base_sim_config();

unsigned int get_first_circuit_id();
unsigned int get_last_circuit_id();
unsigned int get_run_count();

unsigned int get_sa_iterations_for_equal_budget(
    const sim_config& config);

unsigned int make_experiment_seed(
    unsigned int circuit_id,
    unsigned int run_id,
    unsigned int algorithm_id,
    const std::string& sweep_parameter,
    float sweep_value);

std::string create_temp_experiment_folder(
    const std::string& experiment_name);

std::string make_result_csv_path(
    const std::string& file_name);

void merge_csv_files(
    const std::vector<std::string>& input_files,
    const std::string& output_file);

void delete_folder_recursive(
    const std::string& folder_path);
