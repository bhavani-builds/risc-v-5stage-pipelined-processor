# 5-Stage Pipelined RISC-V Processor

A **5-stage pipelined RV32I processor** designed and verified using **Verilog HDL**.
The processor implements a classic **IF → ID → EX → MEM → WB** pipeline architecture with **data forwarding, load-use hazard detection, branch flushing, and automated simulation using GitHub Actions**.

---

## 🚀 Project Overview

This project demonstrates the design of a simplified RISC-V processor using a five-stage pipeline.

The processor divides instruction execution into five stages:

```text
        ┌──────┐
        │  IF  │  Instruction Fetch
        └──┬───┘
           │
        ┌──▼───┐
        │  ID  │  Instruction Decode
        └──┬───┘
           │
        ┌──▼───┐
        │  EX  │  Execute / ALU
        └──┬───┘
           │
        ┌──▼───┐
        │ MEM  │  Memory Access
        └──┬───┘
           │
        ┌──▼───┐
        │  WB  │  Write Back
        └──────┘
```

The pipeline allows multiple instructions to be processed simultaneously, improving instruction throughput compared with a single-cycle implementation.

---

## ✨ Features

* 32-bit RISC-V processor
* RV32I-style instruction execution
* 5-stage pipeline
* Instruction Fetch
* Instruction Decode
* Execute / ALU
* Memory Access
* Register Writeback
* 32 × 32-bit register file
* Data forwarding
* Load-use hazard detection
* Pipeline stalling
* Branch detection
* Pipeline flushing
* JAL support
* Load / Store support
* Signed and unsigned comparisons
* Automated Verilog simulation
* GitHub Actions CI
* VCD waveform generation

---

## 🧩 Pipeline Architecture

```text
                 ┌──────────────────────┐
                 │   Program Counter    │
                 └──────────┬───────────┘
                            │
                            ▼
                    ┌──────────────┐
                    │ Instruction  │
                    │   Memory     │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │     IF/ID    │
                    │    Register  │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │   Control    │
                    │    Unit      │
                    └──────┬───────┘
                           │
                    ┌──────▼───────┐
                    │  Register    │
                    │     File     │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │    ID/EX     │
                    │    Register  │
                    └──────┬───────┘
                           │
                    ┌──────▼───────┐
                    │     ALU      │
                    │   Execute    │
                    └──────┬───────┘
                           │
              ┌────────────┴────────────┐
              │                         │
              ▼                         ▼
       ┌──────────────┐          ┌──────────────┐
       │  Forwarding  │          │    Branch    │
       │     Unit     │          │    Logic     │
       └──────────────┘          └──────────────┘
              │                         │
              └────────────┬────────────┘
                           ▼
                    ┌──────────────┐
                    │    EX/MEM    │
                    │    Register  │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │     Data     │
                    │    Memory    │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │    MEM/WB    │
                    │    Register  │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │  Write Back  │
                    │  Register    │
                    │     File     │
                    └──────────────┘
```

---

## 📁 Project Structure

```text
risc-v-5stage-pipelined-processor/
│
├── rtl/
│   ├── program_counter.v
│   ├── instruction_memory.v
│   ├── register_file.v
│   ├── alu.v
│   ├── immediate_generator.v
│   ├── control_unit.v
│   │
│   ├── if_id_register.v
│   ├── id_ex_register.v
│   ├── ex_mem_register.v
│   ├── mem_wb_register.v
│   │
│   ├── forwarding_unit.v
│   ├── hazard_detection_unit.v
│   ├── data_memory.v
│   └── pipeline_cpu.v
│
├── tb/
│   └── pipeline_cpu_tb.v
│
├── program/
│   └── program.hex
│
├── .github/
│   └── workflows/
│       └── pipeline-ci.yml
│
├── README.md
└── .gitignore
```

---

## 🧠 Processor Components

### Program Counter

Maintains the address of the current instruction and supports:

* Sequential PC + 4
* Branch target updates
* Jump target updates
* Pipeline stalls

### Instruction Memory

Stores the processor program and provides instructions using word-aligned addressing.

### Register File

Contains:

```text
32 registers × 32 bits
```

Register `x0` is permanently treated as zero.

### ALU

Supports:

```text
ADD
SUB
AND
OR
XOR
SLT
SLTU
SLL
SRL
SRA
```

### Immediate Generator

Generates immediate values for:

```text
I-type
S-type
B-type
J-type
```

### Control Unit

Generates control signals based on the instruction opcode and function fields.

### Pipeline Registers

The processor uses four pipeline registers:

```text
IF/ID
ID/EX
EX/MEM
MEM/WB
```

These registers isolate the five pipeline stages.

---

## ⚡ Hazard Handling

Pipeline processors can encounter data dependencies between instructions.

This project implements two important techniques.

### 1. Data Forwarding

Example:

```text
ADD  x3, x1, x2
SUB  x4, x3, x1
```

Instead of waiting for `x3` to be written back, the result can be forwarded directly to the next instruction.

```text
EX/MEM ───────► EX
MEM/WB ───────► EX
```

### 2. Load-Use Hazard Detection

Example:

```text
LW   x2, 0(x1)
ADD  x3, x2, x4
```

The loaded value is not immediately available for the following EX stage.

The hazard detection unit therefore:

```text
STALL PC
STALL IF/ID
FLUSH ID/EX
```

After the required stall, forwarding allows execution to continue.

---

## 🚦 Branch Handling

Conditional branches are evaluated in the execute stage.

For a taken branch:

```text
PC → Branch Target
IF/ID → Flush
ID/EX → Flush
```

This prevents wrong-path instructions from modifying the architectural state.

Supported conditional branches include:

```text
BEQ
BNE
```

---

## 🔗 Jump Support

The processor supports:

```text
JAL
```

For JAL:

```text
rd = PC + 4
PC = PC + immediate
```

The return address is propagated through the pipeline to the writeback stage.

---

## 📋 Supported Instructions

| Category     | Instructions  |
| ------------ | ------------- |
| Arithmetic   | ADD, SUB      |
| Logical      | AND, OR, XOR  |
| Comparison   | SLT, SLTU     |
| Immediate    | ADDI          |
| Memory       | LW, SW        |
| Branch       | BEQ, BNE      |
| Jump         | JAL           |
| Shift        | SLL, SRL, SRA |
| No Operation | NOP           |

---

## 🧪 Verification

The testbench verifies processor operation by checking register values after program execution.

Example:

```text
PASS: x1 = 10
PASS: x2 = 20
PASS: x3 = 30
PASS: x4 = 20
```

The simulation also generates a waveform:

```text
pipeline_cpu.vcd
```

The waveform can be inspected using **GTKWave**.

---

## 🔄 Verification Flow

```text
Verilog RTL
     │
     ▼
Icarus Verilog
     │
     ▼
Compile
     │
     ▼
Simulation
     │
     ▼
Register Checks
     │
     ▼
VCD Waveform
     │
     ▼
GitHub Actions
     │
     ▼
PASS ✓
```

---

## 🤖 Continuous Integration

GitHub Actions automatically:

1. Checks out the repository
2. Installs Icarus Verilog
3. Compiles the complete RTL
4. Compiles the testbench
5. Runs simulation
6. Generates the waveform
7. Verifies the simulation output

This helps ensure that RTL changes do not silently break the processor.

---

## 🛠️ Tools Used

| Tool           | Purpose                |
| -------------- | ---------------------- |
| Verilog HDL    | RTL Design             |
| Icarus Verilog | Simulation             |
| GTKWave        | Waveform Analysis      |
| GitHub Actions | Continuous Integration |
| GitHub         | Version Control        |

---

## 🎯 Learning Objectives

This project demonstrates practical understanding of:

* Computer architecture
* RISC-V ISA concepts
* RTL design
* Pipeline architecture
* Pipeline registers
* ALU design
* Register files
* Control logic
* Data hazards
* Forwarding
* Pipeline stalls
* Branch flushing
* Memory interfaces
* Verilog testbench development
* Automated hardware verification
* GitHub-based HDL development

---

## 📈 Future Improvements

Planned enhancements include:

* Full RV32I instruction coverage
* Additional branch instructions
* CSR support
* Exception handling
* Interrupt support
* Instruction cache
* Data cache
* Branch prediction
* Performance counters
* FPGA implementation
* Timing analysis
* CPI/performance comparison
* Formal verification

---

## 👩‍💻 Author

**Bhavani**

Electronics & Communication Engineering

Interests:

```text
VLSI
RTL Design
Digital Electronics
FPGA
Computer Architecture
Embedded Systems
RISC-V
```

---

## ⭐ Project Highlights

```text
32-bit RISC-V
      +
5-Stage Pipeline
      +
Forwarding
      +
Hazard Detection
      +
Branch Flush
      +
JAL
      +
Automated Verification
      +
GitHub Actions
```

This project is intended as an educational RTL implementation for understanding pipelined processor architecture and hardware verification.
