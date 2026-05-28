#pragma once
#include <vector>
#include "utils.hpp"

signal_pair circuit2(const std::vector<float>& inputs, const std::vector<fixed_point_format>& block_formats);
void print_circuit2_config(const std::vector<fixed_point_format>& block_formats);
float get_circuit2_area(const std::vector<fixed_point_format>& block_formats);
unsigned int get_circuit2_input_num();
unsigned int get_circuit2_op_num();