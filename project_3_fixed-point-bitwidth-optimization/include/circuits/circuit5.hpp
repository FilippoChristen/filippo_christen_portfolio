#pragma once
#include <vector>
#include "utils.hpp"

signal_pair circuit5(const std::vector<float>& inputs, const std::vector<fixed_point_format>& block_formats);
void print_circuit5_config(const std::vector<fixed_point_format>& block_formats);
float get_circuit5_area(const std::vector<fixed_point_format>& block_formats);
unsigned int get_circuit5_input_num();
unsigned int get_circuit5_op_num();