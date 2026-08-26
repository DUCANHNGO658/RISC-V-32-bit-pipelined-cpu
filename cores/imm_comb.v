`timescale 1ns / 1ps

module imm_comb(
input wire [31:0] id_inst,
output reg [31:0] imm_out
    );
wire [6:0] opcode = id_inst[6:0];

always@(*) begin
case (opcode) 
//I type addi, lw
7'b0010011, 7'b0000011: imm_out = {{20{id_inst[31]}},id_inst[31:20]};

//S type; sw
7'b0100011: imm_out = {{20{id_inst[31]}},id_inst[31:25],id_inst[11:7]};

//B type: beq, bne chèn thêm 0 vào imm[0]
7'b1100011: imm_out ={{20{id_inst[31]}},id_inst[7],id_inst[30:25],id_inst[11:8],1'b0};

 // J type: jal 
 7'b1101111: imm_out = {{12{id_inst[31]}}, id_inst[19:12], id_inst[20], id_inst[30:21], 1'b0};
default: // R type
imm_out = 32'b0;
endcase
end
endmodule
