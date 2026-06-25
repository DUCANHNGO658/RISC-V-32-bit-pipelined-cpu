`timescale 1ns / 1ps

module top_module #(parameter WIDTH = 32)(
input wire clk,
input wire rst,
input wire [WIDTH-1:0] next_pc,
output wire [WIDTH-1: 0] cur_pc
    );
 wire pc_write;
 wire [WIDTH-1:0] inc_pc; // pc + 4
 wire [WIDTH-1:0] pc_branch;
 wire pc_sel;
 wire [WIDTH-1:0] inst;
 
 wire regwrite; 
 wire aluSrc;
 wire memread;
 wire memwrite;
 wire memtoreg;
 wire branch;
 wire jump;
 wire [1:0] aluop;
 
 
 wire [WIDTH-1:0] write_data;
 wire [WIDTH-1:0] rs1_data;
 wire [WIDTH-1:0] rs2_data;

 wire [WIDTH-1:0] imm;
 wire [WIDTH-1:0] inB;
 
 wire [2:0] alu_signal;
 wire is_zero;
 wire overflow;
 wire [WIDTH-1:0] alu_result;
 
 wire [WIDTH-1:0] mem_data;
 wire [WIDTH-1:0] write_reg; 
 //program counter
 program_counter pc (
 .clk(clk),
 .rst(rst),
 .pc_write(pc_write),
 .next_pc(next_pc),
 .cur_pc(cur_pc)
 );   
 
 assign inc_pc = cur_pc +4;   
 // pc mux
 Mux pc_mux (
 .in1(pc_branch),
 .in2(inc_pc),
 .sel(pc_sel),
 .out(next_pc)
 );

//instruction memory
inst_mem ins_m(
.addr(cur_pc),
.inst(inst)
);

//control unit
control_unit cont(
.opcode(inst[6:0]),
.regwrite(regwrite),
.aluSrc(aluSrc),
.memread(memread),
.memwrite(memwrite),
.memtoreg(memtoreg),
.branch(branch),
.jump(jump),
.aluop(aluop)
);

//Register
reg_file register_file (
.clk(clk),
.rst(rst),
.regwrite(regwrite),
.rs1_addr(inst[19:15]),
.rs2_addr(inst[24:20]),
.rd_addr(inst[11:7]),
.write_data(write_reg),
.rs1_data(rs1_data),
.rs2_data(rs2_data)
);

//immediate sign extension
assign imm = {{20{inst[31]}},inst[31:20]};
assign pc_branch = inc_pc + (imm<<2);

//ALU mux
Mux alu_mux (
.inA(imm),
.inB(rs2_data),
.sel(aluSrc),
.out(inB)
);

//ALU control
alu_control alu_con(
.opcode(inst[6:0]),
.funct3(inst[14:12]),
.funct7(inst[31:25]),
.alu_signal(alu_signal)
);

//ALU
ALU alu (
.inA(rs1_data),
.inB(inB),
.alu_control(alu_signal),
.is_zero(is_zero),
.overflow(overflow),
.alu_result(alu_result)
);

//Data memory
data_memory data_mem(
.clk(clk),
.rst(rst),
.addr(alu_result),
.memread(memread),
.memwrite(memwrite),
.write_data(rs2_data),
.read_data(mem_data)
);

//Data mem mux
Mux data_mem_mux (
.inA(mem_data),
.inB(alu_result),
.sel(memtoreg),
.out(write_reg)
);
endmodule
