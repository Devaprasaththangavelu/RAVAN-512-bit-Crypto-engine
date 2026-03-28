module SRAM_8TU_Top (
    input  wire        CLK, RST_N,
    input  wire [31:0] ADDR_IN,
    input  wire [63:0] DATA_IN,
    input  wire        REQ, WRITE,
    output reg  [63:0] DATA_OUT,
    output wire        ACK,
    input  wire [1:0]  PWR_REQ,
    input  wire        PUF_REQ,
    input  wire        ZEROIZE_IN,
    output wire        READY 
);
    wire ulvr_en, at_en, ready_sig;
    wire [63:0] bank_dout, puf_dout;
    reg  [63:0] bank_dout_pipe; 

    assign READY = ready_sig;

    SRAM_8TU_Controller ctrl (
        .CLK(CLK), .RST_N(RST_N), .PWR_REQ(PWR_REQ),
        .ULVR_EN(ulvr_en), .AT_EN(at_en), .READY(ready_sig)
    );

    // Physical Macro Pair (Total 16KB)
    MEM1_2048X32 sram_lo (
        .CLK(CLK), .CEN(~REQ), .WEN(~WRITE),
        .A(ADDR_IN[13:3]), .D(DATA_IN[31:0]), .Q(bank_dout[31:0])
    );

    MEM1_2048X32 sram_hi (
        .CLK(CLK), .CEN(~REQ), .WEN(~WRITE),
        .A(ADDR_IN[13:3]), .D(DATA_IN[63:32]), .Q(bank_dout[63:32])
    );

    SRAM_8TU_PUF puf (
        .CLK(CLK), .EN(PUF_REQ), .CHALLENGE(ADDR_IN[13:3]), .RESPONSE(puf_dout)
    );

    // --- SECURE PIPELINE LOGIC ---
    always @(posedge CLK or negedge RST_N) begin
        if (!RST_N) 
            bank_dout_pipe <= 64'h0;
        else if (ZEROIZE_IN) // IMMEDIATELY FLUSH THE PIPELINE
            bank_dout_pipe <= 64'h0;
        else
            bank_dout_pipe <= bank_dout;
    end

    assign ACK = REQ && ready_sig;

    always @(*) begin
        if (PUF_REQ)
            DATA_OUT = puf_dout;
        else
            DATA_OUT = bank_dout_pipe;
    end

endmodule