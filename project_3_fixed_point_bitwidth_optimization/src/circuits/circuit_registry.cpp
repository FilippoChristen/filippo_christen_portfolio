#include "circuits/circuit_registry.hpp"

#include <iostream>
#include <stdexcept>

#include "circuits/circuit1.hpp"
#include "circuits/circuit2.hpp"
#include "circuits/circuit3.hpp"
#include "circuits/circuit4.hpp"
#include "circuits/circuit5.hpp"
#include "circuits/circuit6.hpp"
#include "circuits/circuit7.hpp"
#include "circuits/circuit8.hpp"

const circuit_info& get_circuit_info(unsigned int circuit_id)
{
    static const std::vector<circuit_info> circuits = {
        {
            1,
            "adder_tree",
            circuit1,
            print_circuit1_config,
            get_circuit1_area,
            get_circuit1_input_num,
            get_circuit1_op_num
        },
        {
            2,
            "multiplier_chain",
            circuit2,
            print_circuit2_config,
            get_circuit2_area,
            get_circuit2_input_num,
            get_circuit2_op_num
        },
        {
            3,
            "mac_chain",
            circuit3,
            print_circuit3_config,
            get_circuit3_area,
            get_circuit3_input_num,
            get_circuit3_op_num
        },
        {
            4,
            "polynomial",
            circuit4,
            print_circuit4_config,
            get_circuit4_area,
            get_circuit4_input_num,
            get_circuit4_op_num
        },
        {
            5,
            "fir_like",
            circuit5,
            print_circuit5_config,
            get_circuit5_area,
            get_circuit5_input_num,
            get_circuit5_op_num
        },
        {
            6,
            "deep_mixed_dag",
            circuit6,
            print_circuit6_config,
            get_circuit6_area,
            get_circuit6_input_num,
            get_circuit6_op_num
        },
        {
            7,
            "balanced_tree",
            circuit7,
            print_circuit7_config,
            get_circuit7_area,
            get_circuit7_input_num,
            get_circuit7_op_num
        },
        {
            8,
            "unbalanced_chain",
            circuit8,
            print_circuit8_config,
            get_circuit8_area,
            get_circuit8_input_num,
            get_circuit8_op_num
        }
    };

    for (const circuit_info& info : circuits)
    {
        if (info.id == circuit_id)
        {
            return info;
        }
    }

    throw std::runtime_error("Invalid circuit id");
}

signal_pair circuit(
    const std::vector<float>& inputs,
    const std::vector<fixed_point_format>& block_formats,
    const sim_config& simulation_configuration)
{
    const circuit_info& info = get_circuit_info(simulation_configuration.circuit_id);
    return info.circuit_fn(inputs, block_formats);
}

void print_circuit_config(
    const std::vector<fixed_point_format>& block_formats,
    const sim_config& simulation_configuration)
{
    const circuit_info& info = get_circuit_info(simulation_configuration.circuit_id);
    info.print_fn(block_formats);
}

float get_circuit_area(
    const std::vector<fixed_point_format>& block_formats,
    const sim_config& simulation_configuration)
{
    const circuit_info& info = get_circuit_info(simulation_configuration.circuit_id);
    return info.area_fn(block_formats);
}

unsigned int get_circuit_input_num(
    const sim_config& simulation_configuration)
{
    const circuit_info& info = get_circuit_info(simulation_configuration.circuit_id);
    return info.input_num_fn();
}

unsigned int get_circuit_op_num(
    const sim_config& simulation_configuration)
{
    const circuit_info& info = get_circuit_info(simulation_configuration.circuit_id);
    return info.op_num_fn();
}