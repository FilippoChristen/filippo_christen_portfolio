#include "circuits/circuit6.hpp"
#include "circuits/circuit_common.hpp"

signal_pair circuit6(const std::vector<float>& inputs, const std::vector<fixed_point_format>& block_formats)
{
    signal_pair in1{ inputs[0], inputs[0] };
    signal_pair in2{ inputs[1], inputs[1] };
    signal_pair in3{ inputs[2], inputs[2] };
    signal_pair in4{ inputs[3], inputs[3] };
    signal_pair in5{ inputs[4], inputs[4] };
    signal_pair in6{ inputs[5], inputs[5] };

    signal_pair add1 = add(in1, in2, block_formats[0]);
    signal_pair mul1 = mul(add1, in3, block_formats[1]);
    signal_pair add2 = add(mul1, in4, block_formats[2]);
    signal_pair add3 = add(in5, in6, block_formats[3]);
    signal_pair out = mul(add2, add3, block_formats[4]);

    return out;
}

void print_circuit6_config(const std::vector<fixed_point_format>& block_formats)
{
    print_block("add1", block_formats[0]);
    print_block("mul1", block_formats[1]);
    print_block("add2", block_formats[2]);
    print_block("add3", block_formats[3]);
    print_block("mul2", block_formats[4]);
}

float get_circuit6_area(const std::vector<fixed_point_format>& block_formats)
{
    float area = 0.0f;

    area += block_formats[0].whole_bits + block_formats[0].frac_bits;

    float bits1 = block_formats[1].whole_bits + block_formats[1].frac_bits;
    area += bits1 * bits1;

    area += block_formats[2].whole_bits + block_formats[2].frac_bits;
    area += block_formats[3].whole_bits + block_formats[3].frac_bits;

    float bits4 = block_formats[4].whole_bits + block_formats[4].frac_bits;
    area += bits4 * bits4;

    return area;
}

unsigned int get_circuit6_input_num() { return 6; }
unsigned int get_circuit6_op_num() { return 5; }