`timescale 1ns / 1ps

module top_module #(parameter WIDTH = 32)(
input wire clk,
input wire rst,
output wire [WIDTH-1: 0] cur_pc
    );
    
 wire pc_write;
 wire [WIDTH-1:0] inc_pc, next_pc; // pc + 4
 wire [WIDTH-1:0] pc_branch;
 wire pc_sel;
 wire [WIDTH-1:0] inst;
 
 wire regwrite; 
 wire aluSrc;
 wire memread;
 wire memwrite;
 wire [1:0] memtoreg;
 wire branch;
 wire jump;

 
 wire [WIDTH-1:0] rs1_data;
 wire [WIDTH-1:0] rs2_data;

 wire [WIDTH-1:0] imm;
 
 wire [2:0] alu_signal;
 wire is_zero;
 wire [WIDTH-1:0] alu_result;
 
 wire [WIDTH-1:0] mem_data;
 wire [WIDTH-1:0] write_reg; 
 
 wire stall;
 wire [WIDTH-1:0] id_inc_pc, id_inst;
 wire [4:0] id_rd;
 
 wire [WIDTH-1:0] ex_inc_pc,ex_rs1_data, ex_rs2_data, ex_imm;
 wire ex_regwrite, ex_aluSrc, ex_memread, ex_memwrite, ex_branch; 
 wire [1:0] ex_memtoreg;
 wire [2:0] ex_alu_signal, ex_funct3;
 wire [4:0] ex_rd, ex_rs1_addr, ex_rs2_addr;
 
 wire [WIDTH-1:0] mem_pc_branch, mem_alu_result, mem_rs2_data, mem_inc_pc;
 wire mem_is_zero, mem_regwrite, mem_memread, mem_memwrite, mem_branch;
 wire [1:0] mem_memtoreg;
 wire [4:0] mem_rd;
 wire [2:0] mem_funct3;
 wire [31:0] mem_forward_data;
 
 wire [31:0] wb_alu_result, wb_read_data, wb_inc_pc;
 wire [4:0] wb_rd;
 wire wb_regwrite;
 wire [1:0] wb_memtoreg;
 
 wire [1:0] forwardA,forwardB;
 wire [31:0] inA,inb, in_final;
 
 wire [31:0] id_pc_jump;
 
 assign id_pc_jump = (id_inc_pc-32'd4) +imm;
 assign pc_write = !stall;
 //program counter
 program_counter pc (
 .clk(clk),
 .rst(rst),
 .pc_write(pc_write),
 .next_pc(next_pc),
 .cur_pc(cur_pc)
 );   
 
 assign inc_pc = cur_pc +4;   
 assign pc_sel = mem_branch & ((mem_funct3 ==3'b000) ? mem_is_zero: !mem_is_zero);
// // pc mux
// Mux pc_mux (
// .in1(mem_pc_branch),
// .in2(inc_pc),
// .sel(pc_sel),
// .out(next_pc)
// );

assign next_pc = pc_sel ? mem_pc_branch : jump ? id_pc_jump : inc_pc;
 
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
.jump(jump)
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
imm_comb imm_c (
.id_inst(id_inst),
.imm_out(imm)
);
assign pc_branch = (ex_inc_pc -32'd4) + ex_imm; //đã chèn 1 bit 0 ở cuối để khỏi phải shift left 2 

//ALU mux
Mux alu_mux (
.in1(ex_imm),
.in2(inb),
.sel(ex_aluSrc),
.out(in_final)
);

assign mem_forward_data = (mem_memtoreg == 2'b10) ? mem_inc_pc : mem_alu_result;

//ALU mux inA
mux_3to1 muxa (
.sel(forwardA),
.ex_rs_data(ex_rs1_data),
.mem_alu_result(mem_forward_data),
.write_reg(write_reg),
.out(inA)
);

mux_3to1 muxb (
.sel(forwardB),
.ex_rs_data(ex_rs2_data),
.mem_alu_result(mem_forward_data),
.write_reg(write_reg),
.out(inb)
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
.inA(inA),
.inB(in_final),
.alu_control(ex_alu_signal),
.is_zero(is_zero),
.alu_result(alu_result)
);

//Data memory
data_memory data_mem(
.clk(clk),
.rst(rst),
.addr(mem_alu_result),
.memread(mem_memread),
.memwrite(mem_memwrite),
.data_write(mem_rs2_data),
.data_read(mem_data)
);

////Data mem mux
//Mux data_mem_mux (
//.in1(wb_read_data),
//.in2(wb_alu_result),
//.sel(wb_memtoreg),
//.out(write_reg)
//);

assign write_reg = (wb_memtoreg == 2'b10) ? wb_inc_pc : //jal, ghi PC+4
(wb_memtoreg == 2'b01) ?  wb_read_data : wb_alu_result;

//IF/ID reg
IF_ID if_id (
.clk(clk),
.rst(rst),
.stall(stall),
.jump(jump),
.pc_sel(pc_sel),
.inc_pc(inc_pc),
.inst(inst),
.id_inc_pc(id_inc_pc),
.id_inst(id_inst)
);

//ID/EX reg
ID_EX id_ex(
.clk(clk),
.rst(rst),
.stall(stall),
.pc_sel(pc_sel),
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
.id_funct3(id_inst[14:12]),
.alu_signal(alu_signal),
.id_rd(id_rd),
.id_rs1_addr(id_inst[19:15]),
.id_rs2_addr(id_inst[24:20]),
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
.ex_funct3(ex_funct3),
.ex_rd(ex_rd),
.ex_rs1_addr(ex_rs1_addr),
.ex_rs2_addr(ex_rs2_addr) //update lại rd,rs1,rs2 address
);


//EX/MEM
EX_MEM ex_mem (
.clk(clk),
.rst(rst),
.pc_sel(pc_sel),
.pc_branch(pc_branch),
.is_zero(is_zero),
.alu_result(alu_result),
.ex_rs2_data(inb), //fix dữ liệu sau forwarding
.ex_inc_pc(ex_inc_pc),
.ex_regwrite(ex_regwrite),
.ex_memread(ex_memread),
.ex_memwrite(ex_memwrite),
.ex_memtoreg(ex_memtoreg),
.ex_branch(ex_branch),
.ex_rd(ex_rd),
.ex_funct3(ex_funct3),
.mem_pc_branch(mem_pc_branch),
.mem_alu_result(mem_alu_result),
.mem_rs2_data(mem_rs2_data),
.mem_inc_pc(mem_inc_pc),
.mem_is_zero(mem_is_zero),
.mem_regwrite(mem_regwrite),
.mem_memread(mem_memread),
.mem_memwrite(mem_memwrite),
.mem_memtoreg(mem_memtoreg),
.mem_branch(mem_branch),
.mem_rd(mem_rd),
.mem_funct3(mem_funct3) //update lại rd
);


//MEM/WB 
MEM_WB mem_wb (
.clk(clk),
.rst(rst),
.read_data(mem_data),
.mem_alu_result(mem_alu_result),
.mem_inc_pc(mem_inc_pc),
.mem_regwrite(mem_regwrite),
.mem_memtoreg(mem_memtoreg),
.mem_rd(mem_rd),
.wb_read_data(wb_read_data),
.wb_alu_result(wb_alu_result),
.wb_inc_pc(wb_inc_pc),
.wb_regwrite(wb_regwrite),
.wb_memtoreg(wb_memtoreg),
.wb_rd(wb_rd) //update rd
);

//hazard detect unit
hazard_detect haz_det (
.rs1_addr(id_inst[19:15]),
.rs2_addr(id_inst[24:20]),
.ex_memread(ex_memread),
.ex_rd(ex_rd),
.stall(stall)
);

//forwarding unit
forwarding forw(
.ex_rs1(ex_rs1_addr),
.ex_rs2(ex_rs2_addr),
.mem_regwrite(mem_regwrite),
.wb_regwrite(wb_regwrite),
.wb_rd(wb_rd),
.mem_rd(mem_rd),
.forwardA(forwardA),
.forwardB(forwardB)
);
endmodule
