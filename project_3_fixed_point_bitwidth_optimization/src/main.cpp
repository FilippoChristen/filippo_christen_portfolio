#include <algorithm>
#include <iostream>
#include <thread>

#include "experiments/experiment_baseline.hpp"
#include "experiments/experiment_ga_sweeps.hpp"
#include "experiments/experiment_sa_sweeps.hpp"


unsigned int get_recommended_worker_count()
{
    unsigned int total_threads = std::thread::hardware_concurrency();

    if (total_threads == 0)
    {
        total_threads = 4;
    }

    // Use roughly physical cores
    unsigned int worker_count = std::max(1u, total_threads / 2);

    return worker_count;
}


int main()
{
    unsigned int worker_count = get_recommended_worker_count();

    std::cout << "========================================\n";
    std::cout << "Detected hardware threads: " << std::thread::hardware_concurrency() << "\n";
    std::cout << "Using worker threads: " << worker_count << "\n";
    std::cout << "========================================\n\n";

    // Runs optimization on baseline configuration for SA and GA
    experiment_baseline(worker_count);

    // Runs GA optimization for several meta-parametrizations
    experiment_ga_sweeps(worker_count);

    // Runs SA optimization for several meta-parametrizations 
    experiment_sa_sweeps(worker_count);

    return 0;
}