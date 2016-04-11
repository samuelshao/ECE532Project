module lfsr32(clk, reset, fetch, start, dir_X, ack);
	input clk;
	input reset;
	input fetch;
	input start;//switch[0]
	output [27:0]dir_X;
	output reg ack;
	
	reg [27:0]shiftReg;
	reg [27:0]seed;
	reg [27:0]counter;
	
	always @ (posedge clk) begin
		if(start) begin
			seed[27:0] <= counter[27:0];
		end
		else begin
			counter <= counter + 1;
		end
	end
	
	always @ (posedge clk) begin
	if(start) begin
	   shiftReg[27:0] <= seed[27:0];
	end
	else begin
		if(fetch) begin
			shiftReg = shiftReg << 1;
			shiftReg[0] = shiftReg[24]~^shiftReg[27];
			ack <= 1;
		end
		else begin
			ack <= 0;
		end
	end
	end
	
	assign dir_X[27:0] = shiftReg[27:0];
	
endmodule
