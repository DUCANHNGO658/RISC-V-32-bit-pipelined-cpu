`timescale 1ns / 1ps

module ALU(
input wire [31:0] inA,
input wire [31:0] inB,
input wire [2:0] alu_control,
output wire is_zero,
output wire overflow,
output reg [32:0] alu_result
    );
always@(*) begin
case(alu_control)
3'd0: alu_result <= inA + inB;// support add, addi, lw, sw
3'd1: alu_result <= inA - inB; //sub, beq, bne
3'd2: alu_result <= inA & inB; //and, andi
3'd3: alu_result <=inA | inB; //or, ori
3'd4: alu_result <= inA ^ inB; // xor
3'd5: alu_result <= inA <<inB[4:0]; //sll
3'd6: alu_result <= inA >>inB[4:0]; //srl
3'd7: alu_result <= ($signed(inA)< $signed(inB)) ? 32'd1: 32'd0;//slt.slti
default alu_result = 32'h0;
endcase 
end
assign is_zero = (alu_result ==32'd0) ? 1:0;
assign overflow = alu_result[32];
endmodule
