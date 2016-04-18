//Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
//Date        : Wed Apr 13 13:37:06 2016
//Host        : ffboff running 64-bit Service Pack 1  (build 7601)
//Command     : generate_target dut_5_wrapper.bd
//Design      : dut_5_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module dut_5_wrapper
   (M_AXIS_tdata,
    M_AXIS_tvalid,
    S_AXIS_tdata,
    S_AXIS_tready,
    S_AXIS_tvalid,
    aclk,
    aresetn);
  output [31:0]M_AXIS_tdata;
  output M_AXIS_tvalid;
  input [31:0]S_AXIS_tdata;
  output S_AXIS_tready;
  input S_AXIS_tvalid;
  input aclk;
  input aresetn;

  wire [31:0]M_AXIS_tdata;
  wire M_AXIS_tvalid;
  wire [31:0]S_AXIS_tdata;
  wire S_AXIS_tready;
  wire S_AXIS_tvalid;
  wire aclk;
  wire aresetn;

  dut_5 dut_5_i
       (.M_AXIS_tdata(M_AXIS_tdata),
        .M_AXIS_tvalid(M_AXIS_tvalid),
        .S_AXIS_tdata(S_AXIS_tdata),
        .S_AXIS_tready(S_AXIS_tready),
        .S_AXIS_tvalid(S_AXIS_tvalid),
        .aclk(aclk),
        .aresetn(aresetn));
endmodule
