#!/usr/bin/tclsh

# --- Configuration ---
set UVM_HOME "/usr/local/share/verilator/include/uvm-1.2/src" 
set TOP_MODULE "testbench"
set OUTPUT_EXE "RAVAN_sim"
# --- Define Your File List ---
# List all your Verilog/SystemVerilog files here
set DESIGN_FILES {
    "./src/async_fifo.v" "./src/controller.v" "./src/custom32.v" "./src/decryption.v" 
    "./src/design.sv" "./src/encryption.v" "./src/fifo_interconnect_core.v" 
    "./src/fifomem.v" "./src/keyslicer.v" "./src/key_wrapper.v" "./src/memory_top.v" 
    "./src/model.v" "./src/pipeline.v" "./src/prefetch.v" "./src/puf.v" "./src/rptr_empty.v" 
    "./src/sha.v" "./src/sha_constraints.v" "./src/sha_core.v" "./src/sha_mem.v" 
    "./src/sync.v" "./src/wptr_full.v"
}

# --- UVM Verification Files ---
set TB_FILES {
    "./uvm/ravan_interface.sv"
    "./uvm/ravan_item.sv"
    "./uvm/ravan_sequence.sv"
    "./uvm/ravan_driver.sv"
    "./uvm/ravan_monitor.sv"
    "./uvm/ravan_scoreboard.sv"
    "./uvm/ravan_env.sv"
    "./uvm/ravan_test.sv"
    "./uvm/ravan_assertions.sv"
    "./uvm/testbench.sv"
}

# --- Execution Flow ---

puts "--- Starting Verilator Flow for $TOP_MODULE ---"

# 1. Build the command string
set cmd "verilator --binary -j 2"
append cmd " +incdir+$UVM_HOME"
append cmd " $UVM_HOME/uvm_pkg.sv"
append cmd " --top-module $TOP_MODULE"
append cmd " --trace"
append cmd " -Wno-fatal"

# Add each source file to the command
foreach file $SRC_FILES {
    append cmd " $file"
}

# 2. Run Compilation
puts "Compiling design..."
if {[catch {exec {*}$cmd} result]} {
    puts "Compilation Failed:\n$result"
    exit 1
}
puts "Compilation Successful!"

# 3. Run Simulation
puts "Running Simulation..."
set run_cmd "./obj_dir/V${TOP_MODULE} +UVM_TESTNAME=my_crypto_test"
if {[catch {exec {*}$run_cmd} run_result]} {
    puts "Simulation Output:\n$run_result"
} else {
    puts "Simulation Finished Successfully."
}

# 4. Launch GTKWave automatically
puts "Opening Waveforms..."
exec gtkwave dump.vcd &
