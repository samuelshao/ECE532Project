`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/15/2016 02:19:43 PM
// Design Name: 
// Module Name: vga_ctrl
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


module vga_ctrl(clk, MarkerCoord_X, MarkerCoord_Y, Coord_X, Coord_Y, targetSize, vgaRed, vgaGreen, vgaBlue, Hsync, Vsync);
    input clk;
	input [11:0]MarkerCoord_X;
	input [11:0]MarkerCoord_Y;
    input [11:0]Coord_X;
    input [11:0]Coord_Y;
    input [7:0]targetSize;
    output reg [3:0]vgaRed;
    output reg [3:0]vgaGreen;
    output reg [3:0]vgaBlue;
    output Hsync;
    output Vsync;
	
	/*Parameters*/
	/*red = [11:8], green = [7:4], blue = [3:0]*/
	parameter background_colour = 12'h000;
	parameter target_colour = 12'hFFF;
	parameter marker_colour = 12'hF00;
	parameter FRAME_WIDTH = 1280;
    parameter FRAME_HEIGHT = 1024;
	
	wire [11:0]Counter_X;
    wire [11:0]Counter_Y;
    wire [11:0]backgroundColour_wire;
    reg inTargetX, inTargetY;
	reg inMarkerX, inMarkerY;

	wire [3:0]inDisplayArea;
	wire active;
	
	assign reset = 0;
	
	//module instantiations
	syncgen sync_generator(.clk(clk), .Hsync(Hsync), .Vsync(Vsync), .active(active), .Counter_X(Counter_X), .Counter_Y(Counter_Y));
	background background_inst(.clk(clk), .CounterX(Counter_X), .CounterY(Counter_Y), .backgroundColour(backgroundColour_wire));
	//logic for drawing target
	always @ (posedge clk) begin
	   if(inTargetX == 0) begin
	       inTargetX <= ((Counter_X == Coord_X) && active);
	   end
	   else begin
	       inTargetX <= ((Counter_X < Coord_X + targetSize) && (Counter_X < 1280));
	   end
	end
	
	always @ (posedge clk) begin
	   if(inTargetY == 0) begin
	       inTargetY <= ((Counter_Y == Coord_Y) && active);
	   end
	   else begin
	       inTargetY <= ((Counter_Y < Coord_Y + targetSize) && (Counter_Y < 1024));
	   end
	end
	
	wire inTarget = inTargetX & inTargetY;
	
	//logic for drawing marker
	always @ (posedge clk) begin
		if(inMarkerX == 0) begin
			inMarkerX <= ((Counter_X == MarkerCoord_X) && active);
		end
		else begin
			inMarkerX <= ((Counter_X < MarkerCoord_X + targetSize) && (Counter_X < 1280));
		end
    end
    
    always @ (posedge clk) begin
		if(inMarkerY == 0) begin
			inMarkerY <= ((Counter_Y == MarkerCoord_Y) && active);
		end
		else begin
			inMarkerY <= ((Counter_Y < MarkerCoord_Y + targetSize) && (Counter_Y < 1024));
		end
	end
	
	wire inMarker = inMarkerX & inMarkerY;
	
	//combines logic values for pixels
	assign inDisplayArea[0] = active;
	assign inDisplayArea[1] = active;
	assign inDisplayArea[2] = active;
	assign inDisplayArea[3] = active;
	
	always @ (posedge clk) begin
		if(inMarker) begin
			vgaRed <= inDisplayArea[3:0] & marker_colour[11:8];
			vgaGreen <= inDisplayArea[3:0] & marker_colour[7:4];
			vgaBlue <= inDisplayArea[3:0] & marker_colour[3:0];
		end
		else begin
			if(inTarget) begin
				vgaRed <= inDisplayArea[3:0] & target_colour[11:8];
				vgaGreen <= inDisplayArea[3:0] & target_colour[7:4];
				vgaBlue <= inDisplayArea[3:0] & target_colour[3:0];
			end
			else begin
				//backgroundcolour
				vgaRed <= inDisplayArea[3:0] & backgroundColour_wire[11:8];
				vgaGreen <= inDisplayArea[3:0] & backgroundColour_wire[7:4];
				vgaBlue <= inDisplayArea[3:0] & backgroundColour_wire[3:0];
			end
		end
	end
	
endmodule
