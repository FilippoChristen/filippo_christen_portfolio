#pragma once
#include <vector>
#include "utils.hpp"

signal_pair circuit3(const std::vector<float>& inputs, const std::vector<fixed_point_format>& block_formats);
void print_circuit3_config(const std::vector<fixed_point_format>& block_formats);
float get_circuit3_area(const std::vector<fixed_point_format>& block_formats);
unsigned int get_circuit3_input_num();
unsigned int get_circuit3_op_num();