`timescale 1ns / 1ps
module EX_MEM(
input wire clk,
input wire rst,
input wire stall,
input wire is_zero,
input wire [31:0] pc_branch,alu_result,ex_rs2_data,
output reg mem_is_zero,
output reg [31:0] mem_pc_branch, mem_alu_result,mem_rs2_data
    );
    
always@(posedge clk) begin
if(rst) begin
mem_pc_branch <=32'b0;
mem_alu_result <=32'b0;
mem_rs2_data <=32'b0;
mem_is_zero<=1'b0;
end else if (!stall) begin
mem_pc_branch <=pc_branch;
mem_alu_result <=alu_result;
mem_rs2_data <=ex_rs2_data;
mem_is_zero <= is_zero;
end
end    
    
endmodule
