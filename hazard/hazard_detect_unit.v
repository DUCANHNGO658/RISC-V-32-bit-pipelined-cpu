`timescale 1ns / 1ps

module hazard_detect(
input wire [4:0] rs1_addr, rs2_addr,ex_rd,
input wire ex_memread,
output reg stall
    );

always@(*) begin 
if(ex_memread==1'b1 && ((ex_rd == rs1_addr) || (ex_rd ==rs2_addr)) &&(ex_rd!=5'b0) ) 
stall =1'b1;
else stall =1'b0;
end    
endmodule
