`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/29/2016 11:45:41 PM
// Design Name: 
// Module Name: clock_wrapper
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module clock_wrapper(
    input clk_in,
    output clk_25,
    output clk_50,
    output clk_108
    );
    
    wire clk_in1, clk_in2;
    wire clk_25_wire, clk_50_wire, clk_108_wire, clk_108_dummy;
    assign clk_in1 = clk_in;
    assign clk_in2 = clk_in;
    assign clk_25 = clk_25_wire;
    assign clk_50 = clk_50_wire;
    assign clk_108 = clk_108_wire;
    
    clk_wiz_0 u_clock
         (
          // Clock in ports
          .clk_in1(clk_in1),      // input clk_in1
          // Clock out ports
          .clk_out1(clk_50_wire),     // output clk_out1
          .clk_out2(clk_25_wire),
          .clk_out3(clk_108_dummy)
          //.reset(reset),
          //.locked(locked)
          );    // output clk_out2
    
    clk_wiz_1 clk_wiz_1_inst
            (
            .clk_in1(clk_in2),
            .clk_out1(clk_108_wire)
            );
endmodule
