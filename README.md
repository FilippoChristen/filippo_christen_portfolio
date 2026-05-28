# Filippo Christen — Academic Portfolio

## Overview
This repository contains a selection of completed academic engineering projects.
Each project includes a high-level overview, key contributions, results, and references. Detailed documentation and code for each project are available in the respective subfolders.

---

## Projects

### 1. Deterministic Throughput for GRAND
**Domain:** Error-Correcting Codes, Communication Systems  
**Tools:** MATLAB  

This project benchmarks a FIFO scheduling approach to achieve deterministic throughput for Guessing Random Additive Noise Decoding (GRAND) decoders. It specifically evaluates the ORBGRAND variant to analyze architectural trade-offs.  

[Explore project →](./project_1_grand_fifo_scheduling)

---

### 2. Low-Power AXI Serial Link
**Domain:** Digital Design, Low-Power SoC Interconnects  
**Tools:** SystemVerilog, QuestaSim  

This project presents a low-power, high-throughput AXI-interfaced serial link for edge and chip-to-chip applications. It includes a redesigned interface and control logic, integrating credit-based flow control and idle-mode PHY management. The proprietary mixed-signal PHY is not included. The repository focuses on the modules developed by the author.  

[Explore project →](./project_2_low_power_axi_serial_link)

---

### 3. Fixed-Point Bitwidth Optimization in Arithmetic Circuits
**Domain:** Numerical Optimization, Digital Hardware, Fixed-Point Arithmetic  
**Tools:** C++, Python  

This project implements a C++ framework for optimizing fixed-point bitwidths in arithmetic combinational circuits. It minimizes estimated hardware area while keeping numerical error below a target tolerance, comparing genetic algorithm and simulated annealing approaches across multiple circuit topologies.  

[Explore project →](./project_3_fixed_point_bitwidth_optimization)

---


## Additional Notes
- All code was developed and validated in the intended simulation environments (MATLAB or QuestaSim).  
- Some projects include references to external or proprietary code that is not redistributed here.  
- The accompanying thesis reports (PDFs) provide further details for each project.

---

## License
This repository is licensed under the MIT License. See [LICENSE](./LICENSE) for details.  
Third-party or proprietary code included in project folders retains its original license.

---
