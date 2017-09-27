//Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2016.2 (win64) Build 1577090 Thu Jun  2 16:32:40 MDT 2016
//Date        : Tue Sep 26 17:26:30 2017
//Host        : ffboff running 64-bit Service Pack 1  (build 7601)
//Command     : generate_target DUT_IV.bd
//Design      : DUT_IV
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "DUT_IV,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=DUT_IV,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=4,numReposBlks=4,numNonXlnxBlks=2,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "DUT_IV.hwdef" *) 
module DUT_IV
   (M_AXIS_DATA_tdata,
    M_AXIS_DATA_tready,
    M_AXIS_DATA_tvalid,
    M_AXIS_tdata,
    M_AXIS_tlast,
    M_AXIS_tready,
    M_AXIS_tvalid,
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
  output [15:0]M_AXIS_DATA_tdata;
  input M_AXIS_DATA_tready;
  output M_AXIS_DATA_tvalid;
  output [15:0]M_AXIS_tdata;
  output M_AXIS_tlast;
  input M_AXIS_tready;
  output M_AXIS_tvalid;
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
  output overload;
  output [31:0]sts_data;

  wire [15:0]S_AXIS_1_TDATA;
  wire S_AXIS_1_TREADY;
  wire S_AXIS_1_TVALID;
  wire [15:0]S_AXIS_DATA_1_TDATA;
  wire S_AXIS_DATA_1_TREADY;
  wire S_AXIS_DATA_1_TVALID;
  wire aclk_1;
  wire aresetn_1;
  wire [15:0]axis_measure_pulse_0_BRAM_PORTA_ADDR;
  wire axis_measure_pulse_0_BRAM_PORTA_CLK;
  wire [15:0]axis_measure_pulse_0_BRAM_PORTA_DOUT;
  wire [15:0]axis_measure_pulse_0_M_AXIS_TDATA;
  wire axis_measure_pulse_0_M_AXIS_TLAST;
  wire axis_measure_pulse_0_M_AXIS_TREADY;
  wire axis_measure_pulse_0_M_AXIS_TVALID;
  wire axis_measure_pulse_0_overload;
  wire [31:0]axis_measure_pulse_0_sts_data;
  wire [159:0]\^cfg_data_1 ;
  wire [31:0]cfg_data_1_1;
  wire [15:0]cic_compiler_0_M_AXIS_DATA_TDATA;
  wire cic_compiler_0_M_AXIS_DATA_TREADY;
  wire cic_compiler_0_M_AXIS_DATA_TVALID;

  assign M_AXIS_DATA_tdata[15:0] = cic_compiler_0_M_AXIS_DATA_TDATA;
  assign M_AXIS_DATA_tvalid = cic_compiler_0_M_AXIS_DATA_TVALID;
  assign M_AXIS_tdata[15:0] = axis_measure_pulse_0_M_AXIS_TDATA;
  assign M_AXIS_tlast = axis_measure_pulse_0_M_AXIS_TLAST;
  assign M_AXIS_tvalid = axis_measure_pulse_0_M_AXIS_TVALID;
  assign S_AXIS_1_TDATA = S_AXIS_tdata[15:0];
  assign S_AXIS_1_TVALID = S_AXIS_tvalid;
  assign S_AXIS_DATA_1_TDATA = S_AXIS_DATA_tdata[15:0];
  assign S_AXIS_DATA_1_TVALID = S_AXIS_DATA_tvalid;
  assign S_AXIS_DATA_tready = S_AXIS_DATA_1_TREADY;
  assign S_AXIS_tready = S_AXIS_1_TREADY;
  assign \^cfg_data_1 [159:0] = cfg_data[159:0];
  assign aclk_1 = aclk;
  assign aresetn_1 = aresetn;
  assign axis_measure_pulse_0_M_AXIS_TREADY = M_AXIS_tready;
  assign cfg_data_1_1 = cfg_data_1[31:0];
  assign cic_compiler_0_M_AXIS_DATA_TREADY = M_AXIS_DATA_tready;
  assign overload = axis_measure_pulse_0_overload;
  assign sts_data[31:0] = axis_measure_pulse_0_sts_data;
  DUT_IV_axis_measure_pulse_0_1 axis_measure_pulse_0
       (.aclk(aclk_1),
        .aresetn(aresetn_1),
        .bram_porta_addr(axis_measure_pulse_0_BRAM_PORTA_ADDR),
        .bram_porta_clk(axis_measure_pulse_0_BRAM_PORTA_CLK),
        .bram_porta_rddata(axis_measure_pulse_0_BRAM_PORTA_DOUT),
        .cfg_data(\^cfg_data_1 ),
        .m_axis_tdata(axis_measure_pulse_0_M_AXIS_TDATA),
        .m_axis_tlast(axis_measure_pulse_0_M_AXIS_TLAST),
        .m_axis_tready(axis_measure_pulse_0_M_AXIS_TREADY),
        .m_axis_tvalid(axis_measure_pulse_0_M_AXIS_TVALID),
        .overload(axis_measure_pulse_0_overload),
        .s_axis_tdata(S_AXIS_1_TDATA),
        .s_axis_tready(S_AXIS_1_TREADY),
        .s_axis_tvalid(S_AXIS_1_TVALID),
        .sts_data(axis_measure_pulse_0_sts_data));
  DUT_IV_axis_variable_0_0 axis_variable_0
       (.aclk(aclk_1),
        .aresetn(aresetn_1),
        .cfg_data(cfg_data_1_1),
        .m_axis_tready(1'b0));
  DUT_IV_blk_mem_gen_0_0 blk_mem_gen_0
       (.addra(axis_measure_pulse_0_BRAM_PORTA_ADDR[12:0]),
        .addrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .clka(axis_measure_pulse_0_BRAM_PORTA_CLK),
        .clkb(1'b0),
        .dina({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .dinb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .douta(axis_measure_pulse_0_BRAM_PORTA_DOUT),
        .wea(1'b0),
        .web(1'b0));
  DUT_IV_cic_compiler_0_0 cic_compiler_0
       (.aclk(aclk_1),
        .aresetn(aresetn_1),
        .m_axis_data_tdata(cic_compiler_0_M_AXIS_DATA_TDATA),
        .m_axis_data_tready(cic_compiler_0_M_AXIS_DATA_TREADY),
        .m_axis_data_tvalid(cic_compiler_0_M_AXIS_DATA_TVALID),
        .s_axis_data_tdata(S_AXIS_DATA_1_TDATA),
        .s_axis_data_tready(S_AXIS_DATA_1_TREADY),
        .s_axis_data_tvalid(S_AXIS_DATA_1_TVALID));
endmodule
