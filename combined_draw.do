# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all Verilog modules in poly_function.v to working dir;
# could also have multiple Verilog files.
# The timescale argument defines default time unit
# (used when no unit is specified), while the second number
# defines precision (all times are rounded to this value)
vlog -timescale 1ns/1ns ball.v

# Load simulation using poly_function as the top level simulation module.
vsim combined_balls

# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}


force {clock} 0 0, 1 1 -r 2
force {reset_n} 0 0, 1 2, 0 4

run 400ns

