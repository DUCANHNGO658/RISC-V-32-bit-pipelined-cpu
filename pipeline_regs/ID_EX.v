`timescale 1ns / 1ps

module ID_EX(
input wire clk,
input wire rst,
input wire stall,
input wire pc_sel,
input wire regwrite, aluSrc, memread, memwrite, branch,
input wire [1:0] memtoreg,
input wire [2:0] id_funct3,
input wire [2:0] alu_signal,
input wire [4:0] id_rd,id_rs1_addr, id_rs2_addr,
input wire [31:0] id_inc_pc, rs1_data, rs2_data, imm,
output reg [31:0] ex_inc_pc, ex_rs1_data, ex_rs2_data,ex_imm,
output reg ex_regwrite, ex_aluSrc, ex_memread, ex_memwrite, ex_branch,
output reg [1:0] ex_memtoreg, 
output reg [2:0] ex_funct3,
output reg [2:0] ex_alu_signal,
output reg [4:0] ex_rd,ex_rs1_addr,ex_rs2_addr
    );
    
always@(posedge clk) begin
if(rst || pc_sel) begin
ex_inc_pc <=32'b0;
 ex_rs1_data <=32'b0;
  ex_rs2_data <=32'b0;
   ex_imm <=32'b0;
   ex_regwrite <=1'b0;
    ex_aluSrc <=1'b0;
     ex_memread <=1'b0;
      ex_memwrite <=1'b0;
       ex_memtoreg <=2'b00;
      ex_branch <=1'b0; 
      ex_alu_signal <=3'b0;
      ex_rd <=5'b0;
      ex_rs1_addr <=5'b0;
      ex_rs2_addr <=5'b0;
      ex_funct3 <= 3'b0;
end else begin 
if(stall) begin // stall thì set về 0 hết, 
ex_regwrite <=1'b0;
ex_aluSrc <=1'b0;
ex_memread <=1'b0;
ex_memwrite <=1'b0;
ex_memtoreg <=2'b00;
ex_branch <=1'b0;
ex_alu_signal <=3'b0;
ex_rd <= 5'b0;
ex_rs1_addr <= 5'b0;
ex_rs2_addr <= 5'b0;
ex_funct3 <=3'b0;
ex_inc_pc <= ex_inc_pc;
ex_rs1_data <= ex_rs1_data;
ex_rs2_data <= ex_rs2_data;
ex_imm <= ex_imm;
end else begin
ex_inc_pc <= id_inc_pc;
ex_rs1_data   <= rs1_data;
ex_rs2_data   <= rs2_data;
ex_imm        <= imm;
ex_regwrite <= regwrite;
ex_aluSrc <= aluSrc;
ex_memread <= memread;
ex_memwrite <= memwrite;
ex_memtoreg <= memtoreg;
ex_branch <= branch;
ex_funct3 <= id_funct3;
ex_alu_signal <= alu_signal;
ex_rd <= id_rd;
ex_rs1_addr <= id_rs1_addr;
ex_rs2_addr <= id_rs2_addr;
end    
 end
 end   
endmodule
