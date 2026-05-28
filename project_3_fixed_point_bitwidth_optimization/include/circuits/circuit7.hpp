#pragma once
#include <vector>
#include "utils.hpp"

signal_pair circuit7(const std::vector<float>& inputs, const std::vector<fixed_point_format>& block_formats);
void print_circuit7_config(const std::vector<fixed_point_format>& block_formats);
float get_circuit7_area(const std::vector<fixed_point_format>& block_formats);
unsigned int get_circuit7_input_num();
unsigned int get_circuit7_op_num();