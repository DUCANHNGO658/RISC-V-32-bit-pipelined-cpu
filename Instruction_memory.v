`timescale 1ns / 1ps
module inst_mem #(parameter INST_WIDTH = 32)(
input wire [INST_WIDTH-1:0] addr, //output of PC block
output wire [INST_WIDTH-1:0] inst
    );
reg [31:0] mem_arr [0:1023]    ;
assign inst = mem_arr[addr>>2];  //address dạng byte, chia /4 để chuyển về địa chỉ word 
initial begin
$readmemh("program.mem",mem_arr);
end
endmodule
