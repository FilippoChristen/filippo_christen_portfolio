# Low-Power AXI Serial Link


## Overview
This project implements a low-power AXI-interfaced serial link designed for edge and chip-to-chip (C2C) applications.  
The architecture builds upon existing designs [1,2] while introducing a fully redesigned interface and control logic, excluding the proprietary mixed-signal PHY developed by Sina Arjmandpour (sarjmadpour@iis.ee.ethz.ch).  

The serial link is organized into three main layers, corresponding loosely to OSI layers 1–3:

- **Network Layer:** Interfaces with AXI, converting AXI transactions into parallel flit transfers with appropriate headers.  
- **Data Layer:** Serializes parallel flits onto an 8-bit bus and implements credit-based flow control for reliable transfer under varying throughput conditions.  
- **PHY Layer:** Further serializes the 8-bit stream onto a single data wire. Includes startup, synchronization, and idle control logic to enable low-power operation.  

Incoming data follows the reverse path, ultimately being converted back to AXI at the destination interface.

---

## Key Contributions
- Redesigned AXI interface and link architecture for high throughput and low power.  
- Implemented startup, synchronization, and idle-mode control of the PHY interface.  
- Developed credit-based flow control to ensure reliable data transmission.  
- Verification of the link functionality through SystemVerilog testbenches.  
- Architectural improvements to reduce power consumption and increase efficiency.

---

## Additional Notes
- For further details, see the accompanying thesis report (PDF included in this folder).  
- The code was developed using SystemVerilog and validated in QuestaSim. It is correct under the intended environment, but runtime instructions are not provided.  
- The proprietary mixed-signal PHY is **not included** in this repository. This folder focuses on the modules and wrappers developed by the author.

---

## Acknowledgements
This project was completed as part of a Semester project at ETH Zürich.  
I would like to thank Prof. Dr. Luca Benini and my supervisor Tim Fischer for their guidance and support throughout the project.

---

## References
[1] P. Scheer, T. Benz, V. Potocnik, T. Fischer, L. Colagrande, N. Wistoff, Y. Zhang,  
    L. Bertaccini, G. Ottavi, M. Eggimann, M. Cavalcante, G. Paulin, F. K. Gürkaynak,  
    D. Rossi, and L. Benini, "Occamy: A 432-core dual-chiplet dual-HBM2e 768-Gop/s RISC-V system  
    for 8-to-64-bit dense and sparse computing in 12-nm NFET," *IEEE Journal of Solid-State Circuits*,  
    vol. 60, no. 4, pp. 1324–1338, 2025.  
[2] https://github.com/pulp-platform/serial_link
