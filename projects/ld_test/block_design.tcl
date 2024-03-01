#CMA lockin digitizer test 159

# Create clk_wiz
cell xilinx.com:ip:clk_wiz pll_0 {
  PRIMITIVE PLL
  PRIM_IN_FREQ.VALUE_SRC USER
  PRIM_IN_FREQ 125.0
  PRIM_SOURCE Differential_clock_capable_pin
  CLKOUT1_USED true
  CLKOUT1_REQUESTED_OUT_FREQ 125.0
  CLKOUT2_USED true
  CLKOUT2_REQUESTED_OUT_FREQ 250.0
  CLKOUT2_REQUESTED_PHASE 157.5
  CLKOUT3_USED true
  CLKOUT3_REQUESTED_OUT_FREQ 250.0
  CLKOUT3_REQUESTED_PHASE 202.5
  USE_RESET false
} {
  clk_in1_p adc_clk_p_i
  clk_in1_n adc_clk_n_i
}

# Create processing_system7
cell xilinx.com:ip:processing_system7 ps_0 {
  PCW_IMPORT_BOARD_PRESET cfg/red_pitaya.xml
  PCW_USE_S_AXI_ACP 1
  PCW_USE_DEFAULT_ACP_USER_VAL 1
} {
  M_AXI_GP0_ACLK pll_0/clk_out1
  S_AXI_ACP_ACLK pll_0/clk_out1
}

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {
  make_external {FIXED_IO, DDR}
  Master Disable
  Slave Disable
} [get_bd_cells ps_0]

# Create xlconstant
cell xilinx.com:ip:xlconstant ext_rst_const

# Create proc_sys_reset
cell xilinx.com:ip:proc_sys_reset rst_0 {} {
  ext_reset_in ext_rst_const/dout
  dcm_locked pll_0/locked
  slowest_sync_clk pll_0/clk_out1
}

# Create axis_gpio_reader
cell pavel-demin:user:axis_gpio_reader gpio_0 {
  AXIS_TDATA_WIDTH 8
} {
  gpio_data exp_p_tri_io
  aclk pll_0/clk_out1
}

# Create axi_hub
cell pavel-demin:user:axi_hub hub_0 {
  CFG_DATA_WIDTH 416
  STS_DATA_WIDTH 288
} {
  S_AXI ps_0/M_AXI_GP0
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# ADC

# Create axis_red_pitaya_adc
cell pavel-demin:user:axis_red_pitaya_adc adc_0 {
  ADC_DATA_WIDTH 14
} {
  aclk pll_0/clk_out1
  adc_dat_a adc_dat_a_i
  adc_dat_b adc_dat_b_i
  adc_csn adc_csn_o
}

# Create xlslice
cell pavel-demin:user:port_slicer slice_frequency {
  DIN_WIDTH 416 DIN_FROM 95 DIN_TO 64
} {
  Din hub_0/cfg_data
}

# Create axis_constant
cell pavel-demin:user:axis_constant phase_0 {
  AXIS_TDATA_WIDTH 32
} {
  cfg_data slice_frequency/Dout
  aclk pll_0/clk_out1
}

# Create xlconstant
cell xilinx.com:ip:xlconstant const_modulus {
  CONST_WIDTH 32
  CONST_VAL 15120
}

# Create dds_compiler
cell xilinx.com:ip:dds_compiler dds_0 {
  MODE_OF_OPERATION Rasterized
  MODULUS 15120
  DDS_CLOCK_RATE 125
  parameter_entry Hardware_Parameters
  OUTPUT_WIDTH 14
  PHASE_WIDTH 14
  PHASE_INCREMENT Streaming
  DSP48_USE Maximal
  HAS_TREADY true
  Has_ARESETn true
  Has_Phase_Out false
} {
  S_AXIS_PHASE phase_0/M_AXIS
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# DAC

# Create axis_red_pitaya_dac
cell pavel-demin:user:axis_red_pitaya_dac dac_0 {
  DAC_DATA_WIDTH 14
} {
  aclk pll_0/clk_out1
  ddr_clk pll_0/clk_out2
  wrt_clk pll_0/clk_out3
  locked pll_0/locked
  dac_clk dac_clk_o
  dac_rst dac_rst_o
  dac_sel dac_sel_o
  dac_wrt dac_wrt_o
  dac_dat dac_dat_o
  s_axis dds_0/M_AXIS_DATA
}




# Create port_slicer
cell pavel-demin:user:port_slicer writer_reset_slice {
  DIN_WIDTH 416 DIN_FROM 0 DIN_TO 0
} {
  din hub_0/cfg_data
}

# Create port_slicer
cell pavel-demin:user:port_slicer run_slice {
  DIN_WIDTH 416 DIN_FROM 1 DIN_TO 1
} {
  din hub_0/cfg_data
}

# Create xlslice
cell pavel-demin:user:port_slicer slice_trig_record {
  DIN_WIDTH 416 DIN_FROM 3 DIN_TO 3
} {
   din hub_0/cfg_data
}

# Create port_slicer
#cell pavel-demin:user:port_slicer trig_polarity_slice {
#  DIN_WIDTH 416 DIN_FROM 16 DIN_TO 16
#} {
#  din hub_0/cfg_data
#}

cell xilinx.com:ip:xlconstant trig_polarity_slice {
  CONST_WIDTH 1
  CONST_VAL 1
}

# Create port_slicer
cell pavel-demin:user:port_slicer writer_address_slice {
  DIN_WIDTH 416 DIN_FROM 415 DIN_TO 384
} {
  din hub_0/cfg_data
}

# Create port_slicer
#cell pavel-demin:user:port_slicer trig_mask_slice {
#  DIN_WIDTH 416 DIN_FROM 383 DIN_TO 368
#} {
#  din hub_0/cfg_data
#}

# Create xlconstant
cell xilinx.com:ip:xlconstant trig_mask_slice {
  CONST_WIDTH 16
  CONST_VAL 1
}

# Create port_slicer
#cell pavel-demin:user:port_slicer trig_level_slice {
#  DIN_WIDTH 416 DIN_FROM 367 DIN_TO 352
#} {
#  din hub_0/cfg_data
#}

cell xilinx.com:ip:xlconstant trig_level_slice {
  CONST_WIDTH 16
  CONST_VAL 1
}

# Create port_slicer
#cell pavel-demin:user:port_slicer pre_data_slice {
#  DIN_WIDTH 416 DIN_FROM 127 DIN_TO 96
#} {
#  din hub_0/cfg_data
#}

# Create xlconstant
cell xilinx.com:ip:xlconstant pre_data_slice {
  CONST_WIDTH 32
  CONST_VAL 512
}

# Create port_slicer
cell pavel-demin:user:port_slicer tot_data_slice {
  DIN_WIDTH 416 DIN_FROM 63 DIN_TO 32
} {
  din hub_0/cfg_data
}


# Create axis_trigger
cell pavel-demin:user:axis_soft_trigger trig_0 {
  AXIS_TDATA_WIDTH 8
  AXIS_TDATA_SIGNED FALSE
} {
  S_AXIS gpio_0/M_AXIS
  pol_data trig_polarity_slice/dout
  msk_data trig_mask_slice/dout
  lvl_data trig_level_slice/dout
  soft_trigger slice_trig_record/dout
  aclk pll_0/clk_out1
}

# Create axis_oscilloscope
cell pavel-demin:user:axis_oscilloscope scope_0 {
  AXIS_TDATA_WIDTH 32
  CNTR_WIDTH 26
} {
  S_AXIS adc_0/M_AXIS
  run_flag run_slice/dout
  trg_flag trig_0/trg_flag
  pre_data pre_data_slice/dout
  tot_data tot_data_slice/dout
  aclk pll_0/clk_out1
  aresetn writer_reset_slice/dout
}

# Create xlconstant
cell xilinx.com:ip:xlconstant const_ram_size {
  CONST_WIDTH 21
  CONST_VAL 2097151
}

# Create axis_ram_writer
cell pavel-demin:user:axis_ram_writer writer_0 {
  ADDR_WIDTH 21
  AXI_ID_WIDTH 3
  AXIS_TDATA_WIDTH 32
  FIFO_WRITE_DEPTH 1024
} {
  S_AXIS scope_0/M_AXIS
  M_AXI ps_0/S_AXI_ACP
  min_addr writer_address_slice/dout
  cfg_data const_ram_size/dout
  aclk pll_0/clk_out1
  aresetn writer_reset_slice/dout
}


# Create xlconstant
cell xilinx.com:ip:xlconstant const_ID {
  CONST_WIDTH 16
  CONST_VAL 159
}

# Create xlconcat
cell xilinx.com:ip:xlconcat concat_sts {
  NUM_PORTS 7
  IN0_WIDTH 32
  IN1_WIDTH 32
  IN2_WIDTH 16
  IN3_WIDTH 16
  IN4_WIDTH 32
  IN5_WIDTH 128
  IN6_WITDH 32
} {
  In0 writer_0/sts_data	
  In1 scope_0/sts_data
  In2 trig_0/trg_flag
  In3 const_ID/dout
  In6 const_modulus/dout
  dout hub_0/sts_data
}

assign_bd_address [get_bd_addr_segs ps_0/S_AXI_ACP/ACP_DDR_LOWOCM]
