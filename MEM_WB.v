`timescale 1ns / 1ps

module MEM_WB(
input wire clk,
input wire rst,
input wire stall,
input wire [31:0] read_data, mem_alu_result,
output reg [31:0] wb_read_data, wb_alu_result
    );
    
    always@(posedge clk) begin
    if(rst) begin
   wb_read_data <= 32'b0;
   wb_alu_result <= 32'b0;
    end else if (!stall) begin
    wb_read_data <=read_data;
    wb_alu_result <=mem_alu_result;
    end
    end
endmodule
