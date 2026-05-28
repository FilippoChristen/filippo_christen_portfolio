#include "circuits/circuit3.hpp"
#include "circuits/circuit_common.hpp"

signal_pair circuit3(const std::vector<float>& inputs, const std::vector<fixed_point_format>& block_formats)
{
    signal_pair in1{ inputs[0], inputs[0] };
    signal_pair in2{ inputs[1], inputs[1] };
    signal_pair in3{ inputs[2], inputs[2] };
    signal_pair in4{ inputs[3], inputs[3] };
    signal_pair in5{ inputs[4], inputs[4] };
    signal_pair in6{ inputs[5], inputs[5] };

    signal_pair mul1 = mul(in1, in2, block_formats[0]);
    signal_pair mul2 = mul(in3, in4, block_formats[1]);
    signal_pair mul3 = mul(in5, in6, block_formats[2]);

    signal_pair add1 = add(mul1, mul2, block_formats[3]);
    signal_pair out = add(add1, mul3, block_formats[4]);

    return out;
}

void print_circuit3_config(const std::vector<fixed_point_format>& block_formats)
{
    print_block("mul1", block_formats[0]);
    print_block("mul2", block_formats[1]);
    print_block("mul3", block_formats[2]);
    print_block("add1", block_formats[3]);
    print_block("add2", block_formats[4]);
}

float get_circuit3_area(const std::vector<fixed_point_format>& block_formats)
{
    float area = 0.0f;

    for (int i = 0; i < 3; i++)
    {
        float bits = block_formats[i].whole_bits + block_formats[i].frac_bits;
        area += bits * bits;
    }

    for (int i = 3; i < 5; i++)
    {
        area += block_formats[i].whole_bits + block_formats[i].frac_bits;
    }

    return area;
}

unsigned int get_circuit3_input_num() { return 6; }
unsigned int get_circuit3_op_num() { return 5; }