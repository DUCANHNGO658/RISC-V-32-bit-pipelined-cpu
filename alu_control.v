`timescale 1ns / 1ps

module alu_control(
input wire [6:0] opcode, input wire [2:0] funct3, input wire [6:0] funct7,
output reg [2:0] alu_signal
    );
    
always@(*) begin
case(opcode) 
7'b0110011: begin // R type
case(funct3)
3'b000: if(funct7==7'b0000000) alu_signal =  3'd0; // add
else alu_signal = 3'd1; //sub
3'b001: alu_signal = 3'd5; //sll
3'b100: alu_signal = 3'd4; //xor
3'b101: alu_signal=3'd6; //srl
3'b110: alu_signal = 3'd3; //or
3'b111: alu_signal = 3'd2; //and
default: alu_signal = 3'd0;
endcase
end
7'b0010011: begin // I type addi, andi,slti, ori
case(funct3)
3'b000: alu_signal = 3'd0; //addi
3'b111: alu_signal = 3'd2; //andi
3'b010: alu_signal = 3'd7; //slti
3'b110: alu_signal = 3'd3; //ori
default: alu_signal = 3'd0;
endcase
end
7'b0000011: alu_signal = 3'd0; //lw  
7'b0100011: alu_signal = 3'd0; //S type sw
7'b1100011: alu_signal = 3'd1; // B type beq, bne
7'b1101111: alu_signal = 3'd0; // J type để tạm xử lý sau
default: alu_signal = 3'd0;
endcase
end    
endmodule
