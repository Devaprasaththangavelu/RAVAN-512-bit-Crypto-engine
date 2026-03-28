module SRAM_8TU_Controller (
    input  wire        CLK,
    input  wire        RST_N,
    input  wire [1:0]  PWR_REQ,
    output reg         ULVR_EN,
    output reg         AT_EN,
    output reg         READY 
);
    typedef enum reg [1:0] {NORMAL=2'b00, ULVR_HOLD=2'b01, RECOVERY=2'b10} state_t;
    state_t state;
    reg [3:0] wait_cnt;

    always @(posedge CLK or negedge RST_N) begin
        if (!RST_N) begin
            state <= NORMAL;
            ULVR_EN <= 1'b0;
            AT_EN   <= 1'b0;
            READY   <= 1'b0; // Start not ready until reset clears
            wait_cnt <= 4'd0;
        end else begin
            case (state)
                NORMAL: begin
                    READY   <= 1'b1;
                    ULVR_EN <= 1'b0;
                    AT_EN   <= 1'b0;
                    if (PWR_REQ == 2'b10) state <= ULVR_HOLD;
                end

                ULVR_HOLD: begin
                    ULVR_EN <= 1'b1; 
                    READY   <= 1'b0; 
                    if (PWR_REQ == 2'b00) begin
                        state <= RECOVERY;
                        wait_cnt <= 4'd0;
                        AT_EN <= 1'b1; 
                    end
                end

                RECOVERY: begin
                    ULVR_EN <= 1'b0;
                    AT_EN   <= 1'b1; 
                    READY   <= 1'b0;
                    if (wait_cnt >= 4'd8) begin 
                        state <= NORMAL;
                        AT_EN <= 1'b0;
                    end else begin
                        wait_cnt <= wait_cnt + 1'b1;
                    end
                end
                default: state <= NORMAL;
            endcase
        end
    end
endmodule