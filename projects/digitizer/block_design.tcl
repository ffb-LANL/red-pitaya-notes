#digitizer 152

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
  DIN_WIDTH 512 DIN_FROM 0 DIN_TO 0
} {
  din hub_0/cfg_data
}

# Create port_slicer
cell pavel-demin:user:port_slicer run_slice {
  DIN_WIDTH 512 DIN_FROM 1 DIN_TO 1
} {
  din hub_0/cfg_data
}

# Create xlslice
cell pavel-demin:user:port_slicer slice_trig_record {
  DIN_WIDTH 512 DIN_FROM 3 DIN_TO 3
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
  DIN_WIDTH 512 DIN_FROM 447 DIN_TO 416
} {
  din hub_0/cfg_data
}


# Create port_slicer
cell pavel-demin:user:port_slicer tot_data_slice {
  DIN_WIDTH 512 DIN_FROM 63 DIN_TO 32
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


# Create axis_broadcaster
cell xilinx.com:ip:axis_broadcaster bcast_0 {
  NUM_MI 4
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  M_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 4
  M_TDATA_NUM_BYTES 2
  M00_TDATA_REMAP {tdata[15:0]}
  M01_TDATA_REMAP {tdata[31:16]}
  M02_TDATA_REMAP {tdata[15:0]}
  M03_TDATA_REMAP {tdata[31:16]}
} {
  S_AXIS adc_0/M_AXIS
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}


# Create port_slicer
cell pavel-demin:user:port_slicer decimation_rate {
  DIN_WIDTH 512 DIN_FROM 127 DIN_TO 96
} {
  din hub_0/cfg_data
}


# Create axis_variable
cell pavel-demin:user:axis_variable rate_0 {
  AXIS_TDATA_WIDTH 16
} {
  cfg_data decimation_rate/dout
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create axis_variable
cell pavel-demin:user:axis_variable rate_1 {
  AXIS_TDATA_WIDTH 16
} {
  cfg_data decimation_rate/dout
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}



# Create cic_compiler
cell xilinx.com:ip:cic_compiler cic_0 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 6
  SAMPLE_RATE_CHANGES Programmable
  MINIMUM_RATE 4
  MAXIMUM_RATE 6250
  FIXED_OR_INITIAL_RATE 125
  INPUT_SAMPLE_FREQUENCY 125
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 14
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 16
  USE_XTREME_DSP_SLICE false
  HAS_ARESETN true
} {
  S_AXIS_DATA bcast_0/M00_AXIS
  S_AXIS_CONFIG rate_0/M_AXIS
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create cic_compiler
cell xilinx.com:ip:cic_compiler cic_1 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 6
  SAMPLE_RATE_CHANGES Programmable
  MINIMUM_RATE 4
  MAXIMUM_RATE 6250
  FIXED_OR_INITIAL_RATE 125
  INPUT_SAMPLE_FREQUENCY 125
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 14
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 16
  USE_XTREME_DSP_SLICE false
  HAS_ARESETN true
} {
  S_AXIS_DATA bcast_0/M01_AXIS
  S_AXIS_CONFIG rate_1/M_AXIS
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create axis_combiner
cell  xilinx.com:ip:axis_combiner comb_0 {
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 2
} {
  S00_AXIS cic_0/M_AXIS_DATA
  S01_AXIS cic_1/M_AXIS_DATA
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}


# Create axis_oscilloscope
cell pavel-demin:user:axis_oscilloscope scope_0 {
  AXIS_TDATA_WIDTH 32
  CNTR_WIDTH 26
} {
  S_AXIS comb_0/M_AXIS
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

# Create cic_compiler
cell xilinx.com:ip:cic_compiler cic_2 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 6
  SAMPLE_RATE_CHANGES Fixed
  MINIMUM_RATE 8192
  MAXIMUM_RATE 8192
  FIXED_OR_INITIAL_RATE 8192
  INPUT_SAMPLE_FREQUENCY 125
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 14
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 32
  USE_XTREME_DSP_SLICE false
  HAS_ARESETN true
} {
  S_AXIS_DATA bcast_0/M02_AXIS
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create cic_compiler
cell xilinx.com:ip:cic_compiler cic_3 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 6
  SAMPLE_RATE_CHANGES Fixed
  MINIMUM_RATE 8192
  MAXIMUM_RATE 8192
  FIXED_OR_INITIAL_RATE 8192
  INPUT_SAMPLE_FREQUENCY 125
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 14
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 32
  USE_XTREME_DSP_SLICE false
  HAS_ARESETN true
} {
  S_AXIS_DATA bcast_0/M03_AXIS
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create cic_compiler
cell xilinx.com:ip:cic_compiler cic_4 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 6
  SAMPLE_RATE_CHANGES Fixed
  MINIMUM_RATE 512
  MAXIMUM_RATE 512
  FIXED_OR_INITIAL_RATE 512
  INPUT_SAMPLE_FREQUENCY 125
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 32
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 32
  USE_XTREME_DSP_SLICE false
  HAS_ARESETN true
} {
  S_AXIS_DATA cic_2/M_AXIS_DATA
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create cic_compiler
cell xilinx.com:ip:cic_compiler cic_5 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 6
  SAMPLE_RATE_CHANGES Fixed
  MINIMUM_RATE 512
  MAXIMUM_RATE 512
  FIXED_OR_INITIAL_RATE 512
  INPUT_SAMPLE_FREQUENCY 125
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 32
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 32
  USE_XTREME_DSP_SLICE false
  HAS_ARESETN true
} {
  S_AXIS_DATA cic_3/M_AXIS_DATA
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create axis_combiner
cell  xilinx.com:ip:axis_combiner comb_xy {
  NUM_SI 2
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 4
} {
  S00_AXIS cic_4/M_AXIS_DATA
  S01_AXIS cic_5/M_AXIS_DATA
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
  }

#create value
cell pavel-demin:user:axis_value value_xy {
AXIS_TDATA_WIDTH 64
} {
  s_axis comb_xy/M_AXIS
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create xlconstant
cell xilinx.com:ip:xlconstant const_ID {
  CONST_WIDTH 16
  CONST_VAL 152
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
  In7 value_xy/data
  In8 const_modulus/dout
  dout hub_0/sts_data
}




