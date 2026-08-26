`timescale 1ns / 1ps

module forwarding(
input wire [4:0] ex_rs1,ex_rs2, mem_rd, // 1 cycle ahead
input wire mem_regwrite,
input wire [4:0] wb_rd, //2 cycle
input wire wb_regwrite,
output reg [1:0] forwardA, forwardB
    );
    

always@(*) begin
forwardA =2'b00; //no forward
forwardB =2'b00;

if(mem_regwrite &&( mem_rd != 5'b0) && (mem_rd == ex_rs1)) 
forwardA = 2'b10;
 else if (wb_regwrite && (wb_rd !=5'b0 ) && (wb_rd ==ex_rs1))
forwardA =2'b01;

  if (mem_regwrite && (mem_rd != 5'b0) &&( mem_rd ==ex_rs2))
forwardB=2'b10;
else if(wb_regwrite && (wb_rd !=5'b0) && (wb_rd ==ex_rs2))
forwardB =2'b01;

end
endmodule
