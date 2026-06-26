`timescale 1ns / 1ps

module ID_EX(
input wire clk,
input wire rst,
input wire stall,
input wire [31:0] id_inc_pc, rs1_data, rs2_data, imm,
output reg [31:0] ex_inc_pc, ex_rs1_data, ex_rs2_data,ex_imm
    );
    
always@(posedge clk) begin
if(rst) begin
ex_inc_pc <=32'b0;
 ex_rs1_data <=32'b0;
  ex_rs2_data <=32'b0;
   ex_imm <=32'b0;
end else if (!stall) begin
ex_inc_pc <=id_inc_pc;
ex_rs1_data <=rs1_data;
ex_rs2_data <= rs2_data;
ex_imm <=imm;
end
end    
    
endmodule
