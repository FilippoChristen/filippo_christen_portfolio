#pragma once
#include <vector>
#include "utils.hpp"

signal_pair circuit4(const std::vector<float>& inputs, const std::vector<fixed_point_format>& block_formats);
void print_circuit4_config(const std::vector<fixed_point_format>& block_formats);
float get_circuit4_area(const std::vector<fixed_point_format>& block_formats);
unsigned int get_circuit4_input_num();
unsigned int get_circuit4_op_num();