#include "circuits/circuit_common.hpp"

#include <string>
#include <iostream>
#include <vector>
#include <random>

#include "circuits/circuit_registry.hpp"
#include "utils.hpp"
#include "loss.hpp"

void print_block(
    const std::string& block_name,
    const fixed_point_format& format)
{
    std::cout << block_name
        << " : whole_bits = " << format.whole_bits
        << ", frac_bits = " << format.frac_bits
        << ", total_bits = " << 1 + format.whole_bits + format.frac_bits
        << "\n";
}

void print_circuit_stats(
    const std::vector<fixed_point_format>& block_formats,
    const sim_config& simulation_configuration)
{
    std::mt19937 rng(std::random_device{}());

    loss_result result =
        evaluate_loss(block_formats, simulation_configuration, rng);

    std::cout << "LOSS = " << result.loss
        << "   AREA = " << result.area
        << "   RAW_ERROR = " << result.raw_error
        << "   PENALIZED_ERROR = " << result.penalized_error
        << "\n";
}

signal_pair add(
    const signal_pair in1,
    const signal_pair in2,
    const fixed_point_format& format)
{
    float in1_fp = float_to_fixed_point(in1.fp_value, format);
    float in2_fp = float_to_fixed_point(in2.fp_value, format);

    float out_fp = in1_fp + in2_fp;
    float out_gold = in1.gold_value + in2.gold_value;

    signal_pair out;
    out.fp_value = out_fp;
    out.gold_value = out_gold;

    return out;
}

signal_pair mul(
    const signal_pair in1,
    const signal_pair in2,
    const fixed_point_format& format)
{
    float in1_fp = float_to_fixed_point(in1.fp_value, format);
    float in2_fp = float_to_fixed_point(in2.fp_value, format);

    float out_fp = in1_fp * in2_fp;
    float out_gold = in1.gold_value * in2.gold_value;

    signal_pair out;
    out.fp_value = out_fp;
    out.gold_value = out_gold;

    return out;
}