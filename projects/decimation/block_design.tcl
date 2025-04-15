#decimation test 103

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
cell xilinx.com:ip:xlconstant const_0

# Create proc_sys_reset
cell xilinx.com:ip:proc_sys_reset rst_0 {} {
  ext_reset_in const_0/dout
  dcm_locked pll_0/locked
  slowest_sync_clk pll_0/clk_out1
}

# Create axis_red_pitaya_adc
cell pavel-demin:user:axis_red_pitaya_adc adc_0 {} {
  aclk pll_0/clk_out1
  adc_dat_a adc_dat_a_i
  adc_dat_b adc_dat_b_i
  adc_csn adc_csn_o
}

# Create c_counter_binary
cell xilinx.com:ip:c_counter_binary cntr_0 {
  Output_Width 32
} {
  CLK pll_0/clk_out1
}

# Create xlslice
cell xilinx.com:ip:xlslice slice_0 {
  DIN_WIDTH 32 DIN_FROM 25 DIN_TO 25 DOUT_WIDTH 1
} {
  Din cntr_0/Q
 }


# Create axi_hub
cell pavel-demin:user:axi_hub hub_0 {
  CFG_DATA_WIDTH 512
  STS_DATA_WIDTH 512
} {
  S_AXI ps_0/M_AXI_GP0
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}


# Create xlslice
cell xilinx.com:ip:xlslice slice_1 {
  DIN_WIDTH 256 DIN_FROM 129 DIN_TO 128 
} {
  Din hub_0/cfg_data
}

# Create xlslice
cell xilinx.com:ip:xlslice slice_trx_reset {
  DIN_WIDTH 256 DIN_FROM 4 DIN_TO 4
} {
  Din hub_0/cfg_data
}


# Create xlconcat
cell xilinx.com:ip:xlconcat concat_0 {
  IN1_WIDTH 2
} {
  In0 slice_0/Dout
  In1 slice_1/Dout
  dout led_o
}

# Create xlconstant
cell xilinx.com:ip:xlconstant const_1


# Create axis_dwidth_converter
cell xilinx.com:ip:axis_dwidth_converter:1.1 conv_f {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 4
  M_TDATA_NUM_BYTES 8
} {
  S_AXIS hub_0/M00_AXIS
  aclk /pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}


# Create xlslice
cell xilinx.com:ip:xlslice slice_decimate {
  DIN_WIDTH 256 DIN_FROM 127 DIN_TO 96
} {
  Din hub_0/cfg_data
}

# Create xlconcat
cell xilinx.com:ip:xlconcat concat_interpol {
 IN0_WIDTH 13
 IN1_WIDTH 19
} {

  In1 slice_decimate/Dout

}




# Create port_slicer
cell pavel-demin:user:port_slicer writer_reset_slice {
  DIN_WIDTH 496 DIN_FROM 0 DIN_TO 0
} {
  din hub_0/cfg_data
}

# Create port_slicer
cell pavel-demin:user:port_slicer run_slice {
  DIN_WIDTH 496 DIN_FROM 1 DIN_TO 1
} {
  din hub_0/cfg_data
}

# Create xlslice
cell pavel-demin:user:port_slicer slice_trig_record {
  DIN_WIDTH 496 DIN_FROM 3 DIN_TO 3
} {
   din hub_0/cfg_data
}

# Create port_slicer
cell pavel-demin:user:port_slicer pre_data_slice {
  DIN_WIDTH 496 DIN_FROM 447 DIN_TO 416
} {
  din hub_0/cfg_data
}


# Create port_slicer
cell pavel-demin:user:port_slicer tot_data_slice {
  DIN_WIDTH 496 DIN_FROM 63 DIN_TO 32
} {
  din hub_0/cfg_data
}

# Create axis_broadcaster
cell xilinx.com:ip:axis_broadcaster bcast_two {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  M_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 8
  M_TDATA_NUM_BYTES 4
  M00_TDATA_REMAP {tdata[31:0]}
  M01_TDATA_REMAP {tdata[63:32]}
} {
  s_axis conv_f/M_AXIS
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

# Create axis_fifo
cell xilinx.com:ip:axis_data_fifo fifo_fx {
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 4
  HAS_WR_DATA_COUNT 1
  FIFO_DEPTH 16384
} {
  S_AXIS bcast_two/M00_AXIS
  s_axis_aclk /pll_0/clk_out1
  s_axis_aresetn rst_0/peripheral_aresetn
}



# Create axis_fifo
cell xilinx.com:ip:axis_data_fifo fifo_fy {
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 4
  HAS_WR_DATA_COUNT 1
  FIFO_DEPTH 16384
} {
  S_AXIS bcast_two/M01_AXIS
  s_axis_aclk /pll_0/clk_out1
  s_axis_aresetn rst_0/peripheral_aresetn
}


# Create axis_fifo
cell xilinx.com:ip:axis_data_fifo fifo_x {
  FIFO_DEPTH 8192
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 4
  HAS_WR_DATA_COUNT 1
} {
  S_AXIS fifo_fx/M_AXIS
  s_axis_aclk pll_0/clk_out1
  s_axis_aresetn rst_0/peripheral_aresetn
  M_AXIS hub_0/S02_AXIS
}

# Create axis_fifo
cell xilinx.com:ip:axis_data_fifo fifo_y {
  FIFO_DEPTH 8192
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 4
  HAS_WR_DATA_COUNT 1
} {
  S_AXIS fifo_fy/M_AXIS
  s_axis_aclk pll_0/clk_out1
  s_axis_aresetn rst_0/peripheral_aresetn
  M_AXIS hub_0/S01_AXIS
}


# Create xlconstant
cell xilinx.com:ip:xlconstant const_lockin_sweep_ID {
  CONST_WIDTH 16
  CONST_VAL 103
}

# Create xlconcat
cell xilinx.com:ip:xlconcat concat_status {
  NUM_PORTS 12
  IN0_WIDTH 32
  IN1_WIDTH 32
  IN2_WIDTH 1
  IN3_WIDTH 1
  IN4_WIDTH 14 
  IN5_WIDTH 16
  IN6_WIDTH 96
  IN7_WIDTH 32
  IN8_WIDTH 32
  IN9_WIDTH 32
  IN10_WIDTH 32
  IN11_WIDTH 32
  IN12_WIDTH 32
} {
  IN5 const_lockin_sweep_ID/dout
  In7 fifo_x/axis_wr_data_count
  In8 fifo_fx/axis_wr_data_count
  In9 fifo_y/axis_wr_data_count
  IN10 fifo_fy/axis_wr_data_count
  In11 concat_interpol/Dout
  dout hub_0/sts_data
}


