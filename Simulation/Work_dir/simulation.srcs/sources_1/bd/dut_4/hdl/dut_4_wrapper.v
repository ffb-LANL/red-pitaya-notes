//Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
//Date        : Sat May 14 12:30:53 2016
//Host        : FFBLP running 64-bit Service Pack 1  (build 7601)
//Command     : generate_target dut_4_wrapper.bd
//Design      : dut_4_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module dut_4_wrapper
   (M_AXIS_tdata,
    M_AXIS_tready,
    M_AXIS_tvalid,
    aclk,
    aresetn,
    cfg_data);
  output [15:0]M_AXIS_tdata;
  input M_AXIS_tready;
  output M_AXIS_tvalid;
  input aclk;
  input aresetn;
  input [15:0]cfg_data;

  wire [15:0]M_AXIS_tdata;
  wire M_AXIS_tready;
  wire M_AXIS_tvalid;
  wire aclk;
  wire aresetn;
  wire [15:0]cfg_data;

  dut_4 dut_4_i
       (.M_AXIS_tdata(M_AXIS_tdata),
        .M_AXIS_tready(M_AXIS_tready),
        .M_AXIS_tvalid(M_AXIS_tvalid),
        .aclk(aclk),
        .aresetn(aresetn),
        .cfg_data(cfg_data));
endmodule
