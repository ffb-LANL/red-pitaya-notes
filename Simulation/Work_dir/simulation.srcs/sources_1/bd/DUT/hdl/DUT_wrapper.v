//Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
//Date        : Sat Feb 13 14:47:04 2016
//Host        : FFBLP running 64-bit Service Pack 1  (build 7601)
//Command     : generate_target DUT_wrapper.bd
//Design      : DUT_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module DUT_wrapper
   (M_AXIS_tdata,
    M_AXIS_tready,
    M_AXIS_tvalid,
    aclk,
    aresetn,
    clk_out1,
    trig,
    trig_out);
  output [15:0]M_AXIS_tdata;
  input M_AXIS_tready;
  output M_AXIS_tvalid;
  input aclk;
  input aresetn;
  output clk_out1;
  input trig;
  output [0:0]trig_out;

  wire [15:0]M_AXIS_tdata;
  wire M_AXIS_tready;
  wire M_AXIS_tvalid;
  wire aclk;
  wire aresetn;
  wire clk_out1;
  wire trig;
  wire [0:0]trig_out;

  DUT DUT_i
       (.M_AXIS_tdata(M_AXIS_tdata),
        .M_AXIS_tready(M_AXIS_tready),
        .M_AXIS_tvalid(M_AXIS_tvalid),
        .aclk(aclk),
        .aresetn(aresetn),
        .clk_out1(clk_out1),
        .trig(trig),
        .trig_out(trig_out));
endmodule
