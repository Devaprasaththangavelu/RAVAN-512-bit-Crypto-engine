module SRAM_8TU_PUF (
    input  wire        CLK,
    input  wire        EN,           // PUF Enable
    input  wire [10:0] CHALLENGE,    // Address as challenge
    output reg  [63:0] RESPONSE      // Unique device key
);
    reg [63:0] entropy_table [2047:0];

    initial begin
        for (int i = 0; i < 2048; i++) 
            entropy_table[i] = {$urandom, $urandom};
    end

    always @(posedge CLK) begin
        if (EN) RESPONSE <= entropy_table[CHALLENGE];
    end
endmodule