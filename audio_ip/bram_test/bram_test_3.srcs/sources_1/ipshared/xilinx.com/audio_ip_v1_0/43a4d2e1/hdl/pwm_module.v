`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.03.2016 18:40:39
// Design Name: 
// Module Name: pwm_module
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


module pwm_module( 
input clk,
input [7:0] PWM_in, 
output reg PWM_out,
input [11:0] max_ramp
//input new_data_to_pwm
);
initial PWM_out=1'b1;
//reg [7:0]new_pwm=0;
reg [11:0] PWM_ramp=12'b000000000000; 
//reg [11:0] max_ramp=12'b100011011011;
reg [11:0] max_pwm= 12'b000011111111;
//integer inv_ratio_ramp;
//integer inv_ratio_pwm;
reg [11:0] adjusted_pwm;
integer adjust_rate;

initial begin
    adjust_rate=max_ramp/max_pwm;
end


always@(*)begin
    
    adjusted_pwm=(PWM_in)*(adjust_rate);
    //inv_ratio_ramp=max_ramp/PWM_ramp;
    //inv_ratio_pwm=max_pwm/PWM_in;
    
end


always@(posedge clk)begin
    if(PWM_ramp<max_ramp)begin
        PWM_ramp<=PWM_ramp+1;
    end
    else begin
        PWM_ramp<=0;
    end
    
    //PWM_out<=(adjusted_pwm>PWM_ramp);
    PWM_out<=(adjusted_pwm>PWM_ramp);
end

endmodule
