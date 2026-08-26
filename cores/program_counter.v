`timescale 1ns / 1ps
module program_counter(
input wire clk,
 input wire rst,
 input wire pc_write, //1 allow pc to update, 0 stall
 input wire [31:0] next_pc, //address to jump (from PC + 4 or jump)
 output reg [31:0] cur_pc  //cur pc address
    );
 
 
 always@(posedge clk or posedge rst) begin 
 if(rst) cur_pc <= 32'h0;
 else begin
 if(pc_write) //update when not stall
 cur_pc <=next_pc;
 end
 end
endmodule
