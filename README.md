# Sigma-Delta Controller Project

This repository explores the design, simulation, and implementation of sigma-delta controllers used in analog-to-digital conversion and control systems. The focus is on creating high-performance, low-power modulators tailored for DC motors.

---

## Project Overview

Conventional digital control systems for motor applications often rely on complex, bloated software stacks running on general-purpose processors. These systems introduce significant latency, consume considerable power, and require expensive hardware resources—posing a bottleneck in high-performance, real-time applications such as electric propulsion and flight control. In this project, we explore an alternative architecture based on multiplier-less sigma-delta (ΣΔ) controllers to generate three-phase motor drive signals directly from simple feedback logic. By leveraging the inherent noise-shaping and high-resolution properties of sigma-delta modulation, our design aims to remove the need for computationally expensive transformations (e.g., Park and Clarke), reduce system complexity, and dramatically improve latency and energy efficiency. 

The system is implemented in Verilog, targeting FGPGA platforms for real-time control and integration. To analyze performance and optimize energy efficiency, we aim to use Python to simulate motor and power characteristics. Additionally, LTSpice is used to develop and benchmark a reference motor model for cross-validation. Together, these tools support an efficient design pipeline from concept to hardware.

Our work hopes to show the potential of sigma-delta architectures in building ultra-lightweight, high-bandwidth control systems that scale to future applications such as personal electric flight, where performance, size, and power are all critically constrained.


## Repository Structure

- `/src` – Source code and models  
- `/docs` – Documentation and research papers  
- `/sim` – Simulation results and test benches  
- `/hardware` – FPGA or ASIC implementations  
- `/examples` – Sample use cases 

---

## To Do List

### 1. Verilator Jupyter Notebook Setup
- Compile list of previous issues encountered  
- Explain output results thoroughly  
- Use WSL in VSCode to edit and run Verilog with Verilator  
- Create script to output results into `.txt` format  
- Analyze `.txt` data using Jupyter Notebook  
- Document setup with annotated pictures  
- Explore removing WSL dependency entirely

### 2. AC Motor Modeling
- Design schematic for motor model  
- Build circuit in LTSpice (reuse existing motor model if applicable)  
- Drive simulation with square wave input  
- Program Python model of motor  
- Compare Python outputs with LTSpice results  
- Match Python behavior with simulated behavior  
- Measure power loss via rotor resistance

### 3. First-Order Controller Design
- Apply fixed threshold logic  
  - Allow switching once integrator error exceeds threshold until output matches input (Σ δ s(t))  
- Investigate dual integration approach (Q1 and Q2 control logic)  
- Address stability issues due to high gain

### 4. Second-Order Controller Design
- Implement second integrator to process first-order error  
- Add second-order feedback (potential alternative to threshold modulation)  
- Tackle stability issues related to high gain and amplified first-order output

### 5. Refinement and Documentation
- Refactor code and simulations for clarity  
- Write up methodology and findings in `/docs`  
- Create visual explanations and tutorials  
- Prepare comprehensive project summary and conclusions


