// Code your testbench here
// or browse Examples
`timescale 1ns/1ps

// 1. UVM PACKAGES
import uvm_pkg::*;
`include "uvm_macros.svh"

// -----------------------------------------------------------
// 2. DESIGN FILES (Compiling Bottom-Up)
// -----------------------------------------------------------

// A. Low-Level Libraries (Must come first)
`include "sha_constrants.v"   // Constants needed by SHA
`include "sync.v"             // Needed by async_fifo
`include "fifomem.v"          // Needed by async_fifo
`include "rptr_empty.v"       // Needed by async_fifo
`include "wptr_full.v"        // Needed by async_fifo
`include "sha_core.v"         // Needed by sha.v
`include "sha_mem.v"          // Likely needed by sha.v

// B. Standard Components
`include "async_fifo.v"       // Uses sync, fifomem, etc.
`include "sha.v"              // Uses sha_core
`include "custom32.v"         // Needed by pipeline
`include "keyslicer.v"        // Needed by key_wrapper (You called it keyslicer.v, not keyslicer_v1.v)

// C. Crypto Cores
`include "encryption.v"       // You renamed enc.v to encryption.v
`include "decryption.v"       // WARNING: You missed this in your list. Ensure you have decryption.v!

// D. Sub-Systems
`include "key_wrapper.v"      // Uses keyslicer
`include "fifo_interconnect_core.v" // The Integrated Interconnect (Uses encryption/decryption)
`include "pipeline.v"          // The Integrated Pipeline (Uses SHA, async_fifo, etc.)

// E. Memory
`include "memory_top.v"
`include "puf.v"
`include "prefetch.v"
`include "controller.v"
`include "model.v"
// -----------------------------------------------------------
// 3. UVM TESTBENCH FILES
// -----------------------------------------------------------
`include "ravan_interface.sv" // Renamed from ravan_if.sv
`include "ravan_assertions.sv"
`include "ravan_item.sv"
`include "ravan_sequence.sv"
`include "ravan_driver.sv"
`include "ravan_monitor.sv"
`include "ravan_scoreboard.sv"
`include "ravan_env.sv"
`include "ravan_test.sv"

module tb_top;
    
    // Clock Generation
    logic clk_50m = 0, clk_100m = 0;
    always #10 clk_50m = ~clk_50m;  
    always #5  clk_100m = ~clk_100m;

    // Reset Generation
    logic rst_n_50m = 0, rst_n_100m = 0;

    // Interface
    ravan_if vif(clk_50m, clk_100m, rst_n_50m, rst_n_100m);

    // DUT Instantiation
    ravan_soc_top DUT (
        .clk_50m(clk_50m), 
        .rst_n_50m(rst_n_50m),
        .clk_100m(clk_100m), 
        .rst_n_100m(rst_n_100m),
        
        .reg_addr(vif.reg_addr),
        .reg_wdata(vif.reg_wdata), 
        .reg_rdata(vif.reg_rdata), 
        .reg_we(vif.reg_we),
        .reg_cs(vif.reg_cs),
        
        .system_ready(vif.system_ready),
        .result_valid(vif.result_valid)
    );

    // Bind Assertions
    bind DUT ravan_assertions sva_inst (
        .clk(clk_100m), 
        .rst_n(rst_n_100m),
        .reg_cs(reg_cs),       
        .reg_we(reg_we),
        .system_ready(system_ready),
        .result_valid(result_valid),
        .reg_rdata(reg_rdata)
    );

    initial begin
        // Reset Sequence
        rst_n_50m = 0; rst_n_100m = 0;
        #100;
        rst_n_50m = 1; rst_n_100m = 1;
    end

    initial begin
        uvm_config_db#(virtual ravan_if)::set(null, "*", "vif", vif);
        run_test("ravan_test");
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_top);
    end
endmodule