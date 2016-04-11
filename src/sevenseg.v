`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.03.2016 18:29:08
// Design Name: 
// Module Name: 7seg
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


module sevenseg(
    input clk,
    input [7:0] hit_count,
   // input switch,
    output [7:0] cathode,
    output [7:0] anode       
    );
    
     reg [7:0] cathode;
     reg [7:0] anode;
    wire [7:0]v = 8'b00011011;    
    parameter count_max=50000;
    reg [10:0]count;
    reg [26:0]timer;
    reg [5:0]value;
    wire [3:0]hundreds;
    wire [3:0]tens;
    wire [3:0]ones;
    reg [14:0]c=15'd0;
    BCD a(hit_count,hundreds,tens,ones);
    
   
 /*    always@(posedge clk) begin
     if( timer==count_max ) begin
     timer<=27'd0;
     end
     else
     timer<=timer+1;
     end
    
    always@(posedge clk) begin
    if (switch)
    begin   
    value=6'b0;
    end
    else begin
    if(hit)
    count<=count+1;
    if (timer==count_max)
    
    value <= value+1;
   end 
   end*/
   
   reg newclk;  
     always@(posedge clk)
     begin
     if(c==15'h8fff)
     begin
     newclk=~newclk;
     c<=5'd0;
     end
     else 
     c<=c+1;
     end
     
     always@(*)
     begin
     
     
     if(newclk==1'b1)
     begin
     anode<=8'b11111101;
     value<=tens;
   
     end
     else if (newclk==1'b0)
     begin
     anode<=8'b11111110;
     value<=ones;
     end
     end
   
   
   
     
     always@*
        begin 
        case (value)
               6'd0: cathode= 8'b11000000;
               6'd1: cathode= 8'b11111001;
               6'd2: cathode= 8'b10100100;
               6'd3: cathode= 8'b10110000;
               6'd4: cathode= 8'b10011001;
               6'd5: cathode= 8'b10010010;
               6'd6: cathode= 8'b10000010;
               6'd7: cathode= 8'b11111000;
               6'd8: cathode= 8'b10000000;
               6'd9: cathode= 8'b10010000;
               default: cathode=8'b00000000;       
              endcase
              end
        
        
endmodule


module BCD( 
input[7:0] binary,
output reg [3:0] hundreds,
output reg [3:0] tens,
output reg [3:0] ones
);

integer i;
always @(binary)
begin 
hundreds=4'd0;
tens=4'd0;
ones=4'd0;
for(i=7;i>=0;i=i-1)
	begin 
	if(hundreds>=5)
   hundreds=hundreds+3;
	if(tens>=5)
	tens=tens+3;
	if(ones>=5)
	ones=ones+3;
    hundreds=hundreds<<1;
    hundreds[0]=tens[3];
	tens=tens<<1;
	tens[0]=ones[3];
	ones=ones<<1;
	ones[0]=binary[i];
	end
end
endmodule


