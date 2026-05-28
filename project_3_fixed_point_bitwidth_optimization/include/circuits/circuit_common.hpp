#pragma once

#include <vector>
#include <string>
#include "utils.hpp"

void print_block(const std::string& block_name, const fixed_point_format& format);

void print_circuit_stats(
    const std::vector<fixed_point_format>& block_formats,
    const sim_config& simulation_configuration);

signal_pair add(
    signal_pair in1,
    signal_pair in2,
    const fixed_point_format& format);

signal_pair mul(
    signal_pair in1,
    signal_pair in2,
    const fixed_point_format& format);