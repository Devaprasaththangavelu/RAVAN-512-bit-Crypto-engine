`include "uvm_macros.svh"
import uvm_pkg::*;

module ravan_assertions(
    input logic clk,
    input logic rst_n,
    input logic reg_cs,
    input logic reg_we,
    input logic system_ready,
    input logic result_valid,
    input logic [63:0] reg_rdata
);

    // ==========================================================
    // 1. SAFETY ASSERTIONS (Checking Bad Values)
    // ==========================================================

    // Rule: Output 'result_valid' must never be X (Unknown)
    property p_valid_no_x;
        @(posedge clk) disable iff (!rst_n)
        !$isunknown(result_valid);
    endproperty
    
    A_VALID_NO_X: assert property (p_valid_no_x) 
        else `uvm_error("SVA", "result_valid is X (Unknown state)!") // No semicolon here

    // Rule: During Reset, 'result_valid' must be 0
    property p_reset_check;
        @(posedge clk) !rst_n |-> result_valid == 0;
    endproperty
    
    A_RESET_CHECK: assert property (p_reset_check)
        else `uvm_error("SVA", "result_valid is NOT 0 during reset!") // No semicolon here

    // ==========================================================
    // 2. LIVENESS ASSERTIONS (Checking Latency/Hang)
    // ==========================================================

    // Rule: If we write to the Trigger Address (0x08), result_valid MUST
    // go high within 1000 clock cycles. If not, the Core is HUNG.
    property p_pipeline_timeout;
        @(posedge clk) disable iff (!rst_n)
        (reg_cs && reg_we) |-> ##[1:1000] result_valid;
    endproperty
    
    A_PIPELINE_LIVENESS: assert property (p_pipeline_timeout)
        else `uvm_error("SVA", "Pipeline TIMEOUT! Result did not appear after input.") // No semicolon here

    // ==========================================================
    // 3. PROTOCOL ASSERTIONS (Bus Behavior)
    // ==========================================================
    
    // Rule: If Chip Select (CS) is inactive (0), Write Enable (WE) should be 0
    property p_clean_bus;
        @(posedge clk) disable iff (!rst_n)
        !reg_cs |-> !reg_we;
    endproperty
    
    A_CLEAN_BUS: assert property (p_clean_bus)
        else `uvm_warning("SVA", "Bus Signal Noise: WE is High while CS is Low") // No semicolon here

endmodule