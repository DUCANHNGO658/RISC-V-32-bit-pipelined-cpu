`timescale 1ns / 1ps

module mux_3to1(
input wire [1:0] sel,
input wire [31:0] ex_rs_data, mem_alu_result,write_reg,
output reg [31:0] out
    );
always@(*) begin
case(sel)
2'b00: out =ex_rs_data;
2'b01: out =write_reg;
2'b10: out =mem_alu_result; 
default: out =ex_rs_data;
endcase
end
endmodule
