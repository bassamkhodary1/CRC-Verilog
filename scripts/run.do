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

# Run simulation
run -all

