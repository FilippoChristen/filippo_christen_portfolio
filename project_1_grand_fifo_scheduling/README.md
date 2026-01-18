# Deterministic Throughput for GRAND


## Overview
This project benchmarks a First-In First-Out (FIFO) scheduling approach [1] to achieve deterministic throughput for Guessing Random Additive Noise Decoding (GRAND) decoders [2].  
The study specifically utilizes the Ordered Reliability Bits GRAND (ORBGRAND) variant [3] to analyze architectural trade-offs and performance.

---

## Key Contributions
- Efficient implementation of the ORBGRAND decoder.  
- Development of a data-gathering framework to simulate multiple architectural configurations efficiently.  
- Parametrizable simulator enabling exploration of design trade-offs.  
- Integration of external code from [5] into the simulation workflow.

---

## Results
- The outcomes of this study contributed to the publication: "Fixed-Throughput GRAND with FIFO Scheduling," ISCAS 2025 [4].  

---

## Additional Notes
- For further details, see the accompanying thesis report (PDF included in this folder).  
- The code was developed and validated using MATLAB. It is correct under the intended environment, but runtime instructions are not provided.

---

## Acknowledgements
This project was completed as part of my Bachelor’s thesis at ETH Zürich.  
I would like to thank Prof. Dr. Christoph Studer and my supervisor Darja Nonaca for their guidance and support throughout the project.

---

## References

[1] C. Studer, “Iterative MIMO Decoding: Algorithms and VLSI Implementation Aspects,” Ph.D. dissertation, ETH Zurich, 2009.  
[2] K. R. Duffy, J. Li, and M. Médard, “Capacity-achieving guessing random additive noise decoding,” IEEE Trans. Inf. Theory, vol. 65, no. 7, pp. 4023–4040, 2019.  
[3] K. R. Duffy, W. An, and M. Médard, “Ordered reliability bits guessing random additive noise decoding,” IEEE Trans. Signal Process., vol. 70, pp. 4528–4542, 2022.  
[4] F. Christen, D. Nonaca, and C. Studer, "Fixed-Throughput GRAND with FIFO Scheduling," IEEE ISCAS 2025.  
[5] https://github.com/kenrduffy/GRAND-MATLAB
