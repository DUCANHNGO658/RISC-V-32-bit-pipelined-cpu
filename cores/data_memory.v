`timescale 1ns / 1ps

module data_memory#(parameter WIDTH=32)(
input wire clk,
input wire rst,
input wire memread, memwrite,
input wire [WIDTH-1:0] addr, data_write,
output wire [WIDTH-1:0] data_read
    );

integer i;
reg [WIDTH-1:0] mem [1023:0];
assign data_read = (memread==1'b1)? mem[addr>>2] : 32'b0;
always@(posedge clk) begin
if(rst) begin
for(i = 0; i<1024; i= i+1) mem[i] = 32'b0; end
else if(memwrite) mem[addr>>2] <= data_write;
end
endmodule
