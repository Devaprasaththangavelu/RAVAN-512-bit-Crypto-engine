module sync #(
    parameter ADDRSIZE = 5
)(
    input  wire clk,      // Destination clock
    input  wire rst_n,    // Destination reset
    input  wire [ADDRSIZE:0] ptr_in, // Gray pointer from other domain
    output reg  [ADDRSIZE:0] ptr_out // Synchronized pointer
);
    reg [ADDRSIZE:0] q1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            q1 <= 0;
            ptr_out <= 0;
        end else begin
            q1 <= ptr_in;
            ptr_out <= q1; // 2-stage synchronizer to remove metastability
        end
    end
endmodule
