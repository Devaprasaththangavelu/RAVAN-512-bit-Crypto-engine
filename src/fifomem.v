module fifomem #(
    parameter DATASIZE = 32, // Width of data (32 or 512)
    parameter ADDRSIZE = 5   // Depth = 2^ADDRSIZE (e.g., 4 = 16 locations)
)(
    input  wire wclk, wclken,
    input  wire [ADDRSIZE-1:0] waddr, raddr,
    input  wire [DATASIZE-1:0] wdata,
    output wire [DATASIZE-1:0] rdata
);
    // Declare the RAM array
    reg [DATASIZE-1:0] mem [0:(1<<ADDRSIZE)-1];

    // Read is combinational (standard for minimal latency)
    assign rdata = mem[raddr];

    // Write is synchronous to wclk
    always @(posedge wclk) begin
        if (wclken) begin
            mem[waddr] <= wdata;
        end
    end
endmodule
