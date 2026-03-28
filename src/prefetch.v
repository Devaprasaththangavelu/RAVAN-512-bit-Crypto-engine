module SRAM_8TU_Prefetcher (
    input  wire        CLK,
    input  wire [31:0] REQ_ADDR,
    input  wire        REQ_VALID,
    input  wire [63:0] BANK_DATA,
    output reg  [63:0] PREF_DATA,
    output reg         PREF_HIT
);
    reg [31:0] predicted_addr;
    reg [63:0] buffer;

    always @(posedge CLK) begin
        if (REQ_VALID) begin
            PREF_HIT <= (REQ_ADDR == predicted_addr);
            buffer   <= BANK_DATA;
            predicted_addr <= REQ_ADDR + 32'd8;
        end
    end
    assign PREF_DATA = buffer;
endmodule