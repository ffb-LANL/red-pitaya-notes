#lockin digitizer 159

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
cell xilinx.com:ip:xlconstant ext_rst_const

# Create proc_sys_reset
cell xilinx.com:ip:proc_sys_reset rst_0 {} {
  ext_reset_in ext_rst_const/dout
  dcm_locked pll_0/locked
  slowest_sync_clk pll_0/clk_out1
}

# Create axis_gpio_reader
cell pavel-demin:user:axis_gpio_reader_writer gpio_0 {
  AXIS_TDATA_WIDTH 8
  GPIO_IN_DATA_WIDTH 1
  GPIO_OUT_DATA_WIDTH 1
} {
  gpio_data_in exp_p_tri_io
  gpio_data_out exp_n_tri_io
  aclk pll_0/clk_out1
}

# Create axi_hub
cell pavel-demin:user:axi_hub hub_0 {
  CFG_DATA_WIDTH 512
  STS_DATA_WIDTH 320
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

# Create axis_broadcaster
cell xilinx.com:ip:axis_broadcaster bcast_ADC {
  NUM_MI 3
  S_TDATA_NUM_BYTES 4
  M_TDATA_NUM_BYTES 4
  M00_TDATA_REMAP 16'b0,tdata[15:0]
  M01_TDATA_REMAP 16'b0,tdata[31:16]
  M02_TDATA_REMAP tdata[31:0]
 } {
  S_AXIS  adc_0/M_AXIS
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}


# Create xlslice
cell pavel-demin:user:port_slicer slice_frequency_0 {
  DIN_WIDTH 496 DIN_FROM 95 DIN_TO 64
} {
  Din hub_0/cfg_data
}

# Create xlslice
cell pavel-demin:user:port_slicer slice_frequency_1 {
  DIN_WIDTH 496 DIN_FROM 479 DIN_TO 448
} {
  Din hub_0/cfg_data
}


# Create axis_constant
cell pavel-demin:user:axis_constant phase_0 {
  AXIS_TDATA_WIDTH 32
} {
  cfg_data slice_frequency_0/Dout
  aclk pll_0/clk_out1
}

# Create axis_constant
cell pavel-demin:user:axis_constant phase_1 {
  AXIS_TDATA_WIDTH 32
} {
  cfg_data slice_frequency_1/Dout
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
  Has_Phase_Out true
} {
  S_AXIS_PHASE phase_0/M_AXIS
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create dds_compiler
cell xilinx.com:ip:dds_compiler dds_1 {
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
  Has_Phase_Out true
} {
  S_AXIS_PHASE phase_1/M_AXIS
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}


# Create axis_broadcaster
cell xilinx.com:ip:axis_broadcaster bcast_DDS {
  NUM_MI 3
  S_TDATA_NUM_BYTES 4
  M_TDATA_NUM_BYTES 4
  M00_TDATA_REMAP tdata[31:0]
  M01_TDATA_REMAP tdata[31:0]
  M02_TDATA_REMAP 16'b0,tdata[15:0]
 } {
  S_AXIS  dds_0/M_AXIS_DATA
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# create delay
#cell pavel-demin:user:axis_fixed_delay delay_dds_0 { 
# DEPTH 14
#} {
#  s_axis bcast_DDS/M00_AXIS
#  aclk pll_0/clk_out1
#}

# create delay
#cell pavel-demin:user:axis_fixed_delay delay_dds_1 { 
# DEPTH 14
#} {
#  s_axis bcast_DDS/M01_AXIS
#  aclk pll_0/clk_out1
#}

# Create axis_lfsr
cell pavel-demin:user:axis_lfsr lfsr_0 {} {
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}


# Create axis_lfsr
cell pavel-demin:user:axis_lfsr lfsr_1 {} {
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create xlslice
cell pavel-demin:user:port_slicer scale_factor_0 {
  DIN_WIDTH 496 DIN_FROM 143 DIN_TO 128
} {
  Din hub_0/cfg_data
}

# Create xlslice
cell pavel-demin:user:port_slicer scale_factor_1 {
  DIN_WIDTH 496 DIN_FROM 495 DIN_TO 480
} {
  Din hub_0/cfg_data
}

# Create axis_scaler
cell pavel-demin:user:axis_scaler scaler_0 {
  AXIS_TDATA_WIDTH 14
} {
  S_AXIS bcast_DDS/M02_AXIS
  cfg_data scale_factor_0/Dout
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create axis_scaler
cell pavel-demin:user:axis_scaler scaler_1 {
  AXIS_TDATA_WIDTH 14
} {
  S_AXIS dds_1/M_AXIS_DATA
  cfg_data scale_factor_1/Dout
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}



# Create axis_combiner
cell  xilinx.com:ip:axis_combiner comb_0 {
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 2
} {
  S00_AXIS scaler_0/M_AXIS
  S01_AXIS scaler_1/M_AXIS
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
  S_AXIS comb_0/M_AXIS
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


cell xilinx.com:ip:xlconstant trig_polarity_slice {
  CONST_WIDTH 1
  CONST_VAL 0
}


# Create xlconstant
cell xilinx.com:ip:xlconstant trig_mask_slice {
  CONST_WIDTH 16
  CONST_VAL 1
}


cell xilinx.com:ip:xlconstant trig_level_slice {
  CONST_WIDTH 16
  CONST_VAL 1
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


# Create axis_trigger
cell pavel-demin:user:axis_soft_trigger trig_0 {
  AXIS_TDATA_WIDTH 8
  AXIS_TDATA_SIGNED FALSE
} {
  S_AXIS gpio_0/M_AXIS
  trg_flag gpio_0/data
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
  S_AXIS   bcast_ADC/M02_AXIS
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

# Create xlconstant
cell xilinx.com:ip:xlconstant writer_address_start {
  CONST_WIDTH 32
  CONST_VAL 268435456
}

# Create axis_ram_writer
cell pavel-demin:user:axis_ram_writer writer_0 {
  ADDR_WIDTH 21
  AXI_ID_WIDTH 3
  AXIS_TDATA_WIDTH 32
  FIFO_WRITE_DEPTH 1024
} {
  S_AXIS scope_0/M_AXIS
  M_AXI ps_0/S_AXI_HP0
  min_addr writer_address_start/dout
  cfg_data const_ram_size/dout
  aclk pll_0/clk_out1
  aresetn writer_reset_slice/dout
}

# Create axis_snapshot
cell pavel-demin:user:axis_snapshot phase_snap_0 {
  AXIS_TDATA_WIDTH 32
} {
  S_AXIS dds_0/M_AXIS_PHASE
  aclk pll_0/clk_out1
  trig_flag trig_0/trg_flag
  aresetn writer_reset_slice/dout
}

# Create axis_snapshot
cell pavel-demin:user:axis_snapshot phase_snap_1 {
  AXIS_TDATA_WIDTH 32
} {
  S_AXIS dds_1/M_AXIS_PHASE
  aclk pll_0/clk_out1
  trig_flag trig_0/trg_flag
  aresetn writer_reset_slice/dout
}

# Create cmpy
cell xilinx.com:ip:cmpy mult_0 {
  FLOWCONTROL Blocking
  APORTWIDTH.VALUE_SRC USER
  BPORTWIDTH.VALUE_SRC USER
  APORTWIDTH 14
  BPORTWIDTH 14
  ROUNDMODE Random_Rounding
  OUTPUTWIDTH 28
} {
  S_AXIS_A bcast_ADC/M00_AXIS
  s_axis_b bcast_DDS/M00_AXIS
  S_AXIS_CTRL lfsr_0/M_AXIS
  aclk pll_0/clk_out1
}


# Create cmpy
cell xilinx.com:ip:cmpy mult_1 {
  FLOWCONTROL Blocking
  APORTWIDTH.VALUE_SRC USER
  BPORTWIDTH.VALUE_SRC USER
  APORTWIDTH 14
  BPORTWIDTH 14
  ROUNDMODE Random_Rounding
  OUTPUTWIDTH 28
} {
  S_AXIS_A bcast_ADC/M01_AXIS
  s_axis_b bcast_DDS/M01_AXIS
  S_AXIS_CTRL lfsr_1/M_AXIS
  aclk pll_0/clk_out1
}

# create filter
module filter_xy_0 {
  source projects/low_pass/filter_xy.tcl
} {
  s_axis mult_0/M_AXIS_DOUT
  cfg hub_0/cfg_data
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# create filter
module filter_xy_1 {
  source projects/low_pass/filter_xy_reversed.tcl
} {
  s_axis mult_1/M_AXIS_DOUT
  cfg hub_0/cfg_data
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}


# Create axis_combiner
cell  xilinx.com:ip:axis_combiner comb_xy {
  NUM_SI 4
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 4
} {
  S00_AXIS filter_xy_0/M_AXIS_x
  S01_AXIS filter_xy_0/M_AXIS_y
  S02_AXIS filter_xy_1/M_AXIS_x
  S03_AXIS filter_xy_1/M_AXIS_y
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
  }

#create value
cell pavel-demin:user:axis_value value_xy {
AXIS_TDATA_WIDTH 128
} {
  s_axis comb_xy/M_AXIS
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create xlconstant
cell xilinx.com:ip:xlconstant const_ID {
  CONST_WIDTH 16
  CONST_VAL 159
}

# Create xlconcat
cell xilinx.com:ip:xlconcat concat_sts {
  NUM_PORTS 10
  IN0_WIDTH 32
  IN1_WIDTH 32
  IN2_WIDTH 1
  IN3_WIDTH 1
  IN4_WIDTH 14 
  IN5_WIDTH 16
  IN6_WIDTH 32
  IN7_WIDTH 128
  IN8_WITDH 32
  IN9_WITDH 32
} {
  In0 writer_0/sts_data	
  In1 scope_0/sts_data
  In2 scope_0/triggered
  In3 scope_0/complete
  In5 const_ID/dout
  In6 phase_snap_0/data
  In7 value_xy/data
  In8 const_modulus/dout
  In9 phase_snap_1/data
  dout hub_0/sts_data
}

