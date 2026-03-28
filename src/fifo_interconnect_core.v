
module fifo_interconnect (
    clk,
    rst_n,
    fifo_rempty,
    fifo_rdata,
    fifo_rinc,
    enc_dec_sel,
    sel,
    o_result_data,
    o_result_done
);

    // --- Parameters ---
    parameter FIFO_WIDTH = 64;

    // --- Port Declarations ---
    input  wire        clk;
    input  wire        rst_n;
    input  wire        fifo_rempty;
    input  wire [FIFO_WIDTH-1:0] fifo_rdata;
    output reg         fifo_rinc;
    input  wire        enc_dec_sel;
    input  wire [3:0]  sel;
    output reg [63:0]  o_result_data;
    output reg         o_result_done;

    // --- Internal Registers ---
    reg [63:0] k_mem [0:7]; // 8x 64-bit Memory
    reg [63:0] r_data;
    reg [3:0]  word_cnt;

    reg        start_enc;
    reg        start_dec;
    wire       done_enc;
    wire       done_dec;
    wire [63:0] out_enc;
    wire [63:0] out_dec;

    // --- State Machine Definitions (using localparam) ---
    reg [3:0] state;

    localparam S_IDLE       = 4'd0;
    localparam S_REQ_DATA   = 4'd1;
    localparam S_WAIT_RAM   = 4'd2; // Wait for Data Valid
    localparam S_LATCH_DATA = 4'd3;
    localparam S_PRE_START  = 4'd4; // Safety check
    localparam S_START_CORE = 4'd5;
    localparam S_WAIT_CORE  = 4'd6;
    localparam S_OUTPUT     = 4'd7;

    // --- Core Instantiations ---
    encryption u_enc (
        .clk(clk), 
        .rst(~rst_n),      // Assuming active high reset for core
        .start(start_enc), 
        .sel(sel),
        .data_in(r_data),
        .k0(k_mem[0]), .k1(k_mem[1]), .k2(k_mem[2]), .k3(k_mem[3]),
        .k4(k_mem[4]), .k5(k_mem[5]), .k6(k_mem[6]), .k7(k_mem[7]),
        .enc_data_out(out_enc), 
        .done(done_enc)
    );

    decryption u_dec (
        .clk(clk), 
        .rst(~rst_n), 
        .start(start_dec), 
        .sel(sel),
        .data_in(r_data),
        .k0(k_mem[0]), .k1(k_mem[1]), .k2(k_mem[2]), .k3(k_mem[3]),
        .k4(k_mem[4]), .k5(k_mem[5]), .k6(k_mem[6]), .k7(k_mem[7]),
        .dec_data_out(out_dec), 
        .done(done_dec)
    );

    // --- Main Logic ---
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_IDLE;
            fifo_rinc <= 0;
            start_enc <= 0; 
            start_dec <= 0;
            o_result_done <= 0;
            o_result_data <= 0;
            word_cnt <= 0;
            r_data <= 0;
            
            // Explicit Reset for Key Memory
            k_mem[0] <= 64'd0; k_mem[1] <= 64'd0; k_mem[2] <= 64'd0; k_mem[3] <= 64'd0;
            k_mem[4] <= 64'd0; k_mem[5] <= 64'd0; k_mem[6] <= 64'd0; k_mem[7] <= 64'd0;
            
        end else begin
            // Default Assignments
            fifo_rinc     <= 0;
            start_enc     <= 0;
            start_dec     <= 0;
            o_result_done <= 0;

            case (state)
                S_IDLE: begin
                    word_cnt <= 0;
                    if (!fifo_rempty) state <= S_REQ_DATA;
                end

                // 1. Request Data
                S_REQ_DATA: begin
                    if (!fifo_rempty) begin
                        fifo_rinc <= 1;
                        state <= S_WAIT_RAM;
                    end
                end

                // 2. Wait State (Critical for FIFO Latency)
                S_WAIT_RAM: begin
                    state <= S_LATCH_DATA;
                end

                // 3. Latch Data
                S_LATCH_DATA: begin
                    // Store Key or Data based on count
                    if (word_cnt < 8) begin
                        k_mem[word_cnt] <= fifo_rdata;
                    end else begin
                        r_data <= fifo_rdata;
                    end

                    // Check if packet (8 Keys + 1 Data) is full
                    if (word_cnt == 8) begin
                        state <= S_PRE_START;
                    end else begin
                        word_cnt <= word_cnt + 1;
                        state <= S_REQ_DATA;
                    end
                end

                // 4. Safety Check (Wait for Done to be Low)
                S_PRE_START: begin
                    if (enc_dec_sel) begin
                        if (!done_enc) state <= S_START_CORE;
                    end else begin
                        if (!done_dec) state <= S_START_CORE;
                    end
                end

                // 5. Trigger Core
                S_START_CORE: begin
                    if (enc_dec_sel) start_enc <= 1;
                    else             start_dec <= 1;
                    state <= S_WAIT_CORE;
                end

                // 6. Wait for Completion
                S_WAIT_CORE: begin
                    if (enc_dec_sel && done_enc) begin
                        o_result_data <= out_enc;
                        state <= S_OUTPUT;
                    end else if (!enc_dec_sel && done_dec) begin
                        o_result_data <= out_dec;
                        state <= S_OUTPUT;
                    end
                end

                // 7. Output Result
                S_OUTPUT: begin
                    o_result_done <= 1;
                    state <= S_IDLE;
                end

                default: state <= S_IDLE;
            endcase
        end
    end

endmodule
