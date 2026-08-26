`timescale 1ns / 1ps
module Mux#(parameter WIDTH= 32)(
input wire [WIDTH-1:0] in1,
input wire [WIDTH-1:0] in2,
input wire sel,
output wire [WIDTH-1:0] out
    );
    assign out = sel ? in1 : in2;
endmodule
