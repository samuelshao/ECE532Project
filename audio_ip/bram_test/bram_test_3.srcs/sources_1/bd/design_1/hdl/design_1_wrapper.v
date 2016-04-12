//Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2015.1 (win64) Build 1215546 Mon Apr 27 19:22:08 MDT 2015
//Date        : Mon Apr 04 09:51:14 2016
//Host        : Tailor-PC running 64-bit Service Pack 1  (build 7601)
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (aud_vcc,
    clock_rtl,
    pwm_out,
    reset_rtl,
    reset_rtl_0,
    uart_rtl_rxd,
    uart_rtl_txd);
  output aud_vcc;
  input clock_rtl;
  output pwm_out;
  input reset_rtl;
  input reset_rtl_0;
  input uart_rtl_rxd;
  output uart_rtl_txd;

  wire aud_vcc;
  wire clock_rtl;
  wire pwm_out;
  wire reset_rtl;
  wire reset_rtl_0;
  wire uart_rtl_rxd;
  wire uart_rtl_txd;

  design_1 design_1_i
       (.aud_vcc(aud_vcc),
        .clock_rtl(clock_rtl),
        .pwm_out(pwm_out),
        .reset_rtl(reset_rtl),
        .reset_rtl_0(reset_rtl_0),
        .uart_rtl_rxd(uart_rtl_rxd),
        .uart_rtl_txd(uart_rtl_txd));
endmodule
