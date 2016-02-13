//Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
//Date        : Sat Feb 13 11:16:59 2016
//Host        : FFBLP running 64-bit Service Pack 1  (build 7601)
//Command     : generate_target DUT.bd
//Design      : DUT
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "DUT,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=DUT,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=2,numReposBlks=2,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,synth_mode=Global}" *) (* HW_HANDOFF = "DUT.hwdef" *) 
module DUT
   (M_AXIS_tdata,
    M_AXIS_tready,
    M_AXIS_tvalid,
    aclk,
    aresetn);
  output [15:0]M_AXIS_tdata;
  input M_AXIS_tready;
  output M_AXIS_tvalid;
  input aclk;
  input aresetn;

  wire aclk_1;
  wire aresetn_1;
  wire [15:0]axis_subset_converter_0_M_AXIS_TDATA;
  wire axis_subset_converter_0_M_AXIS_TREADY;
  wire axis_subset_converter_0_M_AXIS_TVALID;
  wire [31:0]dds_compiler_0_M_AXIS_DATA_TDATA;
  wire dds_compiler_0_M_AXIS_DATA_TREADY;
  wire dds_compiler_0_M_AXIS_DATA_TVALID;

  assign M_AXIS_tdata[15:0] = axis_subset_converter_0_M_AXIS_TDATA;
  assign M_AXIS_tvalid = axis_subset_converter_0_M_AXIS_TVALID;
  assign aclk_1 = aclk;
  assign aresetn_1 = aresetn;
  assign axis_subset_converter_0_M_AXIS_TREADY = M_AXIS_tready;
  DUT_axis_subset_converter_0_0 axis_subset_converter_0
       (.aclk(aclk_1),
        .aresetn(aresetn_1),
        .m_axis_tdata(axis_subset_converter_0_M_AXIS_TDATA),
        .m_axis_tready(axis_subset_converter_0_M_AXIS_TREADY),
        .m_axis_tvalid(axis_subset_converter_0_M_AXIS_TVALID),
        .s_axis_tdata(dds_compiler_0_M_AXIS_DATA_TDATA),
        .s_axis_tready(dds_compiler_0_M_AXIS_DATA_TREADY),
        .s_axis_tvalid(dds_compiler_0_M_AXIS_DATA_TVALID));
  DUT_dds_compiler_0_0 dds_compiler_0
       (.aclk(aclk_1),
        .aresetn(aresetn_1),
        .m_axis_data_tdata(dds_compiler_0_M_AXIS_DATA_TDATA),
        .m_axis_data_tready(dds_compiler_0_M_AXIS_DATA_TREADY),
        .m_axis_data_tvalid(dds_compiler_0_M_AXIS_DATA_TVALID));
endmodule
