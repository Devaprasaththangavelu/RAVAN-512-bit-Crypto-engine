module MEM1_2048X32 (
    input  wire        CLK, CEN, WEN,
    input  wire [10:0] A,
    input  wire [31:0] D,
    output reg  [31:0] Q
);
    reg [31:0] internal_mem [0:2047];
    always @(posedge CLK) begin
        if (!CEN) begin // Active low
            if (!WEN) internal_mem[A] <= D;
            else      Q <= internal_mem[A];
        end
    end
endmodule