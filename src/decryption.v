module decryption (
     input wire clk,
    input wire rst,
    input wire start,         
    input wire [3:0] sel,   
    input wire [63:0] data_in,
    input  wire [63:0] k0, k1, k2, k3, k4, k5, k6, k7,
    output reg [63:0] dec_data_out,
    output reg done
);

    // --- Signals ---
  
    reg [63:0] temp_data;
    
    // --- Counters (Initialize to Max!) ---
    reg [4:0] round_ctr; // Will count 20 down to 0
    reg [2:0] key_ctr;   // Will count 7 down to 0
    reg [1:0] state;

    localparam IDLE = 2'b00;
    localparam BUSY = 2'b01;
    localparam FINISH = 2'b10;

    // --- Key Slicer ---
    

    // --- Key Mux ---
    reg [63:0] current_key_slice;
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

    // --- Main Logic ---
    always @(posedge clk) begin
        if (rst) begin
            dec_data_out <= 0;
            temp_data <= 0;
            state <= IDLE;
            done <= 0;
            round_ctr <= 5'd20; // Reset to Max
            key_ctr <= 3'd7;    // Reset to Max
        end else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    if (start) begin
                        temp_data <= data_in; 
                        // Start counters at the END
                        round_ctr <= 5'd20;
                        key_ctr <= 3'd7;
                        state <= BUSY;
                    end
                end

                BUSY: begin
                    // 1. INVERSE Math Operation
                    // Encryption was: (~(data ^ key))
                    // Inverse is:     (~data) ^ key
                    case(sel)
                    4'b0000:temp_data <= (~temp_data) ^ current_key_slice;//1
                    4'b0001:temp_data <= (~temp_data) - current_key_slice;//2
                    4'b0010:temp_data <= ((temp_data ^ current_key_slice) >> 13) | ((temp_data ^ current_key_slice) << 51);//3
                    4'b0011:temp_data <= (temp_data - 64'hDEADBEEFCAFEBABE) ^ current_key_slice;//4
                    4'b0100:temp_data <= ((temp_data >> 16) | (temp_data << 48)) ^ current_key_slice;//5
                    4'b0101:temp_data <= ( (~(temp_data ^ current_key_slice)) << 32 ) | ( (~(temp_data ^ current_key_slice)) >> 32 );//6
                    4'b0110:temp_data <= ~((temp_data - current_key_slice) ^ current_key_slice);//7
                    4'b0111:temp_data <= ( ((temp_data & 64'hF0F0F0F0F0F0F0F0) >> 4) | ((temp_data & 64'h0F0F0F0F0F0F0F0F) << 4) ) ^ current_key_slice;//8
                    4'b1000:temp_data <= ( (temp_data ^ current_key_slice) >> current_key_slice[5:0] ) | ( (temp_data ^ current_key_slice) << (64 - current_key_slice[5:0]) );//9
                    default:temp_data <= {(temp_data[31:0] - current_key_slice[63:32]),(temp_data[63:32] ^ current_key_slice[31:0]) };
                    endcase
                    // 2. Decrement Logic (Counting Down)
                    if (key_ctr == 3'd0) begin
                        key_ctr <= 3'd7; // Reset Key Counter to Top
                        
                        // Check if Rounds are finished
                        if (round_ctr == 5'd0) begin
                            state <= FINISH;
                        end else begin
                            round_ctr <= round_ctr - 1; // Decrement Round
                        end
                    end else begin
                        key_ctr <= key_ctr - 1; // Decrement Key
                    end
                end

                FINISH: begin
                    dec_data_out <= temp_data;
                    done <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
