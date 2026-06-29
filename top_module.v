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
 
 wire stall;
 wire [WIDTH-1:0] id_inc_pc, id_inst;
 wire [4:0] id_rd;
 
 wire [WIDTH-1:0] ex_inc_pc,ex_rs1_data, ex_rs2_data, ex_imm;
 wire ex_regwrite, ex_aluSrc, ex_memread, ex_memwrite, ex_memtoreg, ex_branch; 
 wire [2:0] ex_alu_signal;
 wire [4:0] ex_rd;
 
 wire [WIDTH-1:0] mem_pc_branch, mem_alu_result, mem_rs2_data;
 wire mem_is_zero, mem_regwrite, mem_memread, mem_memwrite, mem_memtoreg, mem_branch;
 wire [4:0] mem_rd;
 
 wire [31:0] wb_alu_result, wb_read_data;
 wire [4:0] wb_rd;
 wire wb_regwrite, wb_memtoreg;
 
 //program counter
 program_counter pc (
 .clk(clk),
 .rst(rst),
 .pc_write(pc_write),
 .next_pc(next_pc),
 .cur_pc(cur_pc)
 );   
 
 assign inc_pc = cur_pc +4;   
 assign pc_sel = mem_branch & mem_is_zero;
 // pc mux
 Mux pc_mux (
 .in1(mem_pc_branch),
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
.opcode(id_inst[6:0]),
.regwrite(regwrite),
.aluSrc(aluSrc),
.memread(memread),
.memwrite(memwrite),
.memtoreg(memtoreg),
.branch(branch),
.jump(jump),
.aluop(aluop)
);

assign id_rd = id_inst[11:7];

//Register
reg_file register_file (
.clk(clk),
.rst(rst),
.regwrite(wb_regwrite),
.rs1_addr(id_inst[19:15]),
.rs2_addr(id_inst[24:20]),
.rd_addr(wb_rd),  // đã chỉnh lại rd
.write_data(write_reg),
.rs1_data(rs1_data),
.rs2_data(rs2_data)
);

//immediate sign extension
assign imm = {{20{id_inst[31]}},id_inst[31:20]};
assign pc_branch = ex_inc_pc + (ex_imm<<2);

//ALU mux
Mux alu_mux (
.in1(ex_imm),
.in2(ex_rs2_data),
.sel(ex_aluSrc),
.out(inB)
);

//ALU control
alu_control alu_con(
.opcode(id_inst[6:0]),
.funct3(id_inst[14:12]),
.funct7(id_inst[31:25]),
.alu_signal(alu_signal)
);

//ALU
ALU alu (
.inA(ex_rs1_data),
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
.addr(mem_alu_result),
.memread(mem_memread),
.memwrite(mem_memwrite),
.write_data(mem_rs2_data),
.read_data(mem_data)
);

//Data mem mux
Mux data_mem_mux (
.in1(wb_read_data),
.in2(wb_alu_result),
.sel(wb_memtoreg),
.out(write_reg)
);

//IF/ID reg
IF_ID if_id (
.clk(clk),
.rst(rst),
.stall(stall),
.inc_pc(inc_pc),
.id_inc_pc(id_inc_pc),
.id_inst(id_inst)
);

//ID/EX reg
ID_EX id_ex(
.clk(clk),
.rst(rst),
.stall(stall),
.id_inc_pc(id_inc_pc),
.rs1_data(rs1_data),
.rs2_data(rs2_data),
.imm(imm),
.regwrite(regwrite), 
.aluSrc(aluSrc),
.memread(memread),
.memwrite(memwrite),
.memtoreg(memtoreg),
.branch(branch),
.alu_signal(alu_signal),
.id_rd(id_rd),
.ex_inc_pc(ex_inc_pc),
.ex_rs1_data(ex_rs1_data),
.ex_rs2_data(ex_rs2_data),
.ex_imm(ex_imm),
.ex_regwrite(ex_regwrite),
.ex_aluSrc(ex_aluSrc),
.ex_memread(ex_memread),
.ex_memwrite(ex_memwrite),
.ex_memtoreg(ex_memtoreg),
.ex_branch(ex_branch),
.ex_alu_signal(ex_alu_signal),
.ex_rd(ex_rd) //update lại rd
);


//EX/MEM
EX_MEM ex_mem (
.clk(clk),
.rst(rst),
.stall(stall),
.pc_branch(pc_branch),
.is_zero(is_zero),
.alu_result(alu_result),
.ex_rs2_data(ex_rs2_data),
.ex_regwrite(ex_regwrite),
.ex_memread(ex_memread),
.ex_memwrite(ex_memwrite),
.ex_memtoreg(ex_memtoreg),
.ex_branch(ex_branch),
.ex_rd(ex_rd),
.mem_pc_branch(mem_pc_branch),
.mem_alu_result(mem_alu_result),
.mem_rs2_data(mem_rs2_data),
.mem_is_zero(mem_is_zero),
.mem_regwrite(mem_regwrite),
.mem_memread(mem_memread),
.mem_memwrite(mem_memwrite),
.mem_memtoreg(mem_memtoreg),
.mem_branch(mem_branch),
.mem_rd(mem_rd) //update lại rd
);


//MEM/WB 
MEM_WB mem_wb (
.clk(clk),
.rst(rst),
.stall(stall),
.read_data(mem_data),
.mem_alu_result(mem_alu_result),
.mem_regwrite(mem_regwrite),
.mem_memtoreg(mem_memtoreg),
.mem_rd(mem_rd),
.wb_read_data(wb_read_data),
.wb_alu_result(wb_alu_result),
.wb_regwrite(wb_regwrite),
.wb_memtoreg(wb_memtoreg),
.wb_rd(wb_rd) //update rd
);
endmodule
