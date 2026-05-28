#pragma once
#include <vector>
#include "utils.hpp"

signal_pair circuit6(const std::vector<float>& inputs, const std::vector<fixed_point_format>& block_formats);
void print_circuit6_config(const std::vector<fixed_point_format>& block_formats);
float get_circuit6_area(const std::vector<fixed_point_format>& block_formats);
unsigned int get_circuit6_input_num();
unsigned int get_circuit6_op_num();