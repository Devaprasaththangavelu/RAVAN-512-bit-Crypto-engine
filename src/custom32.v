module custom32(
  input clk,
  input [3:0]key,
  output reg[31:0]custkey
);
  
  always @(*)
    begin
      case(key)
        4'b0000:custkey=32'h8899AABB;
        4'b0001:custkey=32'hCCDDEEFF;
        4'b0010:custkey=32'hABCD1234;
        4'b0011:custkey=32'hA1B2C3D4;
        4'b0100:custkey=32'h5E6F7081;
        4'b0101:custkey=32'h9A0BCDEF;
        4'b0110:custkey=32'h12345678;
        4'b0111:custkey=32'h89ABCDEF;
        4'b1000:custkey=32'h0F1E2D3C;
        4'b1001:custkey=32'h4B5A6978;
        4'b1010:custkey=32'hFEDCBA98;
        4'b1011:custkey=32'h76543210;
        4'b1100:custkey=32'hDEADBEEF;
        4'b1101:custkey=32'hCAFEBABE;
        4'b1110:custkey=32'h00112233;
        4'b1111:custkey=32'h44556677;
     
        default:custkey=32'h00000000;
      endcase 
    end
endmodule
        