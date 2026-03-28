module ravan_soc_top (
    input  wire        clk_50m,
    input  wire        rst_n_50m,
    input  wire        clk_100m,
    input  wire        rst_n_100m,

    // ===== ORIGINAL BUS INTERFACE (UVM SAFE) =====
    input  wire [5:0]  reg_addr,    
    input  wire [63:0] reg_wdata,
    output reg  [63:0] reg_rdata,
    input  wire        reg_we,
    input  wire        reg_cs,

    // ===== CONTROL =====
    input  wire [2:0]  reg_ctrl,

    // ===== STATUS =====
    output wire        system_ready,
    output wire        result_valid
);

    // =========================================================
    // 100 MHz DOMAIN : CONFIG REGISTERS
    // =========================================================
    reg [511:0] key_shadow;
    reg [511:0] key_active;
    reg [2:0]   key_cnt;
    reg [31:0]  addr_reg;
    reg         start_req;

    // CDC Sync for clearing the start request
    reg done_sync1, done_sync2;

    always @(posedge clk_100m or negedge rst_n_100m) begin
        if (!rst_n_100m) begin
            key_shadow <= 512'b0;
            key_active <= 512'b0;
            key_cnt    <= 3'b0;
            addr_reg   <= 32'b0;
            start_req  <= 1'b0;
        end else begin
            // KEY LOAD (8 x 64-bit)
            if (reg_cs && reg_we && (reg_ctrl == 3'b001)) begin
                key_shadow[key_cnt*64 +: 64] <= reg_wdata;
                if (key_cnt == 3'd7) begin
                    key_active <= key_shadow;
                    key_cnt    <= 3'b0;
                end else begin
                    key_cnt <= key_cnt + 1'b1;
                end
            end

            // ADDRESS LOAD
            if (reg_cs && reg_we && (reg_ctrl == 3'b010)) begin
                addr_reg <= reg_wdata[31:0];
            end

            // START SIGNAL (PULSE STRETCHED)
            if (reg_cs && reg_we && (reg_ctrl == 3'b011)) begin
                start_req <= 1'b1;
            end 
            // Only clear start_req once the pipeline confirms it is done
            else if (done_sync2) begin
                start_req <= 1'b0;
            end
        end
    end

    // =========================================================
    // CDC : START SYNC (100 MHz -> 50 MHz)
    // =========================================================
    reg start_sync1, start_sync2, start_sync3;

    always @(posedge clk_50m or negedge rst_n_50m) begin
        if (!rst_n_50m) begin
            start_sync1 <= 1'b0;
            start_sync2 <= 1'b0;
            start_sync3 <= 1'b0;
        end else begin
            start_sync1 <= start_req;
            start_sync2 <= start_sync1;
            start_sync3 <= start_sync2;
        end
    end

    // Trigger pipeline on the RISING EDGE of the synced signal
    wire start_pipe = start_sync2 && !start_sync3;

    // =========================================================
    // 50 MHz DOMAIN : SNAPSHOT INTO PIPELINE
    // =========================================================
    reg [511:0] key_pipe;
    reg [31:0]  addr_pipe;

    always @(posedge clk_50m or negedge rst_n_50m) begin
        if (!rst_n_50m) begin
            key_pipe  <= 512'b0;
            addr_pipe <= 32'b0;
        end else if (start_pipe) begin
            key_pipe  <= key_active;
            addr_pipe <= addr_reg;
        end
    end

    // =========================================================
    // CRYPTO PIPELINE INSTANCE
    // =========================================================
    wire [63:0] pipe_result;
    wire        pipe_done_50m;

    // Inside ravan_soc_top.v
    // Use the start_pipe (the 50MHz synced pulse) to trigger the engine
    pipeline u_crypto_engine (
        .clk_50m      (clk_50m),
        .rst_n_50m    (rst_n_50m),
        .start        (start_pipe), // <--- CONNECTED HERE
        .address      (addr_pipe),
        .key          (key_pipe),
        .sha_error    (sha_error),
        .clk_100m     (clk_100m),
        .rst_n_100m   (rst_n_100m),
        .final_result (pipe_result),
        .result_valid (pipe_done_50m)
    );
    // =========================================================
    // CDC : RESULT SYNC (50 MHz -> 100 MHz)
    // =========================================================
    always @(posedge clk_100m or negedge rst_n_100m) begin
        if (!rst_n_100m) begin
            done_sync1 <= 1'b0;
            done_sync2 <= 1'b0;
        end else begin
            done_sync1 <= pipe_done_50m;
            done_sync2 <= done_sync1;
        end
    end

    // =========================================================
    // OUTPUT REGISTERS
    // =========================================================
    reg [63:0] out_data;
    reg        out_valid;

    always @(posedge clk_100m or negedge rst_n_100m) begin
        if (!rst_n_100m) begin
            out_data  <= 64'b0;
            out_valid <= 1'b0;
        end else if (done_sync2) begin
            out_data  <= pipe_result;
            out_valid <= 1'b1;
        end else if (reg_cs && reg_we && (reg_ctrl == 3'b011)) begin
            // Reset valid when a new operation starts
            out_valid <= 1'b0;
        end
    end

    assign result_valid = out_valid;
    assign system_ready = !start_req; // Ready when not processing

    // =========================================================
    // BUS READ LOGIC
    // =========================================================
    always @(*) begin
        reg_rdata = 64'h0;
        if (reg_cs && !reg_we) begin
            case (reg_ctrl)
                3'b100:  reg_rdata = out_data;
                3'b101:  reg_rdata = {32'b0, addr_reg};
                default: reg_rdata = 64'hDEAD_BEEF_CAFE_BABE;
            endcase
        end
    end
always @(posedge clk_50m) begin
    if (start_pipe) $display("DEBUG: Pipeline received START signal at %t", $time);
    if (pipe_done_50m) $display("DEBUG: Pipeline finished WORK at %t", $time);
end
endmodule
