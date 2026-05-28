# Fixed-Point Bitwidth Optimization in Arithmetic Circuits

## Overview
This project implements a C++ framework for optimizing fixed-point bitwidths in arithmetic combinational circuits.  
The objective is to minimize estimated hardware area while keeping the output error below a chosen tolerance.

Fixed-point arithmetic is attractive for digital hardware because it is simpler and cheaper than floating-point arithmetic, but selecting the number of integer and fractional bits for each operation block is difficult.  
The search space is discrete, quantization makes the objective non-smooth, and the best solution depends on the circuit topology.

The project models circuits as directed acyclic graphs of arithmetic blocks.  
Each adder or multiplier receives an independently optimized fixed-point format `QI.F`, where `I` is the number of integer bits and `F` is the number of fractional bits.

---

## Optimization Approach
Candidate bitwidth assignments are evaluated using Monte Carlo simulation:

- Random input samples are propagated through a quantized fixed-point circuit.
- The same inputs are propagated through a floating-point reference circuit.
- The relative output error is measured.
- A strong penalty is applied when the error exceeds the target tolerance.
- The final loss combines estimated hardware area and penalized numerical error.

Two derivative-free optimizers were implemented and compared:

- **Genetic Algorithm (GA):** population-based search with tournament selection, crossover, mutation, and elitism.
- **Simulated Annealing (SA):** local stochastic search with temperature-based acceptance of worse solutions.

---

## Key Contributions
- Formulated fixed-point bitwidth selection as a discrete optimization problem.
- Designed a loss function combining hardware-area estimation and numerical accuracy.
- Implemented genetic algorithm and simulated annealing optimizers in C++.
- Built a multithreaded experimentation flow for repeated optimizer runs and parameter sweeps.
- Logged optimization results to CSV and analyzed convergence, variability, and optimizer sensitivity.
- Showed that the genetic algorithm generally achieved lower loss, faster convergence, and more consistent results than simulated annealing under the tested settings.

---

## Additional Notes
- This project was developed for the course **Optimization Methods for Engineers** at ETH Zürich.
- The implementation is written in C++.
- Python was used for post-processing CSV experiment data and generating plots.
- ChatGPT was used for C++ syntax support. The project formulation, implementation, experiments, and analysis were carried out by the author.

---

## Author
Filippo Christen  
ETH Zürich
