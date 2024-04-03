# Create clk_buf
cell xilinx.com:ip:util_ds_buf i_clk_01 {
  CONFIG.FREQ_HZ 125000000
} {
  ibuf_ds_p  adc_clk_p_i
  ibuf_ds_n  adc_clk_n_i
}


# Create clk_wiz
cell xilinx.com:ip:clk_wiz pll_0 {
  PRIMITIVE PLL
  PRIM_IN_FREQ.VALUE_SRC USER
  PRIM_IN_FREQ 125.0
  PRIM_SOURCE Global_buffer
  CLKOUT1_USED true
  CLKOUT1_REQUESTED_OUT_FREQ 125.0
  CLKOUT2_USED true
  CLKOUT2_REQUESTED_OUT_FREQ 200.0
  USE_RESET false
} {
     clk_in1 i_clk_01/IBUF_OUT
}

# Create clk_buf
cell xilinx.com:ip:util_ds_buf i_clk_23 {} {
  ibuf_ds_p  adc_clk_p_i2
  ibuf_ds_n  adc_clk_n_i2
}


cell xilinx.com:ip:clk_wiz pll_1 {
  PRIMITIVE PLL
  PRIM_IN_FREQ.VALUE_SRC USER
  PRIM_IN_FREQ 125.0
  PRIM_SOURCE Global_buffer
  CLKOUT1_USED true
  CLKOUT1_REQUESTED_OUT_FREQ 125.0
  USE_RESET false
} {
     clk_in1 i_clk_23/IBUF_OUT
}

# Create processing_system7
cell xilinx.com:ip:processing_system7 ps_0 {
  PCW_IMPORT_BOARD_PRESET cfg/red_pitaya.xml
} {
  M_AXI_GP0_ACLK pll_0/clk_out1
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



# Create axis_red_pitaya_adc_4ch
cell pavel-demin:user:axis_red_pitaya_adc_4ch adc_0 {
} {
  aclk pll_0/clk_out1
  adc_clk_23 pll_1/clk_out1
  adc_buf_clk01    i_clk_01/IBUF_OUT
  adc_buf_clk23    i_clk_23/IBUF_OUT
  idelay_ctrl_clk pll_0/clk_out2
  adc_dat_i adc_dat_i
  aresetn rst_0/peripheral_aresetn
}

# Create axis_fifo
cell pavel-demin:user:axis_fifo fifo_0 {
  S_AXIS_TDATA_WIDTH 64
  M_AXIS_TDATA_WIDTH 32
  WRITE_DEPTH 16384
} {
  S_AXIS adc_0/M_AXIS
  M_AXIS hub_0/S00_AXIS
  aclk pll_0/clk_out1
  aresetn slice_0/dout
}

# Create xlconcat
cell xilinx.com:ip:xlconcat concat_0 {
  NUM_PORTS 2
  IN0_WIDTH 32
  IN1_WIDTH 32
} {
  In0 fifo_0/read_count
  In1 fifo_0/write_count
  dout hub_0/sts_data
}
