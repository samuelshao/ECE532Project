module lfsr(clk, reset, fetch, start, coord_X, ack);
	input clk;
	input reset;
	input fetch;
	input start;//switch[0]
	output [11:0]coord_X;
	output reg ack;
	
	reg [11:0]shiftReg;
	
	wire [11:0]seed;
	
	seedgen sgen_1(.clk(clk), .enable(start), .seed(seed));
	
	always @ (posedge clk) begin
		if(start) begin
			shiftReg[11:0] = seed[11:0];
		end
		else begin
			if(fetch) begin
				shiftReg = shiftReg << 1;
				shiftReg[0] = shiftReg[3]^shiftReg[9]^shiftReg[10]^shiftReg[11];
				ack <= 1;
			end
			else begin
				ack <= 0;
			end
		end
	end
	
	assign coord_X[11:0] = shiftReg[11:0];
	
endmodule
