#pragma once

#include <random>
#include <vector>

#include "utils.hpp"

struct loss_result
{
    float loss = 0.0f;
    float area = 0.0f;
    float raw_error = 0.0f;
    float penalized_error = 0.0f;
};

loss_result evaluate_loss(
    const std::vector<fixed_point_format>& block_formats,
    const sim_config& simulation_configuration,
    std::mt19937& rng);

float get_rand_float_2dp(
    float a,
    float b,
    std::mt19937& rng);
