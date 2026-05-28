#include "circuits/circuit1.hpp"

#include <vector>
#include <iostream>

#include "circuits/circuit_common.hpp"
#include "utils.hpp"

// Adder tree
signal_pair circuit1(
    const std::vector<float>& inputs,
    const std::vector<fixed_point_format>& block_formats)
{
    // Circuit characteristics
    unsigned int input_num = 4;
    unsigned int op_num = 3;

    // Check sizes
    if (inputs.size() != input_num)
    {
        std::cerr << "Wrong input size. Required input size: "
            << input_num
            << " Provided input size: "
            << inputs.size()
            << "\n";
    }

    if (block_formats.size() != op_num)
    {
        std::cerr << "Wrong formats vector size. Required formats vector size: "
            << op_num
            << " Provided formats vector size: "
            << block_formats.size()
            << "\n";
    }

    // Rename formats
    fixed_point_format add1_format = block_formats[0];
    fixed_point_format add2_format = block_formats[1];
    fixed_point_format add3_format = block_formats[2];

    // Inputs
    signal_pair in1{ inputs[0], inputs[0] };
    signal_pair in2{ inputs[1], inputs[1] };
    signal_pair in3{ inputs[2], inputs[2] };
    signal_pair in4{ inputs[3], inputs[3] };

    // Circuit
    signal_pair add1 = add(in1, in2, add1_format);

    signal_pair add2 = add(in3, in4, add2_format);

    signal_pair out = add(add1, add2, add3_format);

    return out;
}

void print_circuit1_config(
    const std::vector<fixed_point_format>& block_formats)
{
    std::cout << "=== circuit1 config ===\n";

    print_block("add1", block_formats[0]);
    print_block("add2", block_formats[1]);
    print_block("add3", block_formats[2]);
}

float get_circuit1_area(
    const std::vector<fixed_point_format>& block_formats)
{
    float area = 0.0f;

    area += block_formats[0].whole_bits
        + block_formats[0].frac_bits;

    area += block_formats[1].whole_bits
        + block_formats[1].frac_bits;

    area += block_formats[2].whole_bits
        + block_formats[2].frac_bits;

    return area;
}

unsigned int get_circuit1_input_num()
{
    return 4;
}

unsigned int get_circuit1_op_num()
{
    return 3;
}