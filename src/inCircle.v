module isInCircle(clk, coordX, coordY, initX, initY, radius, insideCircle);
	input clk;
	input [11:0]coordX;
	input [11:0]coordY;
	input [11:0]initX;
	input [11:0]initY;
	input [11:0]radius;
	output insideCircle;
	
	wire [23:0]radSquare;
	reg [11:0]x_diff;
	reg [11:0]y_diff;
	reg [23:0]XSquare;
	reg [23:0]YSquare;
	
	assign radSquare = radius * radius;
	
	always @ (posedge clk) begin
		if(coordX > initX) begin
			x_diff <= coordX - initX;
		end
		else begin
			x_diff <= initX - coordX;
		end
		
		if(coordY > initY) begin
			y_diff <= coordY - initY;
		end
		else begin
			y_diff <= initY - coordY;
		end
		
		XSquare <= x_diff * x_diff;
		YSquare <= y_diff * y_diff;
		
	end
	
	assign insideCircle = (radSquare >= (XSquare + YSquare));

endmodule