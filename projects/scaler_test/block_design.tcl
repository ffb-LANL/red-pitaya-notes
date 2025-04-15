#scaler test

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
  CFG_DATA_WIDTH 544
  STS_DATA_WIDTH 320
} {
  S_AXI ps_0/M_AXI_GP0
  S01_AXIS hub_0/M01_AXIS
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create xlslice
cell pavel-demin:user:port_slicer scale_factor_0 {
  DIN_WIDTH 544 DIN_FROM 511 DIN_TO 480
} {
  Din hub_0/cfg_data
}

# Create axis_scaler
cell pavel-demin:user:axis_scaler scaler_0 {
  AXIS_TDATA_WIDTH 14
} {
  S_AXIS hub_0/M00_AXIS
  M_AXIS hub_0/S00_AXIS
  cfg_data scale_factor_0/Dout
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}


