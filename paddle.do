# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all Verilog modules in poly_function.v to working dir;
# could also have multiple Verilog files.
# The timescale argument defines default time unit
# (used when no unit is specified), while the second number
# defines precision (all times are rounded to this value)
vlog -timescale 1ns/1ns paddle_sim.v

# Load simulation using poly_function as the top level simulation module.
vsim paddle_sim
# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}


force {clock} 0 0, 1 1 -r 2
force {reset_n} 0 0, 1 2, 0 4
force {go} 0 0, 1 10
#force {x_in} 10#10 0
#force {y_in} 10#10 0
#force {colour_in} 2#101 0
#force {p1_finYcount} 1 6, 0 20
#force {p2_finYcount} 1 15, 0 17


run 100000ms

