`timescale 1ns / 1ps
module EX_MEM(
input wire clk,
input wire rst,

input wire is_zero,
input wire ex_regwrite, ex_memread, ex_memwrite, ex_branch,
input wire [1:0] ex_memtoreg,
input wire [4:0] ex_rd,
input wire [31:0] pc_branch,alu_result,ex_rs2_data, ex_inc_pc,
output reg mem_is_zero,
output reg [31:0] mem_pc_branch, mem_alu_result,mem_rs2_data, mem_inc_pc,
output reg mem_regwrite, mem_memread, mem_memwrite, mem_branch,
output reg [1:0] mem_memtoreg,
output reg [4:0] mem_rd
    );
    
always@(posedge clk) begin
if(rst) begin
mem_pc_branch <=32'b0;
mem_alu_result <=32'b0;
mem_rs2_data <=32'b0;
mem_inc_pc <=32'b0;
mem_is_zero<=1'b0;
mem_regwrite <=1'b0;
mem_memread <=1'b0;
mem_memwrite <=1'b0;
mem_memtoreg <=2'b00;
mem_branch <=1'b0;
mem_rd <=5'b0;
end else begin
mem_pc_branch <=pc_branch;
mem_alu_result <=alu_result;
mem_rs2_data <=ex_rs2_data;
mem_inc_pc <= ex_inc_pc;
mem_is_zero<=is_zero;
mem_regwrite <=ex_regwrite;
mem_memread <=ex_memread;
mem_memwrite <=ex_memwrite;
mem_memtoreg <=ex_memtoreg;
mem_branch <=ex_branch;
mem_rd <=ex_rd;
 end
end     
endmodule
