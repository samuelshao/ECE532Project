`timescale 1ns/1ps
module tb();
reg sys_clk;
reg reset;
wire AUD_PWM;
wire AUD_SD;


// Instantiate DUT
design_1_wrapper dut(.clock_rtl(sys_clk),// system clock
    .reset_rtl(reset),
    .reset_rtl_0(~reset),
// active high
    
// active low
    .AUD_PWM,
    
    .AUD_SD);

always #5 sys_clk =~sys_clk;
initial
begin
   sys_clk =1'b0;
    reset =1'b1;
#45    
reset =1'b0;
end
endmodule