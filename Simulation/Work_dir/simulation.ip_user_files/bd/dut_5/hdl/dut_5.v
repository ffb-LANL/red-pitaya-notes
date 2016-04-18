//Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
//Date        : Wed Apr 13 13:37:06 2016
//Host        : ffboff running 64-bit Service Pack 1  (build 7601)
//Command     : generate_target dut_5.bd
//Design      : dut_5
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "dut_5,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=dut_5,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=1,numReposBlks=1,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,synth_mode=Global}" *) (* HW_HANDOFF = "dut_5.hwdef" *) 
module dut_5
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

  wire [31:0]S_AXIS_DATA_1_TDATA;
  wire S_AXIS_DATA_1_TREADY;
  wire S_AXIS_DATA_1_TVALID;
  wire aclk_1;
  wire aresetn_1;
  wire [31:0]cic_compiler_0_M_AXIS_DATA_TDATA;
  wire cic_compiler_0_M_AXIS_DATA_TVALID;

  assign M_AXIS_tdata[31:0] = cic_compiler_0_M_AXIS_DATA_TDATA;
  assign M_AXIS_tvalid = cic_compiler_0_M_AXIS_DATA_TVALID;
  assign S_AXIS_DATA_1_TDATA = S_AXIS_tdata[31:0];
  assign S_AXIS_DATA_1_TVALID = S_AXIS_tvalid;
  assign S_AXIS_tready = S_AXIS_DATA_1_TREADY;
  assign aclk_1 = aclk;
  assign aresetn_1 = aresetn;
  dut_5_cic_compiler_0_0 cic_compiler_0
       (.aclk(aclk_1),
        .aresetn(aresetn_1),
        .m_axis_data_tdata(cic_compiler_0_M_AXIS_DATA_TDATA),
        .m_axis_data_tvalid(cic_compiler_0_M_AXIS_DATA_TVALID),
        .s_axis_data_tdata(S_AXIS_DATA_1_TDATA),
        .s_axis_data_tready(S_AXIS_DATA_1_TREADY),
        .s_axis_data_tvalid(S_AXIS_DATA_1_TVALID));
endmodule
