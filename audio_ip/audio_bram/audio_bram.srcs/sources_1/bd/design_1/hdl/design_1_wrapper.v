//Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2015.1 (win64) Build 1215546 Mon Apr 27 19:22:08 MDT 2015
//Date        : Fri Apr 01 13:41:57 2016
//Host        : hp1 running 64-bit major release  (build 9200)
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (AUD_PWM,
    AUD_SD,
    clock_rtl,
    reset_rtl,
    reset_rtl_0);
  output AUD_PWM;
  output AUD_SD;
  input clock_rtl;
  input reset_rtl;
  input reset_rtl_0;

  wire AUD_PWM;
  wire AUD_SD;
  wire clock_rtl;
  wire reset_rtl;
  wire reset_rtl_0;

  design_1 design_1_i
       (.AUD_PWM(AUD_PWM),
        .AUD_SD(AUD_SD),
        .clock_rtl(clock_rtl),
        .reset_rtl(reset_rtl),
        .reset_rtl_0(reset_rtl_0));
endmodule
