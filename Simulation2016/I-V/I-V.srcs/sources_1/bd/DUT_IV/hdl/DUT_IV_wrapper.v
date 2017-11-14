//Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2016.2 (win64) Build 1577090 Thu Jun  2 16:32:40 MDT 2016
//Date        : Wed Nov 08 17:03:02 2017
//Host        : ffboff running 64-bit Service Pack 1  (build 7601)
//Command     : generate_target DUT_IV_wrapper.bd
//Design      : DUT_IV_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module DUT_IV_wrapper
   (M_AXIS_1_tdata,
    M_AXIS_1_tready,
    M_AXIS_1_tvalid,
    M_AXIS_DATA_tdata,
    M_AXIS_DATA_tready,
    M_AXIS_DATA_tvalid,
    M_AXIS_tdata,
    M_AXIS_tlast,
    M_AXIS_tready,
    M_AXIS_tvalid,
    S_AXIS_1_tdata,
    S_AXIS_1_tready,
    S_AXIS_1_tvalid,
    S_AXIS_DATA_tdata,
    S_AXIS_DATA_tready,
    S_AXIS_DATA_tvalid,
    S_AXIS_tdata,
    S_AXIS_tready,
    S_AXIS_tvalid,
    aclk,
    aresetn,
    cfg_data,
    cfg_data_1,
    overload,
    sts_data);
  output [7:0]M_AXIS_1_tdata;
  input M_AXIS_1_tready;
  output M_AXIS_1_tvalid;
  output [15:0]M_AXIS_DATA_tdata;
  input M_AXIS_DATA_tready;
  output M_AXIS_DATA_tvalid;
  output [15:0]M_AXIS_tdata;
  output M_AXIS_tlast;
  input M_AXIS_tready;
  output M_AXIS_tvalid;
  input [23:0]S_AXIS_1_tdata;
  output S_AXIS_1_tready;
  input S_AXIS_1_tvalid;
  input [15:0]S_AXIS_DATA_tdata;
  output S_AXIS_DATA_tready;
  input S_AXIS_DATA_tvalid;
  input [15:0]S_AXIS_tdata;
  output S_AXIS_tready;
  input S_AXIS_tvalid;
  input aclk;
  input aresetn;
  input [159:0]cfg_data;
  input [31:0]cfg_data_1;
  output [2:0]overload;
  output [31:0]sts_data;

  wire [7:0]M_AXIS_1_tdata;
  wire M_AXIS_1_tready;
  wire M_AXIS_1_tvalid;
  wire [15:0]M_AXIS_DATA_tdata;
  wire M_AXIS_DATA_tready;
  wire M_AXIS_DATA_tvalid;
  wire [15:0]M_AXIS_tdata;
  wire M_AXIS_tlast;
  wire M_AXIS_tready;
  wire M_AXIS_tvalid;
  wire [23:0]S_AXIS_1_tdata;
  wire S_AXIS_1_tready;
  wire S_AXIS_1_tvalid;
  wire [15:0]S_AXIS_DATA_tdata;
  wire S_AXIS_DATA_tready;
  wire S_AXIS_DATA_tvalid;
  wire [15:0]S_AXIS_tdata;
  wire S_AXIS_tready;
  wire S_AXIS_tvalid;
  wire aclk;
  wire aresetn;
  wire [159:0]cfg_data;
  wire [31:0]cfg_data_1;
  wire [2:0]overload;
  wire [31:0]sts_data;

  DUT_IV DUT_IV_i
       (.M_AXIS_1_tdata(M_AXIS_1_tdata),
        .M_AXIS_1_tready(M_AXIS_1_tready),
        .M_AXIS_1_tvalid(M_AXIS_1_tvalid),
        .M_AXIS_DATA_tdata(M_AXIS_DATA_tdata),
        .M_AXIS_DATA_tready(M_AXIS_DATA_tready),
        .M_AXIS_DATA_tvalid(M_AXIS_DATA_tvalid),
        .M_AXIS_tdata(M_AXIS_tdata),
        .M_AXIS_tlast(M_AXIS_tlast),
        .M_AXIS_tready(M_AXIS_tready),
        .M_AXIS_tvalid(M_AXIS_tvalid),
        .S_AXIS_1_tdata(S_AXIS_1_tdata),
        .S_AXIS_1_tready(S_AXIS_1_tready),
        .S_AXIS_1_tvalid(S_AXIS_1_tvalid),
        .S_AXIS_DATA_tdata(S_AXIS_DATA_tdata),
        .S_AXIS_DATA_tready(S_AXIS_DATA_tready),
        .S_AXIS_DATA_tvalid(S_AXIS_DATA_tvalid),
        .S_AXIS_tdata(S_AXIS_tdata),
        .S_AXIS_tready(S_AXIS_tready),
        .S_AXIS_tvalid(S_AXIS_tvalid),
        .aclk(aclk),
        .aresetn(aresetn),
        .cfg_data(cfg_data),
        .cfg_data_1(cfg_data_1),
        .overload(overload),
        .sts_data(sts_data));
endmodule
