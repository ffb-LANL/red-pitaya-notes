//Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
//Date        : Sun Feb 21 14:50:35 2016
//Host        : FFBLP running 64-bit Service Pack 1  (build 7601)
//Command     : generate_target DUT_2.bd
//Design      : DUT_2
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "DUT_2,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=DUT_2,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=5,numReposBlks=5,numNonXlnxBlks=2,numHierBlks=0,maxHierDepth=0,synth_mode=Global}" *) (* HW_HANDOFF = "DUT_2.hwdef" *) 
module DUT_2
   (M_AXI_awaddr,
    M_AXI_awburst,
    M_AXI_awcache,
    M_AXI_awid,
    M_AXI_awlen,
    M_AXI_awready,
    M_AXI_awsize,
    M_AXI_awvalid,
    M_AXI_bready,
    M_AXI_wdata,
    M_AXI_wid,
    M_AXI_wlast,
    M_AXI_wready,
    M_AXI_wstrb,
    M_AXI_wvalid,
    aclk,
    aresetn,
    cfg_data,
    enable,
    enable_wr,
    trig);
  output [31:0]M_AXI_awaddr;
  output [1:0]M_AXI_awburst;
  output [3:0]M_AXI_awcache;
  output [5:0]M_AXI_awid;
  output [3:0]M_AXI_awlen;
  input M_AXI_awready;
  output [2:0]M_AXI_awsize;
  output M_AXI_awvalid;
  output M_AXI_bready;
  output [63:0]M_AXI_wdata;
  output [5:0]M_AXI_wid;
  output M_AXI_wlast;
  input M_AXI_wready;
  output [7:0]M_AXI_wstrb;
  output M_AXI_wvalid;
  input aclk;
  input aresetn;
  input [6:0]cfg_data;
  input enable;
  input enable_wr;
  input trig;

  wire aclk_1;
  wire aresetn_1_1;
  wire aresetn_2;
  wire [31:0]axis_circular_packetizer_0_M_AXIS_TDATA;
  wire axis_circular_packetizer_0_M_AXIS_TLAST;
  wire axis_circular_packetizer_0_M_AXIS_TREADY;
  wire axis_circular_packetizer_0_M_AXIS_TVALID;
  wire [63:0]axis_dwidth_converter_0_M_AXIS_TDATA;
  wire axis_dwidth_converter_0_M_AXIS_TREADY;
  wire axis_dwidth_converter_0_M_AXIS_TVALID;
  wire [31:0]axis_ram_writer_0_M_AXI_AWADDR;
  wire [1:0]axis_ram_writer_0_M_AXI_AWBURST;
  wire [3:0]axis_ram_writer_0_M_AXI_AWCACHE;
  wire [5:0]axis_ram_writer_0_M_AXI_AWID;
  wire [3:0]axis_ram_writer_0_M_AXI_AWLEN;
  wire axis_ram_writer_0_M_AXI_AWREADY;
  wire [2:0]axis_ram_writer_0_M_AXI_AWSIZE;
  wire axis_ram_writer_0_M_AXI_AWVALID;
  wire axis_ram_writer_0_M_AXI_BREADY;
  wire [63:0]axis_ram_writer_0_M_AXI_WDATA;
  wire [5:0]axis_ram_writer_0_M_AXI_WID;
  wire axis_ram_writer_0_M_AXI_WLAST;
  wire axis_ram_writer_0_M_AXI_WREADY;
  wire [7:0]axis_ram_writer_0_M_AXI_WSTRB;
  wire axis_ram_writer_0_M_AXI_WVALID;
  wire [6:0]cfg_data_1;
  wire [31:0]dds_compiler_0_M_AXIS_DATA_TDATA;
  wire dds_compiler_0_M_AXIS_DATA_TREADY;
  wire dds_compiler_0_M_AXIS_DATA_TVALID;
  wire enable_1;
  wire trig_1;
  wire [31:0]xlconstant_0_dout;

  assign M_AXI_awaddr[31:0] = axis_ram_writer_0_M_AXI_AWADDR;
  assign M_AXI_awburst[1:0] = axis_ram_writer_0_M_AXI_AWBURST;
  assign M_AXI_awcache[3:0] = axis_ram_writer_0_M_AXI_AWCACHE;
  assign M_AXI_awid[5:0] = axis_ram_writer_0_M_AXI_AWID;
  assign M_AXI_awlen[3:0] = axis_ram_writer_0_M_AXI_AWLEN;
  assign M_AXI_awsize[2:0] = axis_ram_writer_0_M_AXI_AWSIZE;
  assign M_AXI_awvalid = axis_ram_writer_0_M_AXI_AWVALID;
  assign M_AXI_bready = axis_ram_writer_0_M_AXI_BREADY;
  assign M_AXI_wdata[63:0] = axis_ram_writer_0_M_AXI_WDATA;
  assign M_AXI_wid[5:0] = axis_ram_writer_0_M_AXI_WID;
  assign M_AXI_wlast = axis_ram_writer_0_M_AXI_WLAST;
  assign M_AXI_wstrb[7:0] = axis_ram_writer_0_M_AXI_WSTRB;
  assign M_AXI_wvalid = axis_ram_writer_0_M_AXI_WVALID;
  assign aclk_1 = aclk;
  assign aresetn_1_1 = enable_wr;
  assign aresetn_2 = aresetn;
  assign axis_ram_writer_0_M_AXI_AWREADY = M_AXI_awready;
  assign axis_ram_writer_0_M_AXI_WREADY = M_AXI_wready;
  assign cfg_data_1 = cfg_data[6:0];
  assign enable_1 = enable;
  assign trig_1 = trig;
  DUT_2_axis_circular_packetizer_0_0 axis_circular_packetizer_0
       (.aclk(aclk_1),
        .aresetn(enable_1),
        .cfg_data(cfg_data_1),
        .m_axis_tdata(axis_circular_packetizer_0_M_AXIS_TDATA),
        .m_axis_tlast(axis_circular_packetizer_0_M_AXIS_TLAST),
        .m_axis_tready(axis_circular_packetizer_0_M_AXIS_TREADY),
        .m_axis_tvalid(axis_circular_packetizer_0_M_AXIS_TVALID),
        .s_axis_tdata(dds_compiler_0_M_AXIS_DATA_TDATA),
        .s_axis_tready(dds_compiler_0_M_AXIS_DATA_TREADY),
        .s_axis_tvalid(dds_compiler_0_M_AXIS_DATA_TVALID),
        .trigger(trig_1));
  DUT_2_axis_dwidth_converter_0_1 axis_dwidth_converter_0
       (.aclk(aclk_1),
        .aresetn(aresetn_1_1),
        .m_axis_tdata(axis_dwidth_converter_0_M_AXIS_TDATA),
        .m_axis_tready(axis_dwidth_converter_0_M_AXIS_TREADY),
        .m_axis_tvalid(axis_dwidth_converter_0_M_AXIS_TVALID),
        .s_axis_tdata(axis_circular_packetizer_0_M_AXIS_TDATA),
        .s_axis_tlast(axis_circular_packetizer_0_M_AXIS_TLAST),
        .s_axis_tready(axis_circular_packetizer_0_M_AXIS_TREADY),
        .s_axis_tvalid(axis_circular_packetizer_0_M_AXIS_TVALID));
  DUT_2_axis_ram_writer_0_0 axis_ram_writer_0
       (.aclk(aclk_1),
        .aresetn(aresetn_1_1),
        .cfg_data(xlconstant_0_dout),
        .m_axi_awaddr(axis_ram_writer_0_M_AXI_AWADDR),
        .m_axi_awburst(axis_ram_writer_0_M_AXI_AWBURST),
        .m_axi_awcache(axis_ram_writer_0_M_AXI_AWCACHE),
        .m_axi_awid(axis_ram_writer_0_M_AXI_AWID),
        .m_axi_awlen(axis_ram_writer_0_M_AXI_AWLEN),
        .m_axi_awready(axis_ram_writer_0_M_AXI_AWREADY),
        .m_axi_awsize(axis_ram_writer_0_M_AXI_AWSIZE),
        .m_axi_awvalid(axis_ram_writer_0_M_AXI_AWVALID),
        .m_axi_bready(axis_ram_writer_0_M_AXI_BREADY),
        .m_axi_wdata(axis_ram_writer_0_M_AXI_WDATA),
        .m_axi_wid(axis_ram_writer_0_M_AXI_WID),
        .m_axi_wlast(axis_ram_writer_0_M_AXI_WLAST),
        .m_axi_wready(axis_ram_writer_0_M_AXI_WREADY),
        .m_axi_wstrb(axis_ram_writer_0_M_AXI_WSTRB),
        .m_axi_wvalid(axis_ram_writer_0_M_AXI_WVALID),
        .s_axis_tdata(axis_dwidth_converter_0_M_AXIS_TDATA),
        .s_axis_tready(axis_dwidth_converter_0_M_AXIS_TREADY),
        .s_axis_tvalid(axis_dwidth_converter_0_M_AXIS_TVALID));
  DUT_2_dds_compiler_0_0 dds_compiler_0
       (.aclk(aclk_1),
        .aresetn(aresetn_2),
        .m_axis_data_tdata(dds_compiler_0_M_AXIS_DATA_TDATA),
        .m_axis_data_tready(dds_compiler_0_M_AXIS_DATA_TREADY),
        .m_axis_data_tvalid(dds_compiler_0_M_AXIS_DATA_TVALID));
  DUT_2_xlconstant_0_0 xlconstant_0
       (.dout(xlconstant_0_dout));
endmodule
