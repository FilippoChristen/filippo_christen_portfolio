#include "circuits/circuit4.hpp"
#include "circuits/circuit_common.hpp"

signal_pair circuit4(const std::vector<float>& inputs, const std::vector<fixed_point_format>& block_formats)
{
    signal_pair x{ inputs[0], inputs[0] };
    signal_pair a{ inputs[1], inputs[1] };
    signal_pair b{ inputs[2], inputs[2] };
    signal_pair c{ inputs[3], inputs[3] };
    signal_pair d{ inputs[4], inputs[4] };

    signal_pair x2 = mul(x, x, block_formats[0]);
    signal_pair x3 = mul(x2, x, block_formats[1]);

    signal_pair ax3 = mul(a, x3, block_formats[2]);
    signal_pair bx2 = mul(b, x2, block_formats[3]);
    signal_pair cx = mul(c, x, block_formats[4]);

    signal_pair add1 = add(ax3, bx2, block_formats[5]);
    signal_pair add2 = add(add1, cx, block_formats[6]);
    signal_pair out = add(add2, d, block_formats[7]);

    return out;
}

void print_circuit4_config(const std::vector<fixed_point_format>& block_formats)
{
    print_block("x2", block_formats[0]);
    print_block("x3", block_formats[1]);
    print_block("ax3", block_formats[2]);
    print_block("bx2", block_formats[3]);
    print_block("cx", block_formats[4]);
    print_block("add1", block_formats[5]);
    print_block("add2", block_formats[6]);
    print_block("add3", block_formats[7]);
}

float get_circuit4_area(const std::vector<fixed_point_format>& block_formats)
{
    float area = 0.0f;

    for (int i = 0; i < 5; i++)
    {
        float bits = block_formats[i].whole_bits + block_formats[i].frac_bits;
        area += bits * bits;
    }

    for (int i = 5; i < 8; i++)
    {
        area += block_formats[i].whole_bits + block_formats[i].frac_bits;
    }

    return area;
}

unsigned int get_circuit4_input_num() { return 5; }
unsigned int get_circuit4_op_num() { return 8; }