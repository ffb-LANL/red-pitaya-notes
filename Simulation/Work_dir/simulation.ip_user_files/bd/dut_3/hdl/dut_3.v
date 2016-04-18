//Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
//Date        : Mon Apr 11 11:45:22 2016
//Host        : ffboff running 64-bit Service Pack 1  (build 7601)
//Command     : generate_target dut_3.bd
//Design      : dut_3
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "dut_3,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=dut_3,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=9,numReposBlks=9,numNonXlnxBlks=1,numHierBlks=0,maxHierDepth=0,synth_mode=Global}" *) (* HW_HANDOFF = "dut_3.hwdef" *) 
module dut_3
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

  wire aclk_1;
  wire aresetn_1;
  wire [31:0]axis_broadcaster_0_M00_AXIS_TDATA;
  wire axis_broadcaster_0_M00_AXIS_TREADY;
  wire [0:0]axis_broadcaster_0_M00_AXIS_TVALID;
  wire [63:32]axis_broadcaster_0_M01_AXIS_TDATA;
  wire axis_broadcaster_0_M01_AXIS_TREADY;
  wire [1:1]axis_broadcaster_0_M01_AXIS_TVALID;
  wire [31:0]axis_broadcaster_1_M00_AXIS_TDATA;
  wire axis_broadcaster_1_M00_AXIS_TREADY;
  wire [0:0]axis_broadcaster_1_M00_AXIS_TVALID;
  wire [63:32]axis_broadcaster_1_M01_AXIS_TDATA;
  wire axis_broadcaster_1_M01_AXIS_TREADY;
  wire [1:1]axis_broadcaster_1_M01_AXIS_TVALID;
  wire [63:0]axis_lfsr_0_M_AXIS_TDATA;
  wire axis_lfsr_0_M_AXIS_TREADY;
  wire axis_lfsr_0_M_AXIS_TVALID;
  wire [15:0]axis_subset_converter_0_M_AXIS_TDATA;
  wire axis_subset_converter_0_M_AXIS_TREADY;
  wire axis_subset_converter_0_M_AXIS_TVALID;
  wire [31:0]cic_compiler_0_M_AXIS_DATA_TDATA;
  wire cic_compiler_0_M_AXIS_DATA_TVALID;
  wire [31:0]cic_compiler_1_M_AXIS_DATA_TDATA;
  wire cic_compiler_1_M_AXIS_DATA_TVALID;
  wire [31:0]cic_compiler_2_M_AXIS_DATA_TDATA;
  wire cic_compiler_2_M_AXIS_DATA_TVALID;
  wire [63:0]cmpy_0_M_AXIS_DOUT_TDATA;
  wire cmpy_0_M_AXIS_DOUT_TREADY;
  wire cmpy_0_M_AXIS_DOUT_TVALID;
  wire [31:0]dds_compiler_0_M_AXIS_DATA_TDATA;
  wire dds_compiler_0_M_AXIS_DATA_TREADY;
  wire dds_compiler_0_M_AXIS_DATA_TVALID;

  assign M_AXIS_Y_tdata[31:0] = cic_compiler_1_M_AXIS_DATA_TDATA;
  assign M_AXIS_Y_tvalid = cic_compiler_1_M_AXIS_DATA_TVALID;
  assign M_AXIS_tdata[31:0] = cic_compiler_2_M_AXIS_DATA_TDATA;
  assign M_AXIS_tvalid = cic_compiler_2_M_AXIS_DATA_TVALID;
  assign aclk_1 = aclk;
  assign aresetn_1 = aresetn;
  dut_3_axis_broadcaster_0_0 axis_broadcaster_0
       (.aclk(aclk_1),
        .aresetn(aresetn_1),
        .m_axis_tdata({axis_broadcaster_0_M01_AXIS_TDATA,axis_broadcaster_0_M00_AXIS_TDATA}),
        .m_axis_tready({axis_broadcaster_0_M01_AXIS_TREADY,axis_broadcaster_0_M00_AXIS_TREADY}),
        .m_axis_tvalid({axis_broadcaster_0_M01_AXIS_TVALID,axis_broadcaster_0_M00_AXIS_TVALID}),
        .s_axis_tdata(dds_compiler_0_M_AXIS_DATA_TDATA),
        .s_axis_tready(dds_compiler_0_M_AXIS_DATA_TREADY),
        .s_axis_tvalid(dds_compiler_0_M_AXIS_DATA_TVALID));
  dut_3_axis_broadcaster_1_0 axis_broadcaster_1
       (.aclk(aclk_1),
        .aresetn(aresetn_1),
        .m_axis_tdata({axis_broadcaster_1_M01_AXIS_TDATA,axis_broadcaster_1_M00_AXIS_TDATA}),
        .m_axis_tready({axis_broadcaster_1_M01_AXIS_TREADY,axis_broadcaster_1_M00_AXIS_TREADY}),
        .m_axis_tvalid({axis_broadcaster_1_M01_AXIS_TVALID,axis_broadcaster_1_M00_AXIS_TVALID}),
        .s_axis_tdata(cmpy_0_M_AXIS_DOUT_TDATA),
        .s_axis_tready(cmpy_0_M_AXIS_DOUT_TREADY),
        .s_axis_tvalid(cmpy_0_M_AXIS_DOUT_TVALID));
  dut_3_axis_lfsr_0_0 axis_lfsr_0
       (.aclk(aclk_1),
        .aresetn(aresetn_1),
        .m_axis_tdata(axis_lfsr_0_M_AXIS_TDATA),
        .m_axis_tready(axis_lfsr_0_M_AXIS_TREADY),
        .m_axis_tvalid(axis_lfsr_0_M_AXIS_TVALID));
  dut_3_axis_subset_converter_0_0 axis_subset_converter_0
       (.aclk(aclk_1),
        .aresetn(aresetn_1),
        .m_axis_tdata(axis_subset_converter_0_M_AXIS_TDATA),
        .m_axis_tready(axis_subset_converter_0_M_AXIS_TREADY),
        .m_axis_tvalid(axis_subset_converter_0_M_AXIS_TVALID),
        .s_axis_tdata(axis_broadcaster_0_M00_AXIS_TDATA),
        .s_axis_tready(axis_broadcaster_0_M00_AXIS_TREADY),
        .s_axis_tvalid(axis_broadcaster_0_M00_AXIS_TVALID));
  dut_3_cic_compiler_0_0 cic_compiler_0
       (.aclk(aclk_1),
        .aresetn(aresetn_1),
        .m_axis_data_tdata(cic_compiler_0_M_AXIS_DATA_TDATA),
        .m_axis_data_tvalid(cic_compiler_0_M_AXIS_DATA_TVALID),
        .s_axis_data_tdata(axis_broadcaster_1_M00_AXIS_TDATA),
        .s_axis_data_tready(axis_broadcaster_1_M00_AXIS_TREADY),
        .s_axis_data_tvalid(axis_broadcaster_1_M00_AXIS_TVALID));
  dut_3_cic_compiler_0_1 cic_compiler_1
       (.aclk(aclk_1),
        .aresetn(aresetn_1),
        .m_axis_data_tdata(cic_compiler_1_M_AXIS_DATA_TDATA),
        .m_axis_data_tvalid(cic_compiler_1_M_AXIS_DATA_TVALID),
        .s_axis_data_tdata(axis_broadcaster_1_M01_AXIS_TDATA),
        .s_axis_data_tready(axis_broadcaster_1_M01_AXIS_TREADY),
        .s_axis_data_tvalid(axis_broadcaster_1_M01_AXIS_TVALID));
  dut_3_cic_compiler_2_0 cic_compiler_2
       (.aclk(aclk_1),
        .aresetn(aresetn_1),
        .m_axis_data_tdata(cic_compiler_2_M_AXIS_DATA_TDATA),
        .m_axis_data_tvalid(cic_compiler_2_M_AXIS_DATA_TVALID),
        .s_axis_data_tdata(cic_compiler_0_M_AXIS_DATA_TDATA),
        .s_axis_data_tvalid(cic_compiler_0_M_AXIS_DATA_TVALID));
  dut_3_cmpy_0_1 cmpy_0
       (.aclk(aclk_1),
        .m_axis_dout_tdata(cmpy_0_M_AXIS_DOUT_TDATA),
        .m_axis_dout_tready(cmpy_0_M_AXIS_DOUT_TREADY),
        .m_axis_dout_tvalid(cmpy_0_M_AXIS_DOUT_TVALID),
        .s_axis_a_tdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,axis_subset_converter_0_M_AXIS_TDATA}),
        .s_axis_a_tready(axis_subset_converter_0_M_AXIS_TREADY),
        .s_axis_a_tvalid(axis_subset_converter_0_M_AXIS_TVALID),
        .s_axis_b_tdata(axis_broadcaster_0_M01_AXIS_TDATA),
        .s_axis_b_tready(axis_broadcaster_0_M01_AXIS_TREADY),
        .s_axis_b_tvalid(axis_broadcaster_0_M01_AXIS_TVALID),
        .s_axis_ctrl_tdata(axis_lfsr_0_M_AXIS_TDATA[7:0]),
        .s_axis_ctrl_tready(axis_lfsr_0_M_AXIS_TREADY),
        .s_axis_ctrl_tvalid(axis_lfsr_0_M_AXIS_TVALID));
  dut_3_dds_compiler_0_0 dds_compiler_0
       (.aclk(aclk_1),
        .aresetn(aresetn_1),
        .m_axis_data_tdata(dds_compiler_0_M_AXIS_DATA_TDATA),
        .m_axis_data_tready(dds_compiler_0_M_AXIS_DATA_TREADY),
        .m_axis_data_tvalid(dds_compiler_0_M_AXIS_DATA_TVALID));
endmodule
