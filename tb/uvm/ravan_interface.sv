interface ravan_if (input logic clk_50m, input logic clk_100m, input logic rst_n_50m, input logic rst_n_100m);
    // Bus Signals (50MHz Domain)
    logic [5:0]  reg_addr;
    logic [63:0] reg_wdata; // UPDATED to 64-bit
    logic [63:0] reg_rdata; // UPDATED to 64-bit
    logic        reg_we;
    logic        reg_cs;

    // Status Signals (100MHz Domain)
    logic        system_ready;
    logic        result_valid;

    // Clocking Block for Driver
    clocking drv_cb @(posedge clk_50m);
        default input #1ns output #1ns;
        output reg_addr, reg_wdata, reg_we, reg_cs;
        input  reg_rdata;
    endclocking

    // Clocking Block for Monitor
    clocking mon_cb @(posedge clk_50m);
        default input #1ns output #1ns;
        input reg_addr, reg_wdata, reg_rdata, reg_we, reg_cs;
    endclocking
    
    // Status Monitor
    clocking status_cb @(posedge clk_100m);
        input system_ready, result_valid;
    endclocking

endinterface