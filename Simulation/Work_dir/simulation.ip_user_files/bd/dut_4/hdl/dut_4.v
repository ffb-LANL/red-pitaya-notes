//Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
//Date        : Sat May 14 12:05:19 2016
//Host        : FFBLP running 64-bit Service Pack 1  (build 7601)
//Command     : generate_target dut_4.bd
//Design      : dut_4
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "dut_4,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=dut_4,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=2,numReposBlks=2,numNonXlnxBlks=1,numHierBlks=0,maxHierDepth=0,synth_mode=Global}" *) (* HW_HANDOFF = "dut_4.hwdef" *) 
module dut_4
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

  wire Net;
  wire Net1;
  wire [15:0]axis_variable_0_M_AXIS_TDATA;
  wire axis_variable_0_M_AXIS_TREADY;
  wire axis_variable_0_M_AXIS_TVALID;
  wire [15:0]cfg_data_1;
  wire [15:0]dds_compiler_0_M_AXIS_PHASE_TDATA;
  wire dds_compiler_0_M_AXIS_PHASE_TREADY;
  wire dds_compiler_0_M_AXIS_PHASE_TVALID;

  assign M_AXIS_tdata[15:0] = dds_compiler_0_M_AXIS_PHASE_TDATA;
  assign M_AXIS_tvalid = dds_compiler_0_M_AXIS_PHASE_TVALID;
  assign Net = aresetn;
  assign Net1 = aclk;
  assign cfg_data_1 = cfg_data[15:0];
  assign dds_compiler_0_M_AXIS_PHASE_TREADY = M_AXIS_tready;
  dut_4_axis_variable_0_0 axis_variable_0
       (.aclk(Net1),
        .aresetn(Net),
        .cfg_data(cfg_data_1),
        .m_axis_tdata(axis_variable_0_M_AXIS_TDATA),
        .m_axis_tready(axis_variable_0_M_AXIS_TREADY),
        .m_axis_tvalid(axis_variable_0_M_AXIS_TVALID));
  dut_4_dds_compiler_0_0 dds_compiler_0
       (.aclk(Net1),
        .aresetn(Net),
        .m_axis_phase_tdata(dds_compiler_0_M_AXIS_PHASE_TDATA),
        .m_axis_phase_tready(dds_compiler_0_M_AXIS_PHASE_TREADY),
        .m_axis_phase_tvalid(dds_compiler_0_M_AXIS_PHASE_TVALID),
        .s_axis_config_tdata(axis_variable_0_M_AXIS_TDATA),
        .s_axis_config_tready(axis_variable_0_M_AXIS_TREADY),
        .s_axis_config_tvalid(axis_variable_0_M_AXIS_TVALID));
endmodule
