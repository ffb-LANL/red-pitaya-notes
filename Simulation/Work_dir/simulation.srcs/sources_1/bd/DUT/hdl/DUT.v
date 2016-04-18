//Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
//Date        : Fri Apr 08 14:24:51 2016
//Host        : ffboff running 64-bit Service Pack 1  (build 7601)
//Command     : generate_target DUT.bd
//Design      : DUT
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "DUT,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=DUT,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=7,numReposBlks=7,numNonXlnxBlks=3,numHierBlks=0,maxHierDepth=0,synth_mode=Global}" *) (* HW_HANDOFF = "DUT.hwdef" *) 
module DUT
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

  wire aclk_1;
  wire aresetn_1;
  wire [15:0]axis_clock_converter_0_M_AXIS_TDATA;
  wire axis_clock_converter_0_M_AXIS_TREADY;
  wire [1:0]axis_clock_converter_0_M_AXIS_TUSER;
  wire axis_clock_converter_0_M_AXIS_TVALID;
  wire [15:0]axis_subset_converter_0_M_AXIS_TDATA;
  wire axis_subset_converter_0_M_AXIS_TREADY;
  wire axis_subset_converter_0_M_AXIS_TVALID;
  wire axis_subset_converter_0_s_axis_tready;
  wire [15:0]axis_usr_merge_0_M_AXIS_TDATA;
  wire axis_usr_merge_0_M_AXIS_TREADY;
  wire [0:0]axis_usr_merge_0_M_AXIS_TUSER;
  wire axis_usr_merge_0_M_AXIS_TVALID;
  wire [15:0]axis_usr_split_0_M_AXIS_TDATA;
  wire axis_usr_split_0_M_AXIS_TREADY;
  wire axis_usr_split_0_M_AXIS_TVALID;
  wire [0:0]axis_usr_split_0_user_data;
  wire clk_wiz_0_clk_out1;
  wire [31:0]dds_compiler_0_M_AXIS_DATA_TDATA;
  wire dds_compiler_0_M_AXIS_DATA_TVALID;
  wire [31:0]dds_compiler_0_M_AXIS_PHASE_TDATA;
  wire dds_compiler_0_M_AXIS_PHASE_TVALID;
  wire trig_1;

  assign M_AXIS_tdata[15:0] = axis_usr_split_0_M_AXIS_TDATA;
  assign M_AXIS_tvalid = axis_usr_split_0_M_AXIS_TVALID;
  assign aclk_1 = aclk;
  assign aresetn_1 = aresetn;
  assign axis_usr_split_0_M_AXIS_TREADY = M_AXIS_tready;
  assign clk_out1 = clk_wiz_0_clk_out1;
  assign trig_1 = trig;
  assign trig_out[0] = axis_usr_split_0_user_data;
  DUT_axis_clock_converter_0_0 axis_clock_converter_0
       (.m_axis_aclk(clk_wiz_0_clk_out1),
        .m_axis_aresetn(aresetn_1),
        .m_axis_tdata(axis_clock_converter_0_M_AXIS_TDATA),
        .m_axis_tready(axis_clock_converter_0_M_AXIS_TREADY),
        .m_axis_tuser(axis_clock_converter_0_M_AXIS_TUSER),
        .m_axis_tvalid(axis_clock_converter_0_M_AXIS_TVALID),
        .s_axis_aclk(aclk_1),
        .s_axis_aresetn(aresetn_1),
        .s_axis_tdata(axis_usr_merge_0_M_AXIS_TDATA),
        .s_axis_tready(axis_usr_merge_0_M_AXIS_TREADY),
        .s_axis_tuser({1'b0,axis_usr_merge_0_M_AXIS_TUSER}),
        .s_axis_tvalid(axis_usr_merge_0_M_AXIS_TVALID));
  DUT_axis_snapshot_0_0 axis_snapshot_0
       (.aclk(aclk_1),
        .aresetn(trig_1),
        .s_axis_tdata(dds_compiler_0_M_AXIS_PHASE_TDATA),
        .s_axis_tvalid(dds_compiler_0_M_AXIS_PHASE_TVALID));
  DUT_axis_subset_converter_0_0 axis_subset_converter_0
       (.aclk(aclk_1),
        .aresetn(aresetn_1),
        .m_axis_tdata(axis_subset_converter_0_M_AXIS_TDATA),
        .m_axis_tready(axis_subset_converter_0_M_AXIS_TREADY),
        .m_axis_tvalid(axis_subset_converter_0_M_AXIS_TVALID),
        .s_axis_tdata(dds_compiler_0_M_AXIS_DATA_TDATA),
        .s_axis_tready(axis_subset_converter_0_s_axis_tready),
        .s_axis_tvalid(dds_compiler_0_M_AXIS_DATA_TVALID));
  DUT_axis_usr_merge_0_0 axis_usr_merge_0
       (.aclk(aclk_1),
        .m_axis_tdata(axis_usr_merge_0_M_AXIS_TDATA),
        .m_axis_tready(axis_usr_merge_0_M_AXIS_TREADY),
        .m_axis_tuser(axis_usr_merge_0_M_AXIS_TUSER),
        .m_axis_tvalid(axis_usr_merge_0_M_AXIS_TVALID),
        .s_axis_tdata(axis_subset_converter_0_M_AXIS_TDATA),
        .s_axis_tready(axis_subset_converter_0_M_AXIS_TREADY),
        .s_axis_tvalid(axis_subset_converter_0_M_AXIS_TVALID),
        .user_data(trig_1));
  DUT_axis_usr_split_0_0 axis_usr_split_0
       (.aclk(clk_wiz_0_clk_out1),
        .m_axis_tdata(axis_usr_split_0_M_AXIS_TDATA),
        .m_axis_tready(axis_usr_split_0_M_AXIS_TREADY),
        .m_axis_tvalid(axis_usr_split_0_M_AXIS_TVALID),
        .s_axis_tdata(axis_clock_converter_0_M_AXIS_TDATA),
        .s_axis_tready(axis_clock_converter_0_M_AXIS_TREADY),
        .s_axis_tuser(axis_clock_converter_0_M_AXIS_TUSER[0]),
        .s_axis_tvalid(axis_clock_converter_0_M_AXIS_TVALID),
        .user_data(axis_usr_split_0_user_data));
  DUT_clk_wiz_0_0 clk_wiz_0
       (.clk_in1(aclk_1),
        .clk_out1(clk_wiz_0_clk_out1),
        .reset(1'b0));
  DUT_dds_compiler_0_0 dds_compiler_0
       (.aclk(aclk_1),
        .m_axis_data_tdata(dds_compiler_0_M_AXIS_DATA_TDATA),
        .m_axis_data_tready(axis_subset_converter_0_s_axis_tready),
        .m_axis_data_tvalid(dds_compiler_0_M_AXIS_DATA_TVALID),
        .m_axis_phase_tdata(dds_compiler_0_M_AXIS_PHASE_TDATA),
        .m_axis_phase_tready(axis_subset_converter_0_s_axis_tready),
        .m_axis_phase_tvalid(dds_compiler_0_M_AXIS_PHASE_TVALID));
endmodule
