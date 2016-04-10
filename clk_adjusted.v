`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/30/2016 12:03:55 AM
// Design Name: 
// Module Name: clk_adjusted
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


module clk_adjusted(clk_in, clk_50, clk_25);
    input clk_in;
    output reg clk_50;
    output reg clk_25;
    
    reg [2:0]counter_50, counter_25;
    
    initial begin
        clk_50 = clk_in;
        clk_25 = clk_in;
    end
    
    always @ (posedge clk_in) begin
        if(counter_50 == 3'h2) begin
            clk_50 = ~clk_50;
            counter_50 <= 0;
        end
        else begin
            counter_50 <= counter_50 + 1;
        end
        
        if(counter_25 == 3'h4) begin
            clk_25 = ~clk_25;
            counter_25 <= 0;
        end
        else begin
            counter_25 <= counter_25 + 1;
        end
    end


endmodule
