module positionGen(clk, resetn, start, hitSignal, coord_X, coord_Y, targetSize, level, hitAck, missAck, hitCounter, gameend);
	input clk;
	input resetn;
	input start;
	input hitSignal;
	input [7:0]targetSize;
	input [2:0]level;
	output [11:0]coord_X;
	output [11:0]coord_Y;
	output reg hitAck;
	output reg missAck;
	output reg [7:0]hitCounter;
	output reg gameend;

	/*State parameters*/
	reg [2:0] ps, ns;
	localparam [2:0] init = 3'b000, fetch = 3'b001, ack_wait = 3'b010, move = 3'b011, hit = 3'b100, miss = 3'b110, endgame = 3'b111;
	
	/*Registers, wires, and parameters*/
	wire ack;//same as fetchCoord
	wire ack2;
	wire atBoundary;
	wire [11:0]regX_S, regY_S;
	reg [11:0]regX;
	reg [11:0]regY;
	reg [26:0]period_X;
	reg [26:0]period_Y;
	reg [27:0]counter_animation_X, counter_animation_Y, counter_hit;
	reg fetchCoord;//00|01 hit, 10|11 miss
	wire [11:0]coord_X_wire;
	wire fetchCoord_wire;
	reg fetchDirection;
	wire fetchDirection_wire;
	wire [27:0]directionX_wire;
	parameter incrX = 1;
	parameter incrY = 1;
	parameter FRAME_WIDTH = 1248;
	parameter FRAME_HEIGHT = 1024;
	parameter countdown_min = 27'h5265C00;
	reg direction;//0 = x-, 1 = x+;
	reg [27:0]dir_counter;
	//parameter period_X = 27'hA4CB8;
	//parameter period_Y = 27'hA4CB8;
	
	/*wire assignments*/
	assign fetchCoord_wire = fetchCoord;
	assign coord_X[11:0] = regX[11:0];
	assign coord_Y[11:0] = FRAME_HEIGHT - regY[11:0];
	assign atBoundary = (regX > FRAME_WIDTH) | (regY > FRAME_HEIGHT);
	assign fetchDirection_wire = fetchDirection;
	
	/*Module instantiations*/
    lfsr lfsr_inst(.clk(clk), .reset(resetn), .fetch(fetchCoord_wire), .start(start), .coord_X(coord_X_wire), .ack(ack));  
    lfsr32 lfsr32_inst(.clk(clk), .reset(resetn), .fetch(fetchDirection_wire), .start(start), .dir_X(directionX_wire), .ack(ack2));

    always @ (posedge clk) begin
        if(dir_counter == directionX_wire) begin
            dir_counter <= 0;
            direction = ~direction;
            fetchDirection <= 1;
        end
        else begin
            dir_counter <= dir_counter + 1;
            fetchDirection <= 0;
        end
    end
    

    /*always @ (posedge clk) begin
        if(dir_counter == change_dir) begin
            direction = ~direction;
            dir_counter <= 0;
        end
        else begin
            dir_counter <= dir_counter + 1;
        end
    end*/

    always @ (posedge clk) begin
        if(level == 1) begin
            period_X <= 27'hA4CB8;
            period_Y <= 27'hA4CB8;
        end
        else if(level == 2) begin
            period_X <= 27'h7B98A;
            period_Y <= 27'h7B98A;
        end
        else begin
            period_X <= 27'h5265C;
            period_Y <= 27'h5265C;
        end
    end

	always @ (*) begin
		/*Combinational logic for next state transitions*/
		case(ps)
			init: begin
				if(start) begin
					ns = fetch;
				end
				else ns = init;
			end
			fetch: begin
				ns = ack_wait;
			end
			ack_wait: begin
			    if(ack) begin
			        if(coord_X_wire < 300 || coord_X_wire > 980) begin
			            ns = fetch;
			        end
			        else begin
			            ns = move;
			        end
			    end
			    else begin
			        ns = ack_wait;
			    end
			end
			move: begin
				if(atBoundary) begin
					ns = miss;
				end
				else if(hitSignal) begin
				    ns = hit;
				end
				else begin
				    ns = move;
				end
			end
			hit: begin
			 if(gameend) begin
			     ns = endgame;
			 end
			 else begin
			     ns = fetch;
			 end
			end
			miss: begin
			 if(gameend) begin
			     ns = endgame;
			 end
			 else begin
			     ns = fetch;
			 end
			end
			default: begin
			    //no action
			end
		endcase
	end
	
	always @ (posedge clk) begin
		/*Conditional outputs*/
		case(ps)
			init: begin
				regX <= 0;
				regY <= 0;
				gameend <= 0;
				hitCounter <= 0;
			end
			fetch: begin
			    missAck <= 0;
			    hitAck <= 0;
				fetchCoord <= 1;
			end
			ack_wait: begin
			    /*if(ack) begin
			        fetchCoord <= 0;
			        regX <= coord_X_wire;
			        regY <= 2;
			    end*/
			    if(ack) begin
                   fetchCoord <= 0;
                   if(coord_X_wire > 300 && coord_X_wire < 980) begin
                       regX <= coord_X_wire;
                       regY <= 2;
                   end
                   //hitCounter <= hitCounter + 1;
                end
			end
			move: begin
				//no action
				if(counter_animation_X == period_X) begin
				    if(direction == 1) begin
				        regX <= regX - incrX;
				    end
				    else begin
				        regX <= regX + incrX;
				    end
					counter_animation_X <= 0;
				end
				else begin
					counter_animation_X <= counter_animation_X + 1;
				end
				if(counter_animation_Y == period_Y) begin
					regY <= regY + incrY;
					counter_animation_Y <= 0;
				end
				else begin
					counter_animation_Y <= counter_animation_Y + 1;
				end
			end
			hit: begin
			    hitAck <= 1;
			    /*Increment Score*/
			    if(hitCounter < 15) begin
			     hitCounter <= hitCounter + 1;
			     gameend <= 0;
			    end
			    else begin
			         gameend <= 1;
			    end
			    //fetchCoord <= 2'b01;
			end
			miss: begin
			    missAck <= 1;
			    /*Decrement Score*/
			    if(hitCounter > 0) begin
			     hitCounter <= hitCounter - 1;
			     gameend <= 0;
			    end
			    else begin
			     gameend <= 1;
			    end
			    //fetchCoord <= 2'b11;
			    
			end
			default: begin 
			    //no action
			end
		endcase
	end
	
	always @ (posedge clk or negedge resetn) begin
		/*Update next state*/
		if(~resetn) begin
			ps <= init;
		end
		else begin
			ps <= ns;
		end
	end
	
	
	
endmodule