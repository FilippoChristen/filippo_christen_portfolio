#include "loss.hpp"

#include <cmath>
#include <random>
#include <vector>

#include "utils.hpp"
#include "circuits/circuit_registry.hpp"

loss_result evaluate_loss(
    const std::vector<fixed_point_format>& block_formats,
    const sim_config& simulation_configuration,
    std::mt19937& rng)
{
    loss_result result;

    const float eps = 1e-6f;
    const float penalty_factor = 100000.0f;

    std::vector<float> inputs(get_circuit_input_num(simulation_configuration), 0.0f);

    for (unsigned int i = 0; i < simulation_configuration.data_num; i++)
    {
        for (float& in : inputs)
        {
            in = get_rand_float_2dp(
                simulation_configuration.min_input,
                simulation_configuration.max_input,
                rng);
        }

        signal_pair out = circuit(inputs, block_formats, simulation_configuration);

        float rel_err =
            std::abs(out.fp_value - out.gold_value) /
            (std::abs(out.gold_value) + eps);

        result.raw_error += rel_err;

        if (rel_err > simulation_configuration.toll)
        {
            result.penalized_error += penalty_factor * rel_err;
        }
        else
        {
            result.penalized_error += rel_err;
        }
    }

    // Normalize to Monte Carlo sample count
    result.raw_error /= static_cast<float>(simulation_configuration.data_num);
    result.penalized_error /= static_cast<float>(simulation_configuration.data_num);

    result.area = get_circuit_area(block_formats, simulation_configuration);
    result.loss = result.area + result.penalized_error;

    return result;
}

float get_rand_float_2dp(
    float a,
    float b,
    std::mt19937& rng)
{
    int ai = static_cast<int>(a * 100);
    int bi = static_cast<int>(b * 100);

    std::uniform_int_distribution<int> dist(ai, bi);

    return static_cast<float>(dist(rng)) / 100.0f;
}
