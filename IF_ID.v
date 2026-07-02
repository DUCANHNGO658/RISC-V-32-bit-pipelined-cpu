`timescale 1ns / 1ps

module IF_ID #(parameter WIDTH=32)(
input wire clk,
input wire rst,
input wire jump,
input wire stall,
input wire [WIDTH-1:0] inc_pc,inst,
output reg [WIDTH-1:0] id_inc_pc, id_inst
    );
    
always@(posedge clk) begin
if(rst) begin
id_inc_pc <= 32'b0;
id_inst <=32'b0;
end else  begin 
if (!stall) begin 
id_inc_pc <=inc_pc;
id_inst <= (jump) ? 32'h0 : inst;
end
else begin
id_inc_pc <=id_inc_pc;
id_inst <=id_inst;
end
end
end
endmodule
