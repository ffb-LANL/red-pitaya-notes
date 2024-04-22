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
  CFG_DATA_WIDTH 192
  STS_DATA_WIDTH 96
} {
  S_AXI ps_0/M_AXI_GP0
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create port_slicer
cell pavel-demin:user:port_slicer slice_start {
  DIN_WIDTH 192 DIN_FROM 0 DIN_TO 0
} {
  din hub_0/cfg_data
}


# Create c_counter_binary
cell xilinx.com:ip:c_counter_binary cntr_ps {
  Output_Width 64
} {
  CLK ps_0/fclk_clk0
}

# Create c_counter_binary
cell xilinx.com:ip:c_counter_binary cntr_adc {
  Output_Width 64
} {
  CLK pll_0/clk_out1
}


# Create port_slicer
cell pavel-demin:user:port_slicer slice_0 {
  DIN_WIDTH 32 DIN_FROM 26 DIN_TO 26
} {
  din cntr_ps/Q
}


# Create port_slicer
cell pavel-demin:user:port_slicer slice_1 {
  DIN_WIDTH 32 DIN_FROM 26 DIN_TO 26
} {
  din cntr_adc/Q
}

# Create xlconcat
cell xilinx.com:ip:xlconcat concat_1 {
  NUM_PORTS 2
  IN0_WIDTH 1
  IN1_WIDTH 1
} {
  In0 slice_0/dout
  In1 slice_1/dout
  dout led_o
 }

# Create axis_data_fifo
cell xilinx.com:ip:axis_data_fifo fifo_0 {
  TDATA_NUM_BYTES.VALUE_SRC USER
  FIFO_DEPTH 32768
  TDATA_NUM_BYTES 8
} {
  S_AXIS_tdata cntr_adc/Q
  S_AXIS_tvalid const_0/dout
  s_axis_aclk pll_0/clk_out1
  s_axis_aresetn slice_start/dout
}

# Create xis_dwidth_converter
cell xilinx.com:ip:axis_dwidth_converter axis_dwidth_converter_0 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  M_TDATA_NUM_BYTES 4
  S_TDATA_NUM_BYTES 8
} {
  S_AXIS fifo_0/M_AXIS
  M_AXIS hub_0/S00_AXIS 
  aclk pll_0/clk_out1
  aresetn slice_start/dout
}

# Create xlconcat
cell xilinx.com:ip:xlconcat concat_0 {
  NUM_PORTS 6
  IN0_WIDTH 32
  IN1_WIDTH 32
  IN2_WIDTH 1
  IN3_WIDTH 1
  IN4_WIDTH 3
  IN5_WIDTH 1
} {
  dout hub_0/sts_data
 }
