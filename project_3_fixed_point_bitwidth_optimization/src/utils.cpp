#include "utils.hpp"

#include <cmath>
#include <random>

float float_to_fixed_point(float input_value, const fixed_point_format& format)
{
    float scale_factor = std::pow(2.0f, static_cast<float>(format.frac_bits));

    // 2's complement signed fixed-point range:
    // min = -2^whole_bits
    // max =  2^whole_bits - 2^(-fractional_bits)
    // Note: sign bit is not considered
    float min_value = -std::pow(2.0f, static_cast<float>(format.whole_bits));
    float max_value = std::pow(2.0f, static_cast<float>(format.whole_bits)) - (1.0f / scale_factor);

    // Saturate
    if (input_value < min_value)
    {
        input_value = min_value;
    }
    else if (input_value > max_value)
    {
        input_value = max_value;
    }

    float quantized_value = std::floor(input_value * scale_factor) / scale_factor;

    return quantized_value;
}

float fixed_point_to_float(float fixed_point_value)
{
    // In this simple model, the quantized fixed-point value is already stored as a float.
    return fixed_point_value;
}

unsigned int random_uint(
    std::mt19937& rng,
    unsigned int min_value,
    unsigned int max_value)
{
    std::uniform_int_distribution<unsigned int> dist(min_value, max_value);
    return dist(rng);
}

size_t random_index(
    std::mt19937& rng,
    size_t upper_exclusive)
{
    std::uniform_int_distribution<size_t> dist(0, upper_exclusive - 1);
    return dist(rng);
}

float random_float_01(
    std::mt19937& rng)
{
    std::uniform_real_distribution<float> dist(0.0f, 1.0f);
    return dist(rng);
}
