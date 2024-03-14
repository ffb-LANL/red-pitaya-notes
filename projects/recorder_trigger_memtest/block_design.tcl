# Create clk_wiz
cell xilinx.com:ip:clk_wiz pll_0 {
  PRIMITIVE PLL
  PRIM_IN_FREQ.VALUE_SRC USER
  PRIM_IN_FREQ 125.0
  PRIM_SOURCE Differential_clock_capable_pin
  CLKOUT1_USED true
  CLKOUT1_REQUESTED_OUT_FREQ 125.0
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
cell xilinx.com:ip:xlconstant const_0

# Create proc_sys_reset
cell xilinx.com:ip:proc_sys_reset rst_0 {} {
  ext_reset_in const_0/dout
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
  CFG_DATA_WIDTH 192
  STS_DATA_WIDTH 64
} {
  S_AXI ps_0/M_AXI_GP0
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create port_slicer
cell pavel-demin:user:port_slicer slice_0 {
  DIN_WIDTH 192 DIN_FROM 0 DIN_TO 0
} {
  din hub_0/cfg_data
}

# Create port_slicer
cell pavel-demin:user:port_slicer slice_1 {
  DIN_WIDTH 192 DIN_FROM 1 DIN_TO 1
} {
  din hub_0/cfg_data
}

# Create port_slicer
cell pavel-demin:user:port_slicer slice_2 {
  DIN_WIDTH 192 DIN_FROM 16 DIN_TO 16
} {
  din hub_0/cfg_data
}

# Create port_slicer
cell pavel-demin:user:port_slicer slice_3 {
  DIN_WIDTH 192 DIN_FROM 63 DIN_TO 32
} {
  din hub_0/cfg_data
}

# Create port_slicer
cell pavel-demin:user:port_slicer slice_4 {
  DIN_WIDTH 192 DIN_FROM 79 DIN_TO 64
} {
  din hub_0/cfg_data
}

# Create port_slicer
cell pavel-demin:user:port_slicer slice_5 {
  DIN_WIDTH 192 DIN_FROM 95 DIN_TO 80
} {
  din hub_0/cfg_data
}

# Create port_slicer
cell pavel-demin:user:port_slicer slice_6 {
  DIN_WIDTH 192 DIN_FROM 127 DIN_TO 96
} {
  din hub_0/cfg_data
}

# Create port_slicer
cell pavel-demin:user:port_slicer slice_7 {
  DIN_WIDTH 192 DIN_FROM 159 DIN_TO 128
} {
  din hub_0/cfg_data
}

# Create port_slicer
cell pavel-demin:user:port_slicer slice_8 {
  DIN_WIDTH 192 DIN_FROM 175 DIN_TO 160
} {
  din hub_0/cfg_data
}

# Create axis_variable
cell pavel-demin:user:axis_variable rate_0 {
  AXIS_TDATA_WIDTH 16
} {
  cfg_data slice_8/dout
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create axis_variable
cell pavel-demin:user:axis_variable rate_1 {
  AXIS_TDATA_WIDTH 16
} {
  cfg_data slice_8/dout
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}


# Create axis_trigger
cell pavel-demin:user:axis_trigger trig_0 {
  AXIS_TDATA_WIDTH 8
  AXIS_TDATA_SIGNED FALSE
} {
  S_AXIS gpio_0/M_AXIS
  pol_data slice_2/dout
  msk_data slice_4/dout
  lvl_data slice_5/dout
  aclk pll_0/clk_out1
}

# Create axis_inf_counter
cell pavel-demin:user:axis_inf_counter inf_cntr_1 {
  AXIS_TDATA_WIDTH 32
} {
  run_flag slice_1/dout
  trg_flag trig_0/trg_flag
  aclk pll_0/clk_out1
  aresetn slice_0/dout
}


# Create axis_packetizer
cell pavel-demin:user:axis_oscilloscope scope_0 {
  AXIS_TDATA_WIDTH 32
  CNTR_WIDTH 23
} {
  S_AXIS inf_cntr_1/M_AXIS
  run_flag slice_1/dout
  trg_flag trig_0/trg_flag
  pre_data slice_6/dout
  tot_data slice_7/dout
  aclk pll_0/clk_out1
  aresetn slice_0/dout
}

# Create xlconstant
cell xilinx.com:ip:xlconstant const_1 {
  CONST_WIDTH 18
  CONST_VAL 262143
}

# Create axis_ram_writer
cell pavel-demin:user:axis_ram_writer writer_0 {
  ADDR_WIDTH 18
  AXI_ID_WIDTH 3
  AXIS_TDATA_WIDTH 32
  FIFO_WRITE_DEPTH 1024
} {
  S_AXIS scope_0/M_AXIS
  M_AXI ps_0/S_AXI_ACP
  min_addr slice_3/dout
  cfg_data const_1/dout
  aclk pll_0/clk_out1
  aresetn slice_0/dout
}

# Create xlconcat
cell xilinx.com:ip:xlconcat concat_0 {
  NUM_PORTS 2
  IN0_WIDTH 32
  IN1_WIDTH 32
} {
  In0 scope_0/sts_data
  In1 writer_0/sts_data
  dout hub_0/sts_data
}
