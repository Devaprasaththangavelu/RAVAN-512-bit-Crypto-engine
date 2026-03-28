module pipeline(
    // 50MHz Domain
    input wire clk_50m, rst_n_50m,
    input wire start,           
    input wire [31:0] address,
    input wire [511:0] key,
    output wire sha_error, 

    // 100MHz Domain
    input wire clk_100m, rst_n_100m,
    output wire [63:0] final_result,
    output wire        result_valid
);

    // --- 50MHz Signals ---
    reg cs, we;
    reg [7:0] addr;
    reg [31:0] wr_data;
    wire [31:0] rd_data;
    reg [31:0] hk[0:16]; 
    wire [31:0] mk[0:16];
    
    reg [63:0] pack_buffer;
    reg        pack_toggle; 
    
    reg fifo_wr_en;
    wire fifo_full;

    // FSM + Delay counter
    reg [2:0] state, next_state;
    reg [4:0] sel;
    reg [7:0] delay_cnt; // Increased to 8-bit to be safe
    
    localparam S_IDLE=0, S_WRITE=1, S_WAIT=2, S_READ=3, S_DONE=4;

    sha256 hash_unit (
        .clk(clk_50m), 
        .reset_n(rst_n_50m), 
        .cs(cs), 
        .we(we), 
        .address(addr), 
        .write_data(wr_data), 
        .read_data(rd_data), 
        .error(sha_error)
    );

    // key packing logic
    genvar i;
    generate for (i=0; i<15; i=i+1) assign mk[i] = key[((i+1)*32)-1 : i*32]; endgenerate
    assign mk[15] = address; // Use address as the 16th word

    // --- FSM (50MHz) ---
    always @(posedge clk_50m or negedge rst_n_50m) begin
        if (!rst_n_50m) begin
            state <= S_IDLE; sel <= 0; pack_toggle <= 0;
            pack_buffer <= 0; fifo_wr_en <= 0;
            delay_cnt <= 0;
        end else begin
            state <= next_state;
            fifo_wr_en <= 0; 

            if (state == S_WAIT) 
                delay_cnt <= delay_cnt + 1;
            else 
                delay_cnt <= 0;

            if (state == S_READ && next_state == S_WRITE) 
                sel <= sel + 1;

            if (state == S_IDLE) begin 
                sel <= 0; 
                pack_toggle <= 0; 
            end

            if (state == S_READ) begin
                hk[sel] <= rd_data;
                if (pack_toggle == 0) begin
                    pack_buffer[31:0] <= rd_data;
                    pack_toggle <= 1;
                end else begin
                    pack_buffer[63:32] <= rd_data;
                    pack_toggle <= 0;
                    if (!fifo_full) fifo_wr_en <= 1;
                end
            end
            
            if (state == S_DONE && !fifo_full && pack_toggle == 0) begin
                 pack_buffer <= {32'd0, address}; 
                 fifo_wr_en <= 1;
                 $display("DEBUG: Pipeline reached S_DONE at %t", $time);
            end
        end
    end

    // Combinational FSM
    always @(*) begin
        next_state = state;
        cs = 0; we = 0; addr = {3'b000, sel}; wr_data = 0;
        case (state)
            S_IDLE: begin
                if (start) next_state = S_WRITE;
                else next_state = S_IDLE;
            end
            S_WRITE: begin
                cs = 1; we = 1; 
                wr_data = (sel == 0) ? mk[0] : mk[sel] ^ hk[sel-1];
                next_state = S_WAIT;
            end
            S_WAIT: begin 
                cs = 1; 
                // Increased delay to 80 cycles to ensure SHA core is ready
                if (delay_cnt >= 8'd80) next_state = S_READ;
                else next_state = S_WAIT; 
            end
            S_READ: begin
                cs = 1;
                if (fifo_full && pack_toggle == 1) next_state = S_READ; 
                else if (sel == 15) next_state = S_DONE;
                else next_state = S_WRITE;
            end
            S_DONE: next_state = S_IDLE;
            default: next_state = S_IDLE;
        endcase
    end
    
    // ... rest of your async_fifo and interconnect logic ...
endmodule
