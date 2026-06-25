`timescale 1ns / 1ps
module reg_file(
input wire clk,
input wire rst,
input wire regwrite,
input wire [4:0]rs1_addr,
input wire [4:0]rs2_addr,
input wire [4:0] rd_addr,
input wire [31:0] write_data,
output wire [31:0] rs1_data,
output wire [31:0] rs2_data
    );
 reg [31:0] rf [ 31:0]; // 32 thanh ghi 32 bit  
 integer i;
always@(posedge clk,posedge rst) begin
if(rst) begin 
for( i =0; i< 32; i=i+1) begin
rf[i] <=32'h0;
end end else if(regwrite && (rd_addr!=5'b0)) begin
rf[rd_addr] <=write_data;
end
end
assign rs1_data = (rs1_addr==5'b0) ? 32'h0: ((rs1_addr==rd_addr)? write_data: rf[rs1_addr]);
assign rs2_data = (rs2_addr ==5'b0) ? 32'h0: ((rs1_addr ==rd_addr)? write_data: rf[rs2_addr]);
endmodule
