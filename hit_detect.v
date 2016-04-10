module hit_detect(clk, resetn, targetCoord_X, targetCoord_Y, markerCoord_X, markerCoord_Y, targetSize, hit, hitAck);
	input clk;
	input resetn;
	input [11:0]targetCoord_X;
	input [11:0]targetCoord_Y;
	input [11:0]markerCoord_X;
	input [11:0]markerCoord_Y;
	input [7:0]targetSize;
	input hitAck;
	output reg hit;
	
	wire overlap;
	//wire overlapX, overlapY;
	reg[11:0]diff_X, diff_Y;
	
	//assign hitTrigger = (overlapArea > threshold);
	
	assign overlap = (diff_X < 50) && (diff_Y < 50);
	
	parameter threshold = 25;
	
	always @ (*) begin
		if(targetCoord_X > markerCoord_X) begin
			diff_X = targetCoord_X - markerCoord_X;
		end
		else begin
			diff_X = markerCoord_X - targetCoord_X;
		end
		
		if(targetCoord_Y > markerCoord_Y) begin
			diff_Y = targetCoord_Y - markerCoord_Y;
		end
		else begin
			diff_Y = markerCoord_Y - targetCoord_Y;
		end

	end
	reg get_ack=1'b0;
	wire hit_wire;
	reg [7:0] hitCounter_in_cycle=8'd0;
	reg [7:0] prev_hitCounter=8'd0;
	
	assign hit_wire=hit;
	always @ (*) begin
	   if(overlap) begin
	       hit = 1;     
	   end
	   else begin
	       hit = 0;
	   end
    end
endmodule