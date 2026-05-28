#include "optimizers/genetic_algorithm.hpp"

#include <algorithm>
#include <random>
#include <vector>

#include "experiments/experiment_logger.hpp"
#include "loss.hpp"
#include "utils.hpp"

namespace
{
    struct individual
    {
        std::vector<fixed_point_format> config;

        float loss = 0.0f;
        float area = 0.0f;
        float raw_error = 0.0f;
        float penalized_error = 0.0f;
    };

    void evaluate_individual(
        individual& ind,
        const sim_config& simulation_configuration,
        unsigned int& fitness_evaluations,
        std::mt19937& rng)
    {
        loss_result result =
            evaluate_loss(
                ind.config,
                simulation_configuration,
                rng);

        ind.loss = result.loss;
        ind.area = result.area;
        ind.raw_error = result.raw_error;
        ind.penalized_error = result.penalized_error;

        fitness_evaluations++;
    }

    const individual& tournament_select(
        const std::vector<individual>& generation,
        unsigned int tournament_size,
        std::mt19937& rng)
    {
        if (tournament_size == 0)
        {
            tournament_size = 1;
        }

        size_t best_idx =
            random_index(rng, generation.size());

        for (unsigned int i = 1; i < tournament_size; i++)
        {
            size_t candidate_idx =
                random_index(rng, generation.size());

            if (generation[candidate_idx].loss < generation[best_idx].loss)
            {
                best_idx = candidate_idx;
            }
        }

        return generation[best_idx];
    }

    unsigned int mutate_bit_width(
        unsigned int value,
        unsigned int mutation_quantity,
        std::mt19937& rng)
    {
        int q = static_cast<int>(mutation_quantity);

        if (q <= 0)
        {
            return value;
        }

        std::uniform_int_distribution<int> dist(-q, q);
        int mut_amount = dist(rng);
        int new_value = static_cast<int>(value) + mut_amount;

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

    individual crossover(
        const individual& parent1,
        const individual& parent2,
        const sim_config& simulation_configuration,
        unsigned int& fitness_evaluations,
        std::mt19937& rng)
    {
        individual child;
        child.config = parent1.config;

        for (size_t i = 0; i < parent1.config.size(); i++)
        {
            if (random_uint(rng, 0, 1) == 0)
            {
                child.config[i].whole_bits = parent1.config[i].whole_bits;
            }
            else
            {
                child.config[i].whole_bits = parent2.config[i].whole_bits;
            }

            if (random_uint(rng, 0, 1) == 0)
            {
                child.config[i].frac_bits = parent1.config[i].frac_bits;
            }
            else
            {
                child.config[i].frac_bits = parent2.config[i].frac_bits;
            }

            float mutation_random = random_float_01(rng);

            if (mutation_random < simulation_configuration.mutation_prob)
            {
                unsigned int mutation_type = random_uint(rng, 0, 2);

                if (mutation_type == 0)
                {
                    child.config[i].whole_bits =
                        mutate_bit_width(
                            child.config[i].whole_bits,
                            simulation_configuration.mutation_quantity,
                            rng);
                }
                else if (mutation_type == 1)
                {
                    child.config[i].frac_bits =
                        mutate_bit_width(
                            child.config[i].frac_bits,
                            simulation_configuration.mutation_quantity,
                            rng);
                }
                else
                {
                    child.config[i].whole_bits =
                        mutate_bit_width(
                            child.config[i].whole_bits,
                            simulation_configuration.mutation_quantity,
                            rng);

                    child.config[i].frac_bits =
                        mutate_bit_width(
                            child.config[i].frac_bits,
                            simulation_configuration.mutation_quantity,
                            rng);
                }
            }
        }

        evaluate_individual(
            child,
            simulation_configuration,
            fitness_evaluations,
            rng);

        return child;
    }
}

void genetic_algorithm(
    std::vector<fixed_point_format>& block_formats,
    const sim_config& simulation_configuration,
    experiment_logger* logger,
    unsigned int run_id,
    std::mt19937& rng)
{
    unsigned int trials = simulation_configuration.max_it;
    unsigned int population_size = simulation_configuration.population_size;
    unsigned int fitness_evaluations = 0;

    std::vector<individual> curr_generation;
    std::vector<individual> next_generation;

    curr_generation.reserve(population_size);
    next_generation.reserve(population_size);

    for (unsigned int i = 0; i < population_size; i++)
    {
        individual curr_individual;
        curr_individual.config = block_formats;

        for (fixed_point_format& fpf : curr_individual.config)
        {
            fpf.whole_bits = random_uint(rng, 0, 64);
            fpf.frac_bits = random_uint(rng, 0, 64);
        }

        evaluate_individual(
            curr_individual,
            simulation_configuration,
            fitness_evaluations,
            rng);

        curr_generation.push_back(curr_individual);
    }

    next_generation = curr_generation;

    std::sort(
        curr_generation.begin(),
        curr_generation.end(),
        [](const individual& a, const individual& b)
        {
            return a.loss < b.loss;
        });

    individual best_individual = curr_generation[0];

    if (logger != nullptr)
    {
        logger->log(
            "genetic_algorithm",
            simulation_configuration,
            run_id,
            0,
            fitness_evaluations,
            best_individual.loss,
            best_individual.area,
            best_individual.penalized_error,
            best_individual.raw_error,
            best_individual.config);
    }

    for (unsigned int i = 1; i <= trials; i++)
    {
        unsigned int elite_count = simulation_configuration.elite_count;

        if (elite_count > population_size)
        {
            elite_count = population_size;
        }

        // Elitism
        for (unsigned int j = 0; j < elite_count; j++)
        {
            next_generation[j] = curr_generation[j];
        }

        for (unsigned int j = elite_count; j < next_generation.size(); j++)
        {
            const individual& parent1 =
                tournament_select(
                    curr_generation,
                    simulation_configuration.tournament_size,
                    rng);

            const individual& parent2 =
                tournament_select(
                    curr_generation,
                    simulation_configuration.tournament_size,
                    rng);

            next_generation[j] =
                crossover(
                    parent1,
                    parent2,
                    simulation_configuration,
                    fitness_evaluations,
                    rng);
        }

        curr_generation = next_generation;

        std::sort(
            curr_generation.begin(),
            curr_generation.end(),
            [](const individual& a, const individual& b)
            {
                return a.loss < b.loss;
            });

        if (curr_generation[0].loss < best_individual.loss)
        {
            best_individual = curr_generation[0];
        }

        if (logger != nullptr)
        {
            logger->log(
                "genetic_algorithm",
                simulation_configuration,
                run_id,
                i,
                fitness_evaluations,
                best_individual.loss,
                best_individual.area,
                best_individual.penalized_error,
                best_individual.raw_error,
                best_individual.config);
        }
    }

    block_formats = best_individual.config;
}
