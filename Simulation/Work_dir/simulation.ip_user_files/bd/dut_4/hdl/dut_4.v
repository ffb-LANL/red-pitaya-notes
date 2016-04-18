//Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
//Date        : Wed Apr 13 09:38:13 2016
//Host        : ffboff running 64-bit Service Pack 1  (build 7601)
//Command     : generate_target dut_4.bd
//Design      : dut_4
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "dut_4,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=dut_4,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=1,numReposBlks=1,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,synth_mode=Global}" *) (* HW_HANDOFF = "dut_4.hwdef" *) 
module dut_4
   (M_AXIS_tdata,
    M_AXIS_tready,
    M_AXIS_tvalid,
    S_AXIS_tdata,
    S_AXIS_tready,
    S_AXIS_tvalid,
    aclk,
    aresetn);
  output [31:0]M_AXIS_tdata;
  input M_AXIS_tready;
  output M_AXIS_tvalid;
  input [31:0]S_AXIS_tdata;
  output S_AXIS_tready;
  input S_AXIS_tvalid;
  input aclk;
  input aresetn;

  wire [31:0]S_AXIS_1_TDATA;
  wire S_AXIS_1_TREADY;
  wire S_AXIS_1_TVALID;
  wire [31:0]axis_data_fifo_0_M_AXIS_TDATA;
  wire axis_data_fifo_0_M_AXIS_TREADY;
  wire axis_data_fifo_0_M_AXIS_TVALID;
  wire s_axis_aclk_1;
  wire s_axis_aresetn_1;

  assign M_AXIS_tdata[31:0] = axis_data_fifo_0_M_AXIS_TDATA;
  assign M_AXIS_tvalid = axis_data_fifo_0_M_AXIS_TVALID;
  assign S_AXIS_1_TDATA = S_AXIS_tdata[31:0];
  assign S_AXIS_1_TVALID = S_AXIS_tvalid;
  assign S_AXIS_tready = S_AXIS_1_TREADY;
  assign axis_data_fifo_0_M_AXIS_TREADY = M_AXIS_tready;
  assign s_axis_aclk_1 = aclk;
  assign s_axis_aresetn_1 = aresetn;
  dut_4_axis_data_fifo_0_0 axis_data_fifo_0
       (.m_axis_tdata(axis_data_fifo_0_M_AXIS_TDATA),
        .m_axis_tready(axis_data_fifo_0_M_AXIS_TREADY),
        .m_axis_tvalid(axis_data_fifo_0_M_AXIS_TVALID),
        .s_axis_aclk(s_axis_aclk_1),
        .s_axis_aresetn(s_axis_aresetn_1),
        .s_axis_tdata(S_AXIS_1_TDATA),
        .s_axis_tready(S_AXIS_1_TREADY),
        .s_axis_tvalid(S_AXIS_1_TVALID));
endmodule
