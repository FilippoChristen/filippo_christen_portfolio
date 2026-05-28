#include "circuits/circuit2.hpp"
#include "circuits/circuit_common.hpp"

signal_pair circuit2(const std::vector<float>& inputs, const std::vector<fixed_point_format>& block_formats)
{
    signal_pair in1{ inputs[0], inputs[0] };
    signal_pair in2{ inputs[1], inputs[1] };
    signal_pair in3{ inputs[2], inputs[2] };
    signal_pair in4{ inputs[3], inputs[3] };

    signal_pair mul1 = mul(in1, in2, block_formats[0]);
    signal_pair mul2 = mul(mul1, in3, block_formats[1]);
    signal_pair out = mul(mul2, in4, block_formats[2]);

    return out;
}

void print_circuit2_config(const std::vector<fixed_point_format>& block_formats)
{
    print_block("mul1", block_formats[0]);
    print_block("mul2", block_formats[1]);
    print_block("mul3", block_formats[2]);
}

float get_circuit2_area(const std::vector<fixed_point_format>& block_formats)
{
    float area = 0.0f;

    for (int i = 0; i < 3; i++)
    {
        float bits = block_formats[i].whole_bits + block_formats[i].frac_bits;
        area += bits * bits;
    }

    return area;
}

unsigned int get_circuit2_input_num() { return 4; }
unsigned int get_circuit2_op_num() { return 3; }