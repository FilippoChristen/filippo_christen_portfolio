#include "optimizers/simulated_annealing.hpp"

#include <cmath>
#include <random>
#include <vector>

#include "experiments/experiment_logger.hpp"
#include "loss.hpp"
#include "utils.hpp"

namespace
{
    unsigned int perturb_bit_width(
        unsigned int value,
        int delta)
    {
        int new_value = static_cast<int>(value) + delta;

        if (new_value < 0)
        {
            new_value = 0;
        }

        if (new_value > 64)
        {
            new_value = 64;
        }

        return static_cast<unsigned int>(new_value);
    }

    unsigned int get_sa_log_interval(
        const sim_config& simulation_configuration)
    {
        if (simulation_configuration.population_size <= simulation_configuration.elite_count)
        {
            return 1;
        }

        return simulation_configuration.population_size - simulation_configuration.elite_count;
    }
}

void simulated_annealing(
    std::vector<fixed_point_format>& block_formats,
    const sim_config& simulation_configuration,
    experiment_logger* logger,
    unsigned int run_id,
    std::mt19937& rng)
{
    unsigned int trials = simulation_configuration.max_it;
    unsigned int fitness_evaluations = 0;

    std::vector<fixed_point_format> curr_config = block_formats;

    for (fixed_point_format& fpf : curr_config)
    {
        fpf.whole_bits = random_uint(rng, 0, 64);
        fpf.frac_bits = random_uint(rng, 0, 64);
    }

    std::vector<fixed_point_format> best_config = curr_config;

    loss_result curr_result =
        evaluate_loss(
            curr_config,
            simulation_configuration,
            rng);

    fitness_evaluations++;

    loss_result best_result = curr_result;

    if (logger != nullptr)
    {
        logger->log(
            "simulated_annealing",
            simulation_configuration,
            run_id,
            0,
            fitness_evaluations,
            best_result.loss,
            best_result.area,
            best_result.penalized_error,
            best_result.raw_error,
            best_config);
    }

    float T =
        simulation_configuration.initial_temperature_factor *
        static_cast<float>(trials);

    float cooling_rate = simulation_configuration.cooling_rate;
    unsigned int log_interval = get_sa_log_interval(simulation_configuration);

    for (unsigned int i = 1; i <= trials; i++)
    {
        std::vector<fixed_point_format> neighbor = curr_config;

        size_t rand_idx = random_index(rng, curr_config.size());
        unsigned int rand_block = random_uint(rng, 0, 1);

        int step_size = static_cast<int>(simulation_configuration.neighbor_step_size);

        if (step_size <= 0)
        {
            step_size = 1;
        }

        int delta = step_size;

        if (random_uint(rng, 0, 1) == 0)
        {
            delta = -step_size;
        }

        if (rand_block == 0)
        {
            neighbor[rand_idx].whole_bits =
                perturb_bit_width(
                    neighbor[rand_idx].whole_bits,
                    delta);
        }
        else
        {
            neighbor[rand_idx].frac_bits =
                perturb_bit_width(
                    neighbor[rand_idx].frac_bits,
                    delta);
        }

        loss_result neighbor_result =
            evaluate_loss(
                neighbor,
                simulation_configuration,
                rng);

        fitness_evaluations++;

        if (neighbor_result.loss < curr_result.loss)
        {
            curr_config = neighbor;
            curr_result = neighbor_result;
        }
        else
        {
            float exponent =
                (curr_result.loss - neighbor_result.loss) / T;

            float prob = std::exp(exponent);
            float random_value = random_float_01(rng);

            if (prob > random_value)
            {
                curr_config = neighbor;
                curr_result = neighbor_result;
            }
        }

        if (curr_result.loss < best_result.loss)
        {
            best_result = curr_result;
            best_config = curr_config;
        }

        // Ensures similar logging behavior between GA and SA.
        bool log_condition =
            (i % log_interval == 0) ||
            (i == trials);

        if (logger != nullptr && log_condition)
        {
            logger->log(
                "simulated_annealing",
                simulation_configuration,
                run_id,
                i,
                fitness_evaluations,
                best_result.loss,
                best_result.area,
                best_result.penalized_error,
                best_result.raw_error,
                best_config);
        }

        T *= cooling_rate;
    }

    block_formats = best_config;
}
