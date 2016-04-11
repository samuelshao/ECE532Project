`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/20/2016 06:33:51 PM
// Design Name: 
// Module Name: seedgen
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


module seedgen(clk, enable, seed);
	input clk;
	input enable;//switch
	output reg [11:0]seed;
	
	reg [11:0]counter;
	
	always @ (posedge clk) begin
		if(enable) begin
			seed[11:0] <= counter[11:0];
		end
		else begin
			counter <= counter + 1;
		end
	end
	
endmodule
