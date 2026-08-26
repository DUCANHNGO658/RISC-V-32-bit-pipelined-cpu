`timescale 1ns / 1ps

module MEM_WB(
input wire clk,
input wire rst,
input wire [4:0] mem_rd,
input wire mem_regwrite,
input wire [1:0] mem_memtoreg,
input wire [31:0] read_data, mem_alu_result,mem_inc_pc,
output reg [31:0] wb_read_data, wb_alu_result,wb_inc_pc,
output reg wb_regwrite,
output reg [1:0] wb_memtoreg,
output reg [4:0] wb_rd
    );
    
    always@(posedge clk) begin
    if(rst) begin
   wb_read_data <= 32'b0;
   wb_alu_result <= 32'b0;
   wb_inc_pc <=32'b0;
   wb_regwrite <=1'b0;
   wb_memtoreg <=2'b00;
   wb_rd <=5'b0;
    end else begin
   wb_read_data <= read_data;
   wb_alu_result <= mem_alu_result;
   wb_inc_pc <= mem_inc_pc;
   wb_regwrite <=mem_regwrite;
   wb_memtoreg <=mem_memtoreg;
   wb_rd <=mem_rd;
    end
    end
endmodule
