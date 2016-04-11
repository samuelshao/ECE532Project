`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2014/05/23 15:11:30
// Design Name: 
// Module Name: ov7725_capture
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


module ov7670_capture(
input pclk,
input vsync,
input href,
input calibration,
input[7:0] d,
output[16:0] addr,
output reg[15:0] dout,
output reg we,
output [64:0]avg_X_smooth,
output [64:0]avg_Y_smooth
    );
    reg [15:0] d_latch;
    reg [16:0] address;
    reg [16:0] address_next;  
     reg [1:0] wr_hold;    
     reg [1:0] cnt;
     
     // pixel markers
     reg [11:0] red_marker;
     reg [11:0] black;
     //reg calib;
     reg [16:0]placerX;
     reg display_box_calib;
     reg in_calib_zone;
     reg [32:0]sum_red;
     reg [32:0]sum_green;
     reg [32:0]sum_blue;
     reg [32:0]sum_red1;
     reg [32:0]sum_green1;
     reg [32:0]sum_blue1;
     
     reg [3:0] red_calib;
     reg [3:0] green_calib;
     reg [3:0] blue_calib;
     
     //position markers
     reg [16:0]number_of_pixels;
     reg [63:0]avg_X;
     reg [63:0]avg_Y;
     reg [63:0]sum_X;
     reg [63:0]sum_Y;
     reg [32:0]prev_x;
     reg [32:0]prev_y;
   
     //running average logic to smoothen avg_X and avg_Y
      reg [31:0] frame_count;
    
  initial red_marker=12'b111100000000;
  initial begin
    sum_red=32'd0;
    sum_green=32'd0;
    sum_blue=32'd0;
    sum_red1=32'd0;
    sum_green1=32'd0;
    sum_blue1=32'd0;
    red_calib=4'd0;
    green_calib=4'd0;
    blue_calib=4'd0;
    
    number_of_pixels=16'd0;
    avg_X=64'd0;
    avg_Y=64'd0;
    sum_X=64'd0;
    sum_Y=64'd0;
   
    frame_count=32'd0;
    sum_avg_X<=64'd0;
    sum_avg_Y<=64'd0;
  end
  initial black=12'b0;
  initial d_latch = 16'b0;
  initial address = 19'b0;
  initial address_next = 19'b0;
  initial wr_hold = 2'b0;   
  initial cnt = 2'b0;        
assign addr =    address;


always@*begin
    placerX=(address%320);
    
    //calibration mode
    //placer area to find find out the average pixel parameters
    //display the box
    //105x320=33600
    //110x320=35200
    //130x320=41600
    //135x320=43200
    if((address > 33600)&(address < 43200) &(placerX > 145)&(placerX <175))begin
        if(( address < 35200) | (address > 41600))begin
            display_box_calib=1;
            in_calib_zone=0;
        end
        else begin
            if((placerX <150)|(placerX>170))begin
                display_box_calib=1;
                in_calib_zone=0;
            end
            else begin
                display_box_calib=0;
                in_calib_zone=1;
            end
        end
    end
    else begin
        display_box_calib=0;
        in_calib_zone=0;
    end
    
  
    
    
    
    
end

reg [63:0] avg_X_smooth;
reg [63:0] avg_Y_smooth;
reg [63:0] sum_avg_X;
reg [63:0] sum_avg_Y;


always@(posedge pclk)begin

 if( vsync ==1) begin
           address <=17'b0;
           address_next <= 17'b0;
           wr_hold <=  2'b0;
           cnt <=  2'b0;
           
           
            sum_red <=32'b0;
            sum_green <=32'b0;
            sum_blue<=32'b0;
            sum_red1<=32'b0;
            sum_green1<=32'b0;
            sum_blue1<=32'b0;
            number_of_pixels<=16'b0;
            avg_X<=64'b0;
            avg_Y<=64'b0;
            sum_X<=64'b0;
            sum_Y<=64'b0;
              
           
           end
        else begin
           if(address<76800)begin  // Check if at end of frame buffer
             address <= address_next;
           end
           else begin
             address <= 76800;
             /*Averaging factor here*/
              if(frame_count < 1200)begin
                 frame_count<=frame_count+1;
                 sum_avg_X<=avg_X+sum_avg_X;
                 sum_avg_Y<=avg_Y+sum_avg_Y;
              end
              else begin
                 frame_count <=0;
                 sum_avg_X<=0;
                 sum_avg_Y<=0;
                 avg_X_smooth<=sum_avg_X/800;
                 avg_Y_smooth<=sum_avg_Y/800;
              end  
             
             
           end
	   // Get 1 byte from camera each cycle.  Have to get two bytes to form a pixel.
	   // wr_hold is used to generate the write enable every other cycle.
	   // No changes until href = 1 indicating valid data
           we      <= wr_hold[1];  // Set to 1 one cycle after dout is updated
           wr_hold <= {wr_hold[0] , (href &&( ! wr_hold[0])) };
           d_latch <= {d_latch[7:0] , d};

           if (wr_hold[1] ==1 )begin  // increment write address and output new pixel
              address_next <=address_next+1;
                           
              if(calibration==1)begin
                red_calib[3:0]   <= sum_red1[3:0];
                green_calib[3:0] <= sum_green1[3:0];
                blue_calib[3:0]  <= sum_blue1[3:0];
                  //avg color calculations
                  sum_red1<=sum_red/361;
                  sum_green1<=sum_green/361;
                  sum_blue1<=sum_blue/361;
                
                
                if( display_box_calib==1)begin
                    dout[15:0]={d_latch[15:12] , black[11:0]};
                end
                else begin
                    dout[15:0]<={ d_latch[15:11] , d_latch[10:5] , d_latch[4:0] };
                    if(in_calib_zone==1)begin
                        sum_red <= sum_red+dout[11:8];
                        sum_green <= sum_green +dout[7:4];
                        sum_blue <= sum_blue + dout[3:0];
                    end
                end
                                
              end
              else begin
                if((d_latch[11:8] == red_calib[3:0]) & (d_latch[7:4] == green_calib[3:0]) & (d_latch[3:0] == blue_calib[3:0]) )begin
                     //required pixel thresholds are met
                     dout[15:0] <= {d_latch[15:12],red_calib[3:0],green_calib[3:0],blue_calib[3:0] };
                     //calculate and send address
                     number_of_pixels<=number_of_pixels+1;
                     sum_X<=sum_X+(address%320);
                     sum_Y<=sum_Y+(address/240);
                     avg_X<=sum_X/number_of_pixels;
                     avg_Y<=sum_Y/number_of_pixels;
                     
                     
                end
                else begin
                     dout[15:0]  <= {d_latch[15:12] , black[11:0] };
                end
              end
              
           end

        end;
 end

endmodule