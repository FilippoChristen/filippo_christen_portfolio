#pragma once

#include <vector>
#include <string>
#include "utils.hpp"

struct circuit_info
{
    unsigned int id;
    std::string name;

    signal_pair(*circuit_fn)(
        const std::vector<float>&,
        const std::vector<fixed_point_format>&);

    void (*print_fn)(
        const std::vector<fixed_point_format>&);

    float (*area_fn)(
        const std::vector<fixed_point_format>&);

    unsigned int (*input_num_fn)();
    unsigned int (*op_num_fn)();
};

const circuit_info& get_circuit_info(unsigned int circuit_id);

signal_pair circuit(
    const std::vector<float>& inputs,
    const std::vector<fixed_point_format>& block_formats,
    const sim_config& simulation_configuration);

void print_circuit_config(
    const std::vector<fixed_point_format>& block_formats,
    const sim_config& simulation_configuration);

float get_circuit_area(
    const std::vector<fixed_point_format>& block_formats,
    const sim_config& simulation_configuration);

unsigned int get_circuit_input_num(
    const sim_config& simulation_configuration);

unsigned int get_circuit_op_num(
    const sim_config& simulation_configuration);