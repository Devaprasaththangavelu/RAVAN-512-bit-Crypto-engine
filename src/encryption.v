module encryption (
    input wire clk, rst, start,         
    input wire [3:0] sel,   
    input wire [63:0] data_in,
    input wire [63:0] k0, k1, k2, k3, k4, k5, k6, k7,
    output reg [63:0] enc_data_out,
    output reg done
);
    reg [63:0] temp_data;
    reg [4:0]  round_ctr;
    reg [2:0]  key_ctr;
    reg [1:0]  state;
    reg [63:0] current_key_slice;

    localparam IDLE = 2'b00;
    localparam BUSY = 2'b01;
    localparam FINISH = 2'b10;

    // Key Selection Mux
    always @* begin
        case(key_ctr)
            3'd0: current_key_slice = k0;
            3'd1: current_key_slice = k1;
            3'd2: current_key_slice = k2;
            3'd3: current_key_slice = k3;
            3'd4: current_key_slice = k4;
            3'd5: current_key_slice = k5;
            3'd6: current_key_slice = k6;
            3'd7: current_key_slice = k7;
            default: current_key_slice = 64'd0;
        endcase
    end

    // Corrected Logic Block (FIXES *E,EXPLPA)
    always @(posedge clk) begin
        if (rst) begin
            enc_data_out <= 0;
            temp_data <= 0;
            state <= IDLE;
            done <= 0;
            round_ctr <= 0;
            key_ctr <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    if (start) begin
                        temp_data <= data_in; // Critical: Load input
                        round_ctr <= 0;
                        key_ctr <= 0;
                        state <= BUSY;
                    end
                end
                BUSY: begin
                    case(sel)
                         4'b0000:temp_data <= (~(temp_data ^ current_key_slice));//1
                    4'b0001:temp_data <= ~(temp_data + current_key_slice);//2
                    4'b0010:temp_data <= {temp_data[50:0], temp_data[63:51]} ^ current_key_slice;//3
                    4'b0011:temp_data <= (temp_data ^ current_key_slice) + 64'hDEADBEEFCAFEBABE;//4
                    4'b0100:temp_data <= ((temp_data ^ current_key_slice) << 16) | ((temp_data ^ current_key_slice) >> 48);//5
                    4'b0101:temp_data <= (~{temp_data[31:0], temp_data[63:32]}) ^ current_key_slice;//6
                    4'b0110:temp_data <= (~(temp_data ^ current_key_slice)) + current_key_slice;//7
                    4'b0111:temp_data <= ( ((temp_data ^ current_key_slice) & 64'hF0F0F0F0F0F0F0F0) >> 4 ) | ( ((temp_data ^ current_key_slice) & 64'h0F0F0F0F0F0F0F0F) << 4 );//8
                    4'b1000:temp_data <= ( (temp_data << current_key_slice[5:0]) | (temp_data >> (64 - current_key_slice[5:0])) ) ^ current_key_slice;//9
                    default:temp_data <= { (temp_data[31:0] ^ current_key_slice[31:0]), (temp_data[63:32] + current_key_slice[63:32]) };
                    endcase
                    
                    if (key_ctr == 3'd7) begin
                        key_ctr <= 0;
                        if (round_ctr == 5'd20) state <= FINISH;
                        else round_ctr <= round_ctr + 1;
                    end else begin
                        key_ctr <= key_ctr + 1;
                    end
                end
                FINISH: begin
                    enc_data_out <= temp_data;
                    done <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule