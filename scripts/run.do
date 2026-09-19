# =========================================================
# CRC - ModelSim Simulation Script
# =========================================================

# Create compiled simulation library
vlib work

# Compile RTL
vlog rtl/counter.v
vlog rtl/CRC.v

# Compile Testbench
vlog tb/CRC_tb.v

# Load Testbench
vsim work.CRC_tb

# Add all testbench signals to Wave
add wave -divider "Testbench"
add wave sim:/CRC_tb/Clk
add wave sim:/CRC_tb/Rst
add wave sim:/CRC_tb/Active
add wave sim:/CRC_tb/Data
add wave sim:/CRC_tb/Crc
add wave sim:/CRC_tb/Valid

# Run simulation
run -all

