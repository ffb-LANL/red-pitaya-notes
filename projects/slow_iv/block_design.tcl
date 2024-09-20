#slow current-voltage cir. 2024  155

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


# Create axis_red_pitaya_adc
cell pavel-demin:user:axis_red_pitaya_adc adc_0 {
  ADC_DATA_WIDTH 14
} {
  aclk pll_0/clk_out1
  adc_dat_a adc_dat_a_i
  adc_dat_b adc_dat_b_i
  adc_csn adc_csn_o
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
cell xilinx.com:ip:xlslice slice_trig_record {
  DIN_WIDTH 352 DIN_FROM 3 DIN_TO 3
} {
  Din hub_0/cfg_data
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


# Create xlslice
cell xilinx.com:ip:xlslice slice_delay {
  DIN_WIDTH 352 DIN_FROM 351 DIN_TO 320
} {
  din hub_0/cfg_data
}

# create filter
module filter_0 {
  source projects/low_pass/filter_NO_FIR_16.tcl
} {
  s_axis adc_0/M_AXIS
  cfg hub_0/cfg_data
  aclk pll_0/clk_out1
  aresetn writer_reset_slice/dout
}


# Create axis_broadcaster
cell xilinx.com:ip:axis_broadcaster bcast_ADC {
  S_TDATA_NUM_BYTES 4
  M_TDATA_NUM_BYTES 4
 } {
  S_AXIS filter_0/M_AXIS
  aclk pll_0/clk_out1
  aresetn writer_reset_slice/dout
}


# Create blk_mem_gen
cell xilinx.com:ip:blk_mem_gen waveform_bram {
    MEMORY_TYPE True_Dual_Port_RAM
    USE_BRAM_BLOCK Stand_Alone
    WRITE_WIDTH_A 32
    WRITE_DEPTH_A 32768
    READ_WIDTH_B 16
    WRITE_WIDTH_B 16
    ENABLE_A Always_Enabled
    ENABLE_B Always_Enabled
    REGISTER_PORTA_OUTPUT_OF_MEMORY_PRIMITIVES false
    REGISTER_PORTB_OUTPUT_OF_MEMORY_PRIMITIVES false
} {
  BRAM_PORTA hub_0/B00_BRAM
}

# Create xlslice
cell xilinx.com:ip:xlslice slice_measure_pulse {
  DIN_WIDTH 352 DIN_FROM 319 DIN_TO 160
} {
  Din hub_0/cfg_data
}

# Create axis_unblock
cell pavel-demin:user:axis_unblock unblock {
} {
  s_axis bcast_ADC/m01_axis
  aclk pll_0/clk_out1
  aresetn writer_reset_slice/dout
}



# Create xlslice
cell xilinx.com:ip:xlslice slice_decimate {
  DIN_WIDTH 256 DIN_FROM 127 DIN_TO 96
} {
  Din hub_0/cfg_data
}

# Create axis_variable
cell pavel-demin:user:axis_variable rate_0 {
  AXIS_TDATA_WIDTH 16
} {
  cfg_data slice_decimate/Dout
  aclk pll_0/clk_out1
  aresetn writer_reset_slice/dout
}


# Create pulse delay
cell pavel-demin:user:pulse_delay pulse_delay {
  CNTR_WIDTH  32
} {
  delay slice_delay/Dout
  pulse trig_0/trg_flag
  aclk pll_0/clk_out1
  aresetn writer_reset_slice/dout
}

# Create axis_pulse_pattern
cell pavel-demin:user:axis_pulse_pattern pulse_pattern {
    AXIS_TDATA_WIDTH 16
    BRAM_DATA_WIDTH 16
    BRAM_ADDR_WIDTH 16
} {
  cfg_data slice_measure_pulse/Dout
  s_axis unblock/m_axis
  bram waveform_bram/BRAM_PORTB
  trg_flag pulse_delay/delayed_pulse
  aclk pll_0/clk_out1
  aresetn writer_reset_slice/dout
}

# Create cic_compiler
cell xilinx.com:ip:cic_compiler interpol  {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Interpolation
  NUMBER_OF_STAGES 3
  SAMPLE_RATE_CHANGES Programmable
  MINIMUM_RATE 8
  MAXIMUM_RATE 6250
  FIXED_OR_INITIAL_RATE 64
  INPUT_SAMPLE_FREQUENCY 15.625
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 16
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 16
  HAS_ARESETN true
  USE_XTREME_DSP_SLICE true
  HAS_DOUT_TREADY true
} {
  S_AXIS_DATA pulse_pattern/M_AXIS
  S_AXIS_CONFIG rate_0/M_AXIS
  aclk pll_0/clk_out1
  aresetn writer_reset_slice/dout
}


# Create axis_packetizer
cell pavel-demin:user:axis_oscilloscope scope_0 {
  AXIS_TDATA_WIDTH 32
  CNTR_WIDTH 26
} {
  S_AXIS bcast_ADC/m00_axis
  run_flag run_slice/dout
  trg_flag trig_0/trg_flag
  pre_data pre_data_slice/dout
  tot_data tot_data_slice/dout
  aclk pll_0/clk_out1
  aresetn writer_reset_slice/dout
}


# Create xlconstant
cell xilinx.com:ip:xlconstant const_size {
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
  cfg_data const_size/dout
  aclk pll_0/clk_out1
  aresetn writer_reset_slice/dout
}

# Create axis_zeroer
cell pavel-demin:user:axis_zeroer zeroer_DAC {
  AXIS_TDATA_WIDTH 32
} {
  S_AXIS interpol/m_axis_data
  aclk pll_0/clk_out1
}

# Create axis_red_pitaya_dac
cell pavel-demin:user:axis_red_pitaya_dac dac_0 {} {
  aclk pll_0/clk_out1
  ddr_clk pll_0/clk_out2
  wrt_clk pll_0/clk_out3
  locked pll_0/locked
  S_AXIS zeroer_DAC/M_AXIS
  dac_clk dac_clk_o
  dac_rst dac_rst_o
  dac_sel dac_sel_o
  dac_wrt dac_wrt_o
  dac_dat dac_dat_o
}

# Create axis_fifo
cell pavel-demin:user:axis_fifo fifo_0 {
  S_AXIS_TDATA_WIDTH 32
  M_AXIS_TDATA_WIDTH 32
  WRITE_DEPTH 65536
} {
  S_AXIS pulse_pattern/M01_AXIS
  M_AXIS hub_0/S00_AXIS
  aclk pll_0/clk_out1
  aresetn writer_reset_slice/dout
}


# Create xlconstant
cell xilinx.com:ip:xlconstant const_ID {
  CONST_WIDTH 16
  CONST_VAL 155
}


# Create xlconcat
cell xilinx.com:ip:xlconcat concat_sts {
  NUM_PORTS 11
  IN0_WIDTH 32
  IN1_WIDTH 32
  IN2_WIDTH 1
  IN3_WIDTH 1
  IN4_WIDTH 1
  IN5_WIDTH 1
  IN6_WIDTH 3
  IN7_WIDTH 9
  IN8_WIDTH 16
  IN9_WIDTH 32
  IN10_WIDTH 32
} {
  In0 writer_0/sts_data
  In1 scope_0/sts_data
  In2 scope_0/triggered
  In3 scope_0/complete
  In4 writer_reset_slice/dout
  In5 pulse_pattern/overload
  In6 pulse_pattern/case_id
  In8 const_ID/dout
  In9 pulse_pattern/sts_data
  In10 pulse_pattern/pulse_count
  dout hub_0/sts_data
}



