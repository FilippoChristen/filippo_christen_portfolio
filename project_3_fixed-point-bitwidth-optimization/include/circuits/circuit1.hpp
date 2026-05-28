#pragma once

#include <vector>
#include "utils.hpp"

// Adder tree
signal_pair circuit1(
    const std::vector<float>& inputs,
    const std::vector<fixed_point_format>& block_formats);

void print_circuit1_config(
    const std::vector<fixed_point_format>& block_formats);

float get_circuit1_area(
    const std::vector<fixed_point_format>& block_formats);

unsigned int get_circuit1_input_num();

unsigned int get_circuit1_op_num();