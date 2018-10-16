#lockin_sweep 103

# Create clk_wiz
cell xilinx.com:ip:clk_wiz:6.0 pll_0 {
  PRIMITIVE PLL
  PRIM_IN_FREQ.VALUE_SRC USER
  PRIM_IN_FREQ 125.0
  PRIM_SOURCE Differential_clock_capable_pin
  CLKOUT1_USED true
  CLKOUT1_REQUESTED_OUT_FREQ 125.0
  CLKOUT2_USED true
  CLKOUT2_REQUESTED_OUT_FREQ 250.0
  CLKOUT2_REQUESTED_PHASE -90.0
  USE_RESET false
} {
  clk_in1_p adc_clk_p_i
  clk_in1_n adc_clk_n_i
}

# Create processing_system7
cell xilinx.com:ip:processing_system7:5.5 ps_0 {
  PCW_IMPORT_BOARD_PRESET cfg/red_pitaya.xml
  PCW_USE_S_AXI_HP0 1
} {
  M_AXI_GP0_ACLK pll_0/clk_out1
  S_AXI_HP0_ACLK pll_0/clk_out1
}

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {
  make_external {FIXED_IO, DDR}
  Master Disable
  Slave Disable
} [get_bd_cells ps_0]

# Create xlconstant
cell xilinx.com:ip:xlconstant:1.1 const_0

# Create proc_sys_reset
cell xilinx.com:ip:proc_sys_reset:5.0 rst_0 {} {
  ext_reset_in const_0/dout
}

# Create axis_red_pitaya_adc
cell pavel-demin:user:axis_red_pitaya_adc:2.0 adc_0 {} {
  aclk pll_0/clk_out1
  adc_dat_a adc_dat_a_i
  adc_dat_b adc_dat_b_i
  adc_csn adc_csn_o
}

# Create c_counter_binary
cell xilinx.com:ip:c_counter_binary:12.0 cntr_0 {
  Output_Width 32
} {
  CLK pll_0/clk_out1
}

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_0 {
  DIN_WIDTH 32 DIN_FROM 25 DIN_TO 25 DOUT_WIDTH 1
} {
  Din cntr_0/Q
 }

# Create axi_cfg_register
cell pavel-demin:user:axi_cfg_register:1.0 cfg_0 {
  CFG_DATA_WIDTH 256
  AXI_ADDR_WIDTH 32
  AXI_DATA_WIDTH 32
}

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Master /ps_0/M_AXI_GP0
  Clk Auto
} [get_bd_intf_pins cfg_0/S_AXI]

set_property RANGE 4K [get_bd_addr_segs ps_0/Data/SEG_cfg_0_reg0]
set_property OFFSET 0x40000000 [get_bd_addr_segs ps_0/Data/SEG_cfg_0_reg0]

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_1 {
  DIN_WIDTH 256 DIN_FROM 129 DIN_TO 128 
} {
  Din cfg_0/cfg_data
}

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_trx_reset {
  DIN_WIDTH 256 DIN_FROM 4 DIN_TO 4
} {
  Din cfg_0/cfg_data
}


# Create xlconcat
cell xilinx.com:ip:xlconcat:2.1 concat_0 {
  IN1_WIDTH 2
} {
  In0 slice_0/Dout
  In1 slice_1/Dout
  dout led_o
}

# Create xlconstant
cell xilinx.com:ip:xlconstant:1.1 const_1

# Create axis_subset_converter
cell xilinx.com:ip:axis_subset_converter:1.1 subset_ADC_A {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  M_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 4
  M_TDATA_NUM_BYTES 2
  TDATA_REMAP {tdata[15:0]}
} {
 s_axis adc_0/M_AXIS
  aclk pll_0/clk_out1
  aresetn slice_trx_reset/dout
}


# Create axi_axis_writer
cell pavel-demin:user:axi_axis_writer:1.0 writer_f {
  AXI_DATA_WIDTH 32
} {
  aclk /pll_0/clk_out1
  aresetn slice_trx_reset/dout
}

# Create axis_data_fifo
cell xilinx.com:ip:axis_data_fifo:1.1 fifo_f {
  FIFO_DEPTH 16384
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 4
} {
  s_axis  writer_f/m_axis
  s_axis_aclk pll_0/clk_out1
  s_axis_aresetn slice_trx_reset/dout
}

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_decimate {
  DIN_WIDTH 256 DIN_FROM 127 DIN_TO 96
} {
  Din cfg_0/cfg_data
}

# Create xlconcat
cell xilinx.com:ip:xlconcat:2.1 concat_interpol {
 IN0_WIDTH 13
 IN1_WIDTH 19
} {

  In1 slice_decimate/Dout

}


# Create axis_interpolator
cell pavel-demin:user:axis_interpolator:1.0 inter_f {
  AXIS_TDATA_WIDTH 32
  CNTR_WIDTH 32
} {
  S_AXIS fifo_f/M_AXIS
  cfg_data concat_interpol/Dout
  aclk pll_0/clk_out1
  aresetn slice_trx_reset/dout
}

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Master /ps_0/M_AXI_GP0
  Clk Auto
} [get_bd_intf_pins writer_f/S_AXI]

set_property RANGE 256K [get_bd_addr_segs ps_0/Data/SEG_writer_f_reg0]
set_property OFFSET 0x40040000 [get_bd_addr_segs ps_0/Data/SEG_writer_f_reg0]


# Create axis_broadcaster
cell xilinx.com:ip:axis_broadcaster:1.1 bcast_f {
  S_TDATA_NUM_BYTES 4
  M_TDATA_NUM_BYTES 4
 } {
  S_AXIS inter_f/m_axis
  aclk pll_0/clk_out1
  aresetn slice_trx_reset/dout
}


# Create dds_compiler
cell xilinx.com:ip:dds_compiler:6.0 dds_0 {
  DDS_CLOCK_RATE 125
  parameter_entry Hardware_Parameters
  OUTPUT_WIDTH 14
  PHASE_WIDTH 32 
 PHASE_INCREMENT Streaming
  DSP48_USE Maximal
  HAS_TREADY true
  HAS_PHASE_OUT false
  HAS_ARESETn true
} {
  S_AXIS_PHASE bcast_f/M00_AXIS
  aclk pll_0/clk_out1
  aresetn slice_trx_reset/dout
}

# Create axis_broadcaster
cell xilinx.com:ip:axis_broadcaster:1.1 bcast_DDS {
  S_TDATA_NUM_BYTES 4
  M_TDATA_NUM_BYTES 4
 } {
  S_AXIS dds_0/M_AXIS_DATA
  aclk pll_0/clk_out1
  aresetn slice_trx_reset/dout
}

# Create axis_lfsr
cell pavel-demin:user:axis_lfsr:1.0 lfsr_0 {} {
  aclk pll_0/clk_out1
  aresetn slice_trx_reset/dout
}

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_dds_delay {
  DIN_WIDTH 256 DIN_FROM 255 DIN_TO 224
} {
  Din cfg_0/cfg_data
}

# create delay
cell pavel-demin:user:axis_fixed_delay:1.0 delay_dds { 
 DEPTH 17
} {
  s_axis bcast_DDS/M01_AXIS
  aclk pll_0/clk_out1
}

# Create cmpy
cell xilinx.com:ip:cmpy:6.0 mult_0 {
  FLOWCONTROL Blocking
  APORTWIDTH.VALUE_SRC USER
  BPORTWIDTH.VALUE_SRC USER
  APORTWIDTH 14
  BPORTWIDTH 14
  ROUNDMODE Random_Rounding
  OUTPUTWIDTH 28
  aresetn true
} {
  S_AXIS_A subset_ADC_A/M_AXIS
  s_axis_b delay_dds/M_AXIS
  S_AXIS_CTRL lfsr_0/M_AXIS
  aclk pll_0/clk_out1
  aresetn slice_trx_reset/dout
}

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 scale_factor {
  DIN_WIDTH 256 DIN_FROM 159 DIN_TO 144
} {
  Din cfg_0/cfg_data
}


# Create axis_scaler
cell pavel-demin:user:axis_scaler:1.0 scaler {
  AXIS_TDATA_WIDTH 14
} {
  S_AXIS bcast_DDS/M00_AXIS
  cfg_data scale_factor/Dout
  aclk pll_0/clk_out1
  aresetn slice_trx_reset/dout
}


# Create axis_red_pitaya_dac
cell pavel-demin:user:axis_red_pitaya_dac:1.0 dac_0 {} {
  aclk pll_0/clk_out1
  ddr_clk pll_0/clk_out2
  locked pll_0/locked
  S_AXIS scaler/M_AXIS
  dac_clk dac_clk_o
  dac_rst dac_rst_o
  dac_sel dac_sel_o
  dac_wrt dac_wrt_o
  dac_dat dac_dat_o
}

# create filter
module filter_xy {
  source projects/filter_test/filter_xy.tcl
} {
  s_axis mult_0/M_AXIS_DOUT
  cfg cfg_0/cfg_data
  aclk pll_0/clk_out1
  aresetn slice_trx_reset/dout
}

# create delay
cell pavel-demin:user:axis_fixed_delay:1.0 delay_f { 
 DEPTH 16
} {
  s_axis bcast_f/M01_AXIS
  aclk pll_0/clk_out1
}

# Create axis_decimator
cell pavel-demin:user:axis_decimator:1.0 dcmtr_f {
  AXIS_TDATA_WIDTH 32
  CNTR_WIDTH 32
} {
  S_AXIS delay_f/M_AXIS
  cfg_data concat_interpol/Dout
  aclk pll_0/clk_out1
  aresetn slice_trx_reset/dout
}

# Create axis_combiner
cell  xilinx.com:ip:axis_combiner:1.1 comb_xyf {
  NUM_SI 3
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 4
} {
  S00_AXIS dcmtr_f/M_AXIS
  S01_AXIS filter_xy/M_AXIS_x
  S02_AXIS filter_xy/M_AXIS_y
  aclk pll_0/clk_out1
  aresetn slice_trx_reset/dout
  }

# Create axis_data_fifo
cell xilinx.com:ip:axis_data_fifo:1.1 fifo_xyf {
  FIFO_DEPTH 16384
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 12
} {
  s_axis  comb_xyf/m_axis
  s_axis_aclk pll_0/clk_out1
  s_axis_aresetn slice_trx_reset/dout
}

# Create axis_dwidth_converter
cell xilinx.com:ip:axis_dwidth_converter:1.1 conv_xyf {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 12
  M_TDATA_NUM_BYTES 4
} {
  S_AXIS fifo_xyf/M_AXIS
  aclk pll_0/clk_out1
  aresetn slice_trx_reset/dout
}

# Create axi_axis_reader
cell pavel-demin:user:axi_axis_reader:1.0 reader_xyf {
  AXI_DATA_WIDTH 32
} {
  S_AXIS conv_xyf/M_AXIS
  aclk pll_0/clk_out1
  aresetn slice_trx_reset/dout
}

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Master /ps_0/M_AXI_GP0
  Clk Auto
} [get_bd_intf_pins reader_xyf/S_AXI]

set_property RANGE 16K [get_bd_addr_segs ps_0/Data/SEG_reader_xyf_reg0]
set_property OFFSET 0x40010000 [get_bd_addr_segs ps_0/Data/SEG_reader_xyf_reg0]

# Create xlconstant
cell xilinx.com:ip:xlconstant:1.1 const_lockin_sweep_ID {
  CONST_WIDTH 16
  CONST_VAL 103
}

# Create xlconcat
cell xilinx.com:ip:xlconcat:2.1 concat_status {
  NUM_PORTS 7
  IN0_WIDTH 32
  IN1_WIDTH 32
  IN2_WIDTH 16
  IN3_WIDTH 16
  IN4_WIDTH 96
  IN5_WIDTH 32
  IN6_WIDTH 32
} {
  IN3 const_lockin_sweep_ID/dout
  In5 fifo_xyf/axis_data_count
  In6 fifo_f/axis_data_count
}

# Create axi_sts_register
cell pavel-demin:user:axi_sts_register:1.0 sts_0 {
  STS_DATA_WIDTH 256
  AXI_ADDR_WIDTH 32
  AXI_DATA_WIDTH 32
} {
  sts_data concat_status/dout
}


# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Master /ps_0/M_AXI_GP0
  Clk Auto
} [get_bd_intf_pins sts_0/S_AXI]


set_property RANGE 4K [get_bd_addr_segs ps_0/Data/SEG_sts_0_reg0]
set_property OFFSET 0x40001000 [get_bd_addr_segs ps_0/Data/SEG_sts_0_reg0]
