`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/13/2016 05:11:21 PM
// Design Name: 
// Module Name: top_mod
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


module top_mod(clk, resetn, start, sw, X_position, Y_position, vgaRed, vgaGreen, vgaBlue, Hsync, Vsync, cathode, anode, hitAck, gameEnd);
   // input clk_new;   
    input clk;//gets 108MHZ
    input resetn;
    input start;
    input [2:0]sw;
    input [11:0]X_position;//These are the marker's coordinates
    input [11:0]Y_position;
    output [3:0]vgaRed;
    output [3:0]vgaGreen;
    output [3:0]vgaBlue;
    output Hsync;
    output Vsync;
    output [7:0]cathode;
    output [7:0]anode;
    output hitAck;
    output gameEnd;
    
    /*Counters for score and level*/
    //wire game_end;
    //wire [2:0]level_wire;
    //output [11:0]LED;
    //assign level[2:0] = sw[2:0];
    //assign game_end = (scoreCounter < 0) || (scoreCounter > 15);
    //assign level_wire = level;
    //reg [11:0]Coord_X;
    //reg [11:0]Coord_Y;
    parameter targetSize = 50;
    reg [31:0]counter_animation;
    
    wire [11:0]Coord_X_wire;
    wire [11:0]Coord_Y_wire;
    wire hitAck_wire;
    wire missAck_wire;
    //wire [2:0]targetID_wire;
    wire reset = ~resetn;
    wire hitSignal;
    wire [7:0]scoreCounter;
    //wire clk_108;
    //wire reset = 0;
    //wire locked;
    //reg [7:0] scoreCounter_reg;
    //always@(posedge clk)begin
        //scoreCounter_reg=scoreCounter;
    assign hitAck = hitAck_wire;
    //end
    //assign Coord_X_wire[11:0] = Coord_X[11:0];
    //assign Coord_Y_wire[11:0] = Coord_Y[11:0];
    
    //positiongen position_generator(.clk(clk_108), .Coord_X(Coord_X_wire), .Coord_Y(Coord_Y_wire), .Delta_X(X_incr), .Delta_Y(Y_incr));
    //lfsr_gen lfsr_inst(.clk(clk_108), .pos_X(Coord_X_wire), .pos_Y(Coord_Y_wire), .LED(LED));
    //random_number lfsr_inst(.clock(clk_108), .reset(), .max(), .min(), .random_seed(), .random_num());
    //clk_wiz_1 clk_adjusted(.clk_in1(clk), .clk_out1(clk_108), .reset(reset), .locked(locked));
    hit_detect hit_detect_inst(.resetn(resetn), .targetCoord_X(Coord_X_wire), .targetCoord_Y(Coord_Y_wire), .markerCoord_X(X_position), .markerCoord_Y(Y_position), .targetSize(targetSize), .hit(hitSignal), .hitAck(hitAck_wire));
    positionGen positionGen_inst(.clk(clk), .resetn(resetn), .start(start), .hitSignal(hitSignal), .coord_X(Coord_X_wire), .coord_Y(Coord_Y_wire), .targetSize(targetSize), .hitAck(hitAck_wire), .missAck(missAck_wire), .hitCounter(scoreCounter), .level(sw[2:0]), .gameend(gameEnd));  
    sevenseg sevenseg_inst(.clk(clk), .hit_count(scoreCounter), .cathode(cathode), .anode(anode));
    vga_ctrl vga(.clk(clk), .MarkerCoord_X(X_position), .MarkerCoord_Y(Y_position), .Coord_X(Coord_X_wire), .Coord_Y(Coord_Y_wire), .targetSize(targetSize), .vgaRed(vgaRed), .vgaGreen(vgaGreen), .vgaBlue(vgaBlue), .Hsync(Hsync), .Vsync(Vsync));

endmodule
