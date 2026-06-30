`timescale 1ns / 1ps

module control_unit #(parameter OP_WIDTH=7)(
input wire [OP_WIDTH-1:0] opcode,
output reg regwrite, aluSrc,memread,memwrite, memtoreg,branch,jump,
output reg [1:0] aluop
    );
    
always@(*) begin 
case(opcode) // R type add, sub, and, or, xor, sll, srl, slt
7'b0110011: begin
regwrite = 1'b1;
aluSrc = 1'b0;
memread = 1'b0;
memwrite = 1'b0;
branch=1'b0;
jump = 1'b0;
aluop=2'b10;   
end
7'b0010011: begin // I Type addi, andi, slti
regwrite =1'b1;
aluSrc =1'b1;
memread= 1'b0;
memwrite = 1'b0;
memtoreg = 1'b0;
branch = 1'b0;
jump =1'b0;
aluop =2'b11;
end 
7'b0000011: begin // lw
regwrite =1'b1;
aluSrc = 1'b1;
memread =1'b1;
memwrite =1'b0;
memtoreg =1'b1;
branch =1'b0;
jump = 1'b0;
aluop =2'b00;
end
7'b0100011: begin //sw
regwrite = 1'b0;
aluSrc =1'b1;
memread = 1'b0;
memwrite =1'b1;
memtoreg = 1'bx;
branch =1'b0;
jump =1'b0;
aluop =2'b00;
end
7'b1100011: begin //beq, bne
regwrite =1'b0;
aluSrc =1'b0;
memread =1'b0;
memwrite =1'b0;
memtoreg =1'bx;
branch =1'b1;
jump =1'b0;
aluop = 2'b01;
end
7'b1101111: begin // jal
regwrite = 1'b1;
aluSrc =1'bx;
memread = 1'b0;
memwrite =1'b0;
memtoreg =1'bx;
branch =1'b0;
jump =1'b1;
aluop =2'b00;
end
default: begin
regwrite =1'b0;
aluSrc =1'b0;
memread =1'b0;
memwrite =1'b0;
memtoreg =1'b0;
branch =1'b0;
jump = 1'b0;
aluop =2'bxx;
end
endcase 
end
endmodule
