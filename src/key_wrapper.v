module key_wrapper(
    input wire [511:0] key,          // changed to [511:0] for standard convention
    input wire [3:0]   key_sel,
    output reg [63:0]  sliced_key_1,
    output reg [63:0]  sliced_key_2,
    output reg [63:0]  sliced_key_3,
    output reg [63:0]  sliced_key_4,
    output reg [63:0]  sliced_key_5,
    output reg [63:0]  sliced_key_6,
    output reg [63:0]  sliced_key_7,
    output reg [63:0]  sliced_key_8
);

    // Internal wires to hold the raw output from the slicer
    wire [63:0] sk1, sk2, sk3, sk4, sk5, sk6, sk7, sk8;

    // Instantiate the Key Slicer
    // This splits the 512-bit key into 8 chunks
    keyslicer_v1 Slicer (
        .key(key),
        .sliced_key1(sk1), 
        .sliced_key2(sk2), 
        .sliced_key3(sk3), 
        .sliced_key4(sk4),
        .sliced_key5(sk5), 
        .sliced_key6(sk6), 
        .sliced_key7(sk7), 
        .sliced_key8(sk8)
    );

    // The Permutation Logic (The "Mixer")
    always @(*) begin
        case(key_sel)
            4'b0000: begin // Identity (1-8)
                sliced_key_1 = sk1; sliced_key_2 = sk2; sliced_key_3 = sk3; sliced_key_4 = sk4;
                sliced_key_5 = sk5; sliced_key_6 = sk6; sliced_key_7 = sk7; sliced_key_8 = sk8;
            end
            
            4'b0001: begin // Reverse (8-1)
                sliced_key_1 = sk8; sliced_key_2 = sk7; sliced_key_3 = sk6; sliced_key_4 = sk5;
                sliced_key_5 = sk4; sliced_key_6 = sk3; sliced_key_7 = sk2; sliced_key_8 = sk1;
            end
            
            4'b0010: begin // Half Split
                sliced_key_1 = sk1; sliced_key_2 = sk2; sliced_key_3 = sk3; sliced_key_4 = sk4;
                sliced_key_5 = sk8; sliced_key_6 = sk7; sliced_key_7 = sk6; sliced_key_8 = sk5;
            end
            
            4'b0011: begin // Inner Swap
                sliced_key_1 = sk4; sliced_key_2 = sk3; sliced_key_3 = sk2; sliced_key_4 = sk1;
                sliced_key_5 = sk5; sliced_key_6 = sk6; sliced_key_7 = sk7; sliced_key_8 = sk8;
            end
            
            4'b0100: begin // Scramble A
                sliced_key_1 = sk3; sliced_key_2 = sk8; sliced_key_3 = sk1; sliced_key_4 = sk7;
                sliced_key_5 = sk5; sliced_key_6 = sk4; sliced_key_7 = sk6; sliced_key_8 = sk2;
            end
            
            4'b0101: begin // Scramble B
                sliced_key_1 = sk5; sliced_key_2 = sk6; sliced_key_3 = sk7; sliced_key_4 = sk8;
                sliced_key_5 = sk4; sliced_key_6 = sk3; sliced_key_7 = sk2; sliced_key_8 = sk1;
            end
            
            4'b0110: begin // Scramble C
                sliced_key_1 = sk7; sliced_key_2 = sk3; sliced_key_3 = sk2; sliced_key_4 = sk6;
                sliced_key_5 = sk5; sliced_key_6 = sk4; sliced_key_7 = sk8; sliced_key_8 = sk1;
            end
            
            4'b0111: begin // Scramble D
                sliced_key_1 = sk4; sliced_key_2 = sk3; sliced_key_3 = sk2; sliced_key_4 = sk1;
                sliced_key_5 = sk8; sliced_key_6 = sk7; sliced_key_7 = sk6; sliced_key_8 = sk5;
            end
            
            4'b1000: begin // Scramble E
                sliced_key_1 = sk7; 
                sliced_key_2 = sk2; 
                sliced_key_3 = sk3; 
                sliced_key_4 = sk8;
                sliced_key_5 = sk4;
                 sliced_key_6 = sk6; 
                 sliced_key_7 = sk1; 
                 sliced_key_8 = sk5;
            end
            
           // ... existing cases 0 to 8 ...

            4'b1001: begin // Case 9: Swap Halves (Inner)
                sliced_key_1 = sk3; sliced_key_2 = sk4; sliced_key_3 = sk1; sliced_key_4 = sk2;
                sliced_key_5 = sk7; sliced_key_6 = sk8; sliced_key_7 = sk5; sliced_key_8 = sk6;
            end

            4'b1010: begin // Case 10 (A): Interleaved Swap
                sliced_key_1 = sk2; sliced_key_2 = sk1; sliced_key_3 = sk4; sliced_key_4 = sk3;
                sliced_key_5 = sk6; sliced_key_6 = sk5; sliced_key_7 = sk8; sliced_key_8 = sk7;
            end

            4'b1011: begin // Case 11 (B): Rotate Left by 1
                sliced_key_1 = sk2; sliced_key_2 = sk3; sliced_key_3 = sk4; sliced_key_4 = sk5;
                sliced_key_5 = sk6; sliced_key_6 = sk7; sliced_key_7 = sk8; sliced_key_8 = sk1;
            end

            4'b1100: begin // Case 12 (C): Rotate Right by 1
                sliced_key_1 = sk8; sliced_key_2 = sk1; sliced_key_3 = sk2; sliced_key_4 = sk3;
                sliced_key_5 = sk4; sliced_key_6 = sk5; sliced_key_7 = sk6; sliced_key_8 = sk7;
            end

            4'b1101: begin // Case 13 (D): Ends to Center
                sliced_key_1 = sk8; sliced_key_2 = sk7; sliced_key_3 = sk1; sliced_key_4 = sk2;
                sliced_key_5 = sk3; sliced_key_6 = sk4; sliced_key_7 = sk5; sliced_key_8 = sk6;
            end

            4'b1110: begin // Case 14 (E): Center to Ends
                sliced_key_1 = sk4; sliced_key_2 = sk5; sliced_key_3 = sk3; sliced_key_4 = sk6;
                sliced_key_5 = sk2; sliced_key_6 = sk7; sliced_key_7 = sk1; sliced_key_8 = sk8;
            end

            4'b1111: begin // Case 15 (F): Total Chaos (Evens/Odds)
                sliced_key_1 = sk2; sliced_key_2 = sk4; sliced_key_3 = sk6; sliced_key_4 = sk8;
                sliced_key_5 = sk1; sliced_key_6 = sk3; sliced_key_7 = sk5; sliced_key_8 = sk7;
            end
            
            default: begin // Default Safety (Identity)
                 sliced_key_1 = sk1; sliced_key_2 = sk2; sliced_key_3 = sk3; sliced_key_4 = sk4;
                 sliced_key_5 = sk5; sliced_key_6 = sk6; sliced_key_7 = sk7; sliced_key_8 = sk8;
            end
        endcase
    end

endmodule
