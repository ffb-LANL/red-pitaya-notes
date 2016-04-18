//Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
//Date        : Mon Apr 11 11:45:22 2016
//Host        : ffboff running 64-bit Service Pack 1  (build 7601)
//Command     : generate_target dut_3_wrapper.bd
//Design      : dut_3_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module dut_3_wrapper
   (M_AXIS_Y_tdata,
    M_AXIS_Y_tvalid,
    M_AXIS_tdata,
    M_AXIS_tvalid,
    aclk,
    aresetn);
  output [31:0]M_AXIS_Y_tdata;
  output M_AXIS_Y_tvalid;
  output [31:0]M_AXIS_tdata;
  output M_AXIS_tvalid;
  input aclk;
  input aresetn;

  wire [31:0]M_AXIS_Y_tdata;
  wire M_AXIS_Y_tvalid;
  wire [31:0]M_AXIS_tdata;
  wire M_AXIS_tvalid;
  wire aclk;
  wire aresetn;

  dut_3 dut_3_i
       (.M_AXIS_Y_tdata(M_AXIS_Y_tdata),
        .M_AXIS_Y_tvalid(M_AXIS_Y_tvalid),
        .M_AXIS_tdata(M_AXIS_tdata),
        .M_AXIS_tvalid(M_AXIS_tvalid),
        .aclk(aclk),
        .aresetn(aresetn));
endmodule
