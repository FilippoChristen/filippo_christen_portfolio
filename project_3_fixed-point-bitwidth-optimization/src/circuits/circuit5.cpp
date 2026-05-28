#include "circuits/circuit5.hpp"
#include "circuits/circuit_common.hpp"

signal_pair circuit5(const std::vector<float>& inputs, const std::vector<fixed_point_format>& block_formats)
{
    signal_pair in1{ inputs[0], inputs[0] };
    signal_pair in2{ inputs[1], inputs[1] };
    signal_pair in3{ inputs[2], inputs[2] };
    signal_pair in4{ inputs[3], inputs[3] };

    signal_pair c1{ inputs[4], inputs[4] };
    signal_pair c2{ inputs[5], inputs[5] };
    signal_pair c3{ inputs[6], inputs[6] };
    signal_pair c4{ inputs[7], inputs[7] };

    signal_pair mul1 = mul(c1, in1, block_formats[0]);
    signal_pair mul2 = mul(c2, in2, block_formats[1]);
    signal_pair mul3 = mul(c3, in3, block_formats[2]);
    signal_pair mul4 = mul(c4, in4, block_formats[3]);

    signal_pair add1 = add(mul1, mul2, block_formats[4]);
    signal_pair add2 = add(mul3, mul4, block_formats[5]);
    signal_pair out = add(add1, add2, block_formats[6]);

    return out;
}

void print_circuit5_config(const std::vector<fixed_point_format>& block_formats)
{
    print_block("mul1", block_formats[0]);
    print_block("mul2", block_formats[1]);
    print_block("mul3", block_formats[2]);
    print_block("mul4", block_formats[3]);
    print_block("add1", block_formats[4]);
    print_block("add2", block_formats[5]);
    print_block("add3", block_formats[6]);
}

float get_circuit5_area(const std::vector<fixed_point_format>& block_formats)
{
    float area = 0.0f;

    for (int i = 0; i < 4; i++)
    {
        float bits = block_formats[i].whole_bits + block_formats[i].frac_bits;
        area += bits * bits;
    }

    for (int i = 4; i < 7; i++)
    {
        area += block_formats[i].whole_bits + block_formats[i].frac_bits;
    }

    return area;
}

unsigned int get_circuit5_input_num() { return 8; }
unsigned int get_circuit5_op_num() { return 7; }