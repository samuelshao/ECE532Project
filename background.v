module background(clk, CounterX, CounterY, backgroundColour);
	input clk;
	input [11:0]CounterX;
	input [11:0]CounterY;
	output reg [11:0]backgroundColour;
	
	/*Colour parameters*/
	/*red = [11:8], green = [7:4], blue = [3:0]*/
	parameter colour_sky = 12'h00F;
	parameter colour_leaf = 12'h0F0;
	parameter colour_trunk = 12'h530;
	parameter colour_grass = 12'h0F0;
	parameter colour_sun = 12'hFF0;
	parameter coordinate_sun_X = 200;
	parameter coordinate_sun_Y = 200;
	
	isInCircle isInCircle_inst(.clk(clk), .coordX(CounterX), .coordY(CounterY), .initX(coordinate_sun_X), .initY(coordinate_sun_Y), .radius(100), .insideCircle(insideCircle_wire));
	
	wire [11:0]CounterY_inv = 1024 - CounterY;
	wire insideCircle_wire;
	
	always @ (*) begin
	   if(CounterY_inv < 105) begin
		  backgroundColour = colour_grass;
	   end
	   else begin
		  if(CounterY_inv >= 105 && CounterY_inv < 200 && CounterX >= 200 && CounterX < 250) begin
			     backgroundColour = colour_trunk;
		  end
		  else if(CounterY_inv >= 200 && CounterY_inv < 300 && CounterX >= 150 && CounterX < 300) begin
			     backgroundColour = colour_leaf;
		  end
		  else if(CounterY_inv >= 300 && CounterY_inv < 400 && CounterX >= 175 && CounterX < 275) begin
			     backgroundColour = colour_leaf;
		  end
		  else if(insideCircle_wire) begin
		         backgroundColour = colour_sun;
		  end
		  else begin
			     backgroundColour = colour_sky;
		  end
	   end
	end
	
	
endmodule