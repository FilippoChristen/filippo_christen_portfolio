#pragma once

#include <cstddef>
#include <random>

struct fixed_point_format
{
    unsigned int whole_bits = 0;    // bits for whole-number part
    unsigned int frac_bits = 0;     // bits for fractional part
};

struct signal_pair
{
    float fp_value = 0.0f;
    float gold_value = 0.0f;
};

struct sim_config
{
    unsigned int circuit_id;

    float toll;
    unsigned int data_num;
    float min_input;
    float max_input;
    unsigned int max_it;

    // GA parameters
    unsigned int population_size;
    float mutation_prob;
    unsigned int mutation_quantity;
    unsigned int tournament_size;
    unsigned int elite_count;

    // SA parameters
    float initial_temperature_factor;
    float cooling_rate;
    unsigned int neighbor_step_size;
};

// Converts a float to the nearest value representable in the given fixed-point format.
// Saturates if the input is outside the representable range.
float float_to_fixed_point(float value, const fixed_point_format& format);

// Converts back to float.
float fixed_point_to_float(float value);

unsigned int random_uint(
    std::mt19937& rng,
    unsigned int min_value,
    unsigned int max_value);

size_t random_index(
    std::mt19937& rng,
    size_t upper_exclusive);

float random_float_01(
    std::mt19937& rng);
