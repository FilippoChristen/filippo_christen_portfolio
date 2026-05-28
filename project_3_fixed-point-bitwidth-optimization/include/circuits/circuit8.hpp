#pragma once
#include <vector>
#include "utils.hpp"

signal_pair circuit8(const std::vector<float>& inputs, const std::vector<fixed_point_format>& block_formats);
void print_circuit8_config(const std::vector<fixed_point_format>& block_formats);
float get_circuit8_area(const std::vector<fixed_point_format>& block_formats);
unsigned int get_circuit8_input_num();
unsigned int get_circuit8_op_num();