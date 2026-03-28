module rptr_empty #(
    parameter ADDRSIZE = 5
)(
    input  wire rclk, rrst_n, rinc,
    input  wire [ADDRSIZE:0] rq2_wptr, // Synced Write Pointer (Gray)
    output reg  rempty,
    output wire [ADDRSIZE-1:0] raddr,  // Binary address to Memory
    output reg  [ADDRSIZE:0] rptr      // Gray pointer to Write domain
);
    reg  [ADDRSIZE:0] rbin;
    wire [ADDRSIZE:0] rgraynext, rbinnext;

    // --- 1. Binary Counter ---
    assign rbinnext = rbin + (rinc & ~rempty); // Only increment if not empty
    assign raddr    = rbin[ADDRSIZE-1:0];      // Output to memory address

    // --- 2. Binary to Gray Conversion ---
    assign rgraynext = (rbinnext >> 1) ^ rbinnext;

    // --- 3. Register Update ---
    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            rbin <= 0;
            rptr <= 0;
        end else begin
            rbin <= rbinnext;
            rptr <= rgraynext;
        end
    end

    // --- 4. Empty Flag Logic ---
    // FIFO is empty when Read Gray Ptr == Synced Write Gray Ptr
    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) rempty <= 1'b1; // Reset to Empty = 1
        else         rempty <= (rgraynext == rq2_wptr);
    end
endmodule
