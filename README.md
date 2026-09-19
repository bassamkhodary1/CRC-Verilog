# CRC Verilog RTL Design & Verification

## Overview

This project implements a **Cyclic Redundancy Check (CRC)** module using **Verilog HDL**.

The design consists of:

* A CRC RTL module
* A parameterized counter module
* A Verilog testbench for functional verification
* File-based input and expected-output test vectors
* Clocked CRC input and output phases
* Automated PASS/FAIL result checking

The project was developed as part of practical **Digital IC / RTL Design** training.

---

## Project Structure

```text
CRC-Verilog/
│
├── rtl/
│   ├── CRC.v
│   └── counter.v
│
├── tb/
│   └── CRC_tb.v
│
├── sim/
│   ├── DATA_h.txt
│   └── Expec_Out_h.txt
│
├── README.md
└── .gitignore
```

---

## Design Architecture

The design contains two main RTL modules:

```text
             +----------------+
 Data ------>|                |
 Active ---->|      CRC       |------> Crc
 Clk ------->|                |------> Valid
 Rst ------->|                |
             +-------+--------+
                     |
                     | start / clear
                     v
             +----------------+
             |    Counter     |
             +----------------+
                     |
                     v
                    done
```

### CRC Module

The CRC module provides the main CRC generation logic.

### Interface

| Signal   | Direction | Description                             |
| -------- | --------- | --------------------------------------- |
| `Data`   | Input     | Serial input data bit                   |
| `Active` | Input     | Controls the input/CRC processing phase |
| `Clk`    | Input     | Clock signal                            |
| `Rst`    | Input     | Active-low reset                        |
| `Crc`    | Output    | Serial CRC output bit                   |
| `Valid`  | Output    | Indicates the CRC output phase          |

The CRC register is initialized using:

```verilog
localparam SEED = 8'hD8;
```

The CRC state is stored in an 8-bit register:

```verilog
reg [7:0] Q_next, Q_reg;
```

---

## CRC Processing

The input data is processed **serially, LSB first**.

For each input byte, the testbench sends:

```text
bit[0] → bit[1] → ... → bit[7]
```

The testbench explicitly drives the data bit before the rising clock edge, allowing the DUT to sample the input synchronously.

After the input phase is completed, the design enters the CRC output phase.

The CRC output is also collected **LSB first**:

```text
Crc bit[0] → Crc bit[1] → ... → Crc bit[7]
```

The testbench reconstructs the complete CRC byte from the serial output bits.

---

## Counter Module

The project includes a parameterized counter:

```verilog
module counter
#(parameter n=4)
```

The counter contains:

```verilog
reg [n-1:0] Q_next, Q_reg;
```

and uses:

```verilog
localparam [n-1:0] Const = 7;
```

When `clear` is asserted, the counter is loaded with `Const`.

When `start` is asserted, the counter increments.

The `done` signal is generated using:

```verilog
assign done = &Q_reg;
```

The CRC module instantiates the counter with:

```verilog
counter #(.n(4)) C1 (
    .clk(Clk),
    .start(Valid),
    .done(done),
    .clear(Active)
);
```

---

## Reset and Initialization

The CRC register uses an active-low asynchronous reset:

```verilog
always @(posedge Clk, negedge Rst)
```

When reset is asserted:

```verilog
Q_reg <= SEED;
```

Therefore, the CRC state starts from:

```text
SEED = 0xD8
```

The testbench applies reset at the beginning of the simulation and waits for a complete clock cycle after releasing reset before starting the test frames.

---

## Verification

The project includes a file-based Verilog testbench.

The testbench reads:

```text
DATA_h.txt
```

for input data and:

```text
Expec_Out_h.txt
```

for the expected CRC values.

The testbench uses `$fopen` and `$fscanf` to read hexadecimal test vectors.

### Example Input Data

The input file can contain hexadecimal bytes such as:

```text
93
72
36
1B
A6
C0
55
F2
5E
11
```

Each byte is processed as one test frame.

---

## Automated Test Flow

For every test frame, the testbench performs:

```text
Read Input Byte
       ↓
Read Expected CRC
       ↓
Send 8 Data Bits
       ↓
LSB-First Processing
       ↓
Collect 8 CRC Bits
       ↓
Reconstruct CRC Byte
       ↓
Compare Actual vs Expected
       ↓
PASS / FAIL
```

The testbench maintains:

```verilog
frame_count
pass_count
fail_count
```

and produces a final simulation report.

---

## Verification Output

For each frame, the testbench displays:

```text
==============================================
FRAME 1
==============================================
Input    = 93
Expected = 78
----------------------------------------------
...
Actual   = 78
Expected = 78
RESULT   = PASS
==============================================
```

At the end of the simulation, it reports:

```text
==============================================
                 TEST COMPLETE
==============================================
Total Frames = ...
PASS         = ...
FAIL         = ...
----------------------------------------------
FINAL RESULT = *** PASS ***
==============================================
```

The final result is determined from the accumulated `fail_count`.

---

## Simulation

The project can be simulated using a Verilog simulator such as **ModelSim**.

A typical simulation flow is:

```text
Compile RTL
    ↓
Compile Testbench
    ↓
Load CRC_tb
    ↓
Add Signals to Waveform
    ↓
Run Simulation
    ↓
Check PASS/FAIL
```

### Important Waveform Signals

For debugging and verification, the following signals are useful:

```text
Clk
Rst
Active
Data
Crc
Valid
Q_reg
Q_next
done
```

The waveform can be used to inspect:

* Reset behavior
* Input data timing
* CRC state transitions
* `Valid` timing
* CRC output timing
* Counter operation
* Frame-to-frame behavior

---

## Tools

* **Verilog HDL**
* **ModelSim**
* **Git**
* **GitHub**

---

## Key RTL Concepts Demonstrated

This project demonstrates practical implementation of:

* Sequential logic
* Combinational logic
* Registers
* Asynchronous reset
* Parameterized modules
* Module instantiation
* Serial data processing
* Bit-level operations
* Clocked interfaces
* RTL testbench development
* File-based test vectors
* Automated verification
* PASS/FAIL checking
* Waveform-based debugging

---

## Future Improvements

Possible future improvements include:

* Adding SystemVerilog assertions (SVA)
* Adding functional coverage
* Replacing file handling with `$readmemh` for memory-based test vectors
* Adding additional CRC test vectors
* Parameterizing the CRC width and polynomial
* Adding configurable seed values
* Creating a more reusable CRC verification environment
* Adding synthesis and timing analysis

---

## Project Status

**Completed — RTL implementation and functional verification**

The project currently includes the CRC RTL, counter logic, file-based testbench, automated comparison, and simulation workflow.
