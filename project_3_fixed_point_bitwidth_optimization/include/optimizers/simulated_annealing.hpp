#pragma once

#include <random>
#include <vector>

#include "utils.hpp"
#include "experiments/experiment_logger.hpp"

void simulated_annealing(
    std::vector<fixed_point_format>& block_formats,
    const sim_config& simulation_configuration,
    experiment_logger* logger,
    unsigned int run_id,
    std::mt19937& rng);
