module wptr_full #(
    parameter ADDRSIZE = 5
)(
    input  wire wclk, wrst_n, winc,
    input  wire [ADDRSIZE:0] wq2_rptr, // Synced Read Pointer (Gray)
    output reg  wfull,
    output wire [ADDRSIZE-1:0] waddr,  // Binary address to Memory
    output reg  [ADDRSIZE:0] wptr      // Gray pointer to Read domain
);
    reg  [ADDRSIZE:0] wbin;
    wire [ADDRSIZE:0] wgraynext, wbinnext;
    wire wfull_val;

    // --- 1. Binary Counter ---
    assign wbinnext = wbin + (winc & ~wfull); // Only increment if not full
    assign waddr    = wbin[ADDRSIZE-1:0];

    // --- 2. Binary to Gray Conversion ---
    assign wgraynext = (wbinnext >> 1) ^ wbinnext;

    // --- 3. Register Update ---
    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            wbin <= 0;
            wptr <= 0;
        end else begin
            wbin <= wbinnext;
            wptr <= wgraynext;
        end
    end

    // --- 4. Full Flag Logic ---
    // FIFO is full when MSB and 2nd MSB are different, but rest are same.
    // Example: ReadPtr=00xx, WritePtr=11xx -> Full (Wrapped around)
    assign wfull_val = (wgraynext == {~wq2_rptr[ADDRSIZE:ADDRSIZE-1], wq2_rptr[ADDRSIZE-2:0]});

    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) wfull <= 1'b0;
        else         wfull <= wfull_val;
    end
endmodule
