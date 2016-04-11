`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/15/2016 02:18:35 PM
// Design Name: 
// Module Name: syncgen
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


module syncgen(clk, Hsync, Vsync, active, Counter_X, Counter_Y);
	input clk;//should be 108MHz via clock wizard
	output active, Hsync, Vsync;
	output [11:0] Counter_X;
	output [11:0] Counter_Y;
   
	/*Some constants*/
	parameter FRAME_WIDTH = 1280;
	parameter FRAME_HEIGHT = 1024;
	parameter H_FP = 48; //H front porch
	parameter H_PW = 112; //H sync pulse width
	parameter H_MAX = 1688; //H total period
	parameter V_FP = 1; //V front porch
	parameter V_PW = 3; //V sync pulse width
	parameter V_MAX = 1066; //V total period
	//parameter H_POL = 1;
	//parameter V_POL = 1;
	
	/*Some registers*/
	//H and V counters
	reg [11:0]h_counter_reg;
	reg [11:0]v_counter_reg;
	reg h_sync_reg, v_sync_reg;
	
	//Pipe counters and sync
	reg [11:0]h_counter_reg_delay;
	reg [11:0]v_counter_reg_delay;
	reg h_sync_reg_delay, v_sync_reg_delay;
	
	//Horizontal counter
	always @ (posedge clk) begin
		if (h_counter_reg == (H_MAX - 1)) begin
			h_counter_reg <= 0;
		end
		else begin
			h_counter_reg <= h_counter_reg + 1;
		end
	end
	
	//Vertical counter
	always @ (posedge clk) begin
		if ((h_counter_reg == (H_MAX - 1)) && (v_counter_reg == (V_MAX - 1))) begin
			v_counter_reg <= 0;
		end
		else if (h_counter_reg == (H_MAX - 1)) begin
			v_counter_reg <= v_counter_reg + 1;
		end
	end
	
	//Horizontal sync
	always @ (posedge clk) begin
		if((h_counter_reg >= (H_FP + FRAME_WIDTH - 1)) && (h_counter_reg < (H_FP + FRAME_WIDTH + H_PW - 1))) begin
			h_sync_reg <= 1;
		end
		else begin
			h_sync_reg <= 0;
		end
	end
	
	//Vertical sync
	always @ (posedge clk) begin
		if((v_counter_reg >= (V_FP + FRAME_HEIGHT - 1)) && (v_counter_reg < (V_FP + FRAME_HEIGHT + V_PW - 1))) begin
			v_sync_reg <= 1;
		end
		else begin
			v_sync_reg <= 0;
		end
	end
	
	//Notifies whether the current position is in the display area
	assign active = ((h_counter_reg_delay < FRAME_WIDTH) && (v_counter_reg_delay < FRAME_HEIGHT));
	
	//Updates pipe register values
	always @ (posedge clk) begin
		h_counter_reg_delay <= h_counter_reg;
		v_counter_reg_delay <= v_counter_reg;
		h_sync_reg_delay <= h_sync_reg;
		v_sync_reg_delay <= v_sync_reg;
	end
	
	assign Hsync = h_sync_reg_delay;
	assign Vsync = v_sync_reg_delay;
	assign Counter_X = h_counter_reg;
	assign Counter_Y = v_counter_reg;
	
	
endmodule
