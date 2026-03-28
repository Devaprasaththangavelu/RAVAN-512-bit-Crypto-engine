# RAVAN-512: Multi-core Cryptographic Hardware Engine

## Overview

RAVAN-512 is a high-performance 512-bit cryptographic engine designed using Verilog, targeting secure and scalable hardware implementations. The architecture is optimized for high throughput, efficient resource utilization, and robust multi-clock domain operation.

The design implements a 21-round encryption/decryption pipeline with dynamic key slicing and supports full RTL-to-GDSII flow validation.

---

## Key Highlights

* 512-bit multi-core cryptographic architecture
* 21-round pipelined encryption/decryption engine
* Achieved timing closure at **500 MHz (2.0 ns)** with **+1.15 ns slack** (45nm)
* Maximum theoretical frequency: ~1.26 GHz
* ~11.5K standard cells, ~29K µm² area
* Total power: **1.72 mW** (Leakage: 7.59 µW)
* Multi-clock domain design with **Gray-coded asynchronous FIFO**
* Integrated **AMBA AXI4/AHB interfaces**
* End-to-end RTL-to-GDSII flow using OpenLane (Sky130)

---

## Architecture

The system consists of the following major components:

* Multi-core encryption datapath
* Dynamic key slicing unit (512-bit → 8 × 64-bit slices)
* 21-round transformation engine
* Control FSM for encryption/decryption flow
* Clock domain crossing (CDC) using asynchronous FIFO

---

## Verification Strategy

A multi-level verification approach was used:

### RTL Verification

* Developed **SystemVerilog/UVM-based constrained random environment**
* Verified functional correctness across multiple test scenarios

### High-Level Reference Model (Python)

* Implemented a Python-based golden reference model
* Used to validate RTL outputs against expected encryption/decryption results
* Enabled rapid functional validation before simulation
* Performed RTL vs Python output comparison across test vectors

---

## Physical Design & Implementation

* Synthesized using **Cadence Genus** (45nm technology)
* Achieved timing closure with positive slack
* Performed RTL-to-GDSII flow using **OpenLane (Sky130)**
* Completed floorplanning and global routing for macro-level design

---

## Results

### Timing

* Clock Frequency: 500 MHz
* Slack: +1.15 ns
* Critical Path Delay: ~0.79 ns

### Area

* Standard Cells: ~11.5K
* Total Area: ~29K µm²

### Power

* Total Power: 1.72 mW
* Leakage Power: 7.59 µW

---

## Repository Structure

```
RAVAN-512/
 ├── RTL/                # Verilog source files
 ├── Verification/
 │    ├── UVM/           # Testbench and verification environment
 │    └── Python_Model/  # Golden reference model
 ├── Synthesis/          # Synthesis scripts and reports
 ├── Physical_Design/    # Floorplan, routing, GDS (if available)
 ├── Results/            # Waveforms, timing reports, output logs
 └── Docs/               # Block diagrams and documentation
```

---

## Tools & Technologies

* Verilog, SystemVerilog, UVM
* Cadence Genus, Xcelium
* OpenLane (Sky130)
* Yosys, Verilator
* Python (Reference Model)

---

## Key Learnings

* Designing high-frequency pipelined architectures
* Handling multi-clock domain synchronization (CDC)
* Achieving timing closure under strict constraints
* Building scalable and modular RTL systems
* Integrating verification with high-level modeling

---

## Future Improvements

* Full signoff (DRC/LVS) for physical design
* Power optimization using clock gating
* FPGA prototyping for real-time validation
* Enhanced security through advanced key scheduling

---

## Author

**Devaprasath Thangavelu**
RTL / ASIC Design Engineer

GitHub: https://github.com/Devaprasaththangavelu
LinkedIn: https://www.linkedin.com/in/devaprasath-thangavelu-424011294/
