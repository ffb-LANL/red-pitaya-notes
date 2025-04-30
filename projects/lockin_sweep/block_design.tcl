#lockin_sweep 103

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
  dout led_o
 }


# Create axi_hub
cell pavel-demin:user:axi_hub hub_0 {
  CFG_DATA_WIDTH 544
  STS_DATA_WIDTH 512
} {
  S_AXI ps_0/M_AXI_GP0
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}


# Create xlslice
cell xilinx.com:ip:xlslice slice_trx_reset {
  DIN_WIDTH 544 DIN_FROM 4 DIN_TO 4
} {
  Din hub_0/cfg_data
}


# Create xlconstant
cell xilinx.com:ip:xlconstant const_1

# Create axis_subset_converter
cell xilinx.com:ip:axis_subset_converter subset_ADC_A {
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


# Create axis_fifo
cell xilinx.com:ip:axis_data_fifo fifo_f {
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 4
  HAS_WR_DATA_COUNT 1
  FIFO_DEPTH 16384
} {
  S_AXIS hub_0/M00_AXIS
  s_axis_aclk /pll_0/clk_out1
  s_axis_aresetn slice_trx_reset/dout
}

# Create xlslice
cell xilinx.com:ip:xlslice slice_interpolate {
  DIN_WIDTH 544 DIN_FROM 159 DIN_TO 128
} {
  Din hub_0/cfg_data
}




# Create axis_interpolator
cell pavel-demin:user:axis_interpolator inter_f {
  AXIS_TDATA_WIDTH 32
  CNTR_WIDTH 32
} {
  S_AXIS fifo_f/M_AXIS
  cfg_data slice_interpolate/Dout
  aclk pll_0/clk_out1
  aresetn slice_trx_reset/dout
}



# Create dds_compiler
cell xilinx.com:ip:dds_compiler dds_0 {
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
  S_AXIS_PHASE inter_f/m_axis
  aclk pll_0/clk_out1
  aresetn slice_trx_reset/dout
}

# Create axis_broadcaster
cell xilinx.com:ip:axis_broadcaster bcast_DDS {
  S_TDATA_NUM_BYTES 4
  M_TDATA_NUM_BYTES 4
 } {
  S_AXIS dds_0/M_AXIS_DATA
  aclk pll_0/clk_out1
  aresetn slice_trx_reset/dout
}

# Create axis_lfsr
cell pavel-demin:user:axis_lfsr lfsr_0 {} {
  aclk pll_0/clk_out1
  aresetn slice_trx_reset/dout
}

# Create xlslice
cell xilinx.com:ip:xlslice slice_dds_delay {
  DIN_WIDTH 544 DIN_FROM 255 DIN_TO 224
} {
  Din hub_0/cfg_data
}

# create delay
cell pavel-demin:user:axis_fixed_delay delay_dds { 
 DEPTH 15
} {
  s_axis bcast_DDS/M01_AXIS
  aclk pll_0/clk_out1
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
  aresetn true
} {
  S_AXIS_A subset_ADC_A/M_AXIS
  s_axis_b delay_dds/M_AXIS
  S_AXIS_CTRL lfsr_0/M_AXIS
  aclk pll_0/clk_out1
  aresetn slice_trx_reset/dout
}

# Create xlslice
cell xilinx.com:ip:xlslice scale_factor {
  DIN_WIDTH 544 DIN_FROM 511 DIN_TO 480
} {
  Din hub_0/cfg_data
}


# Create axis_scaler
cell pavel-demin:user:axis_scaler scaler {
  AXIS_TDATA_WIDTH 14
} {
  S_AXIS bcast_DDS/M00_AXIS
  cfg_data scale_factor/Dout
  aclk pll_0/clk_out1
  aresetn slice_trx_reset/dout
}


# Create axis_red_pitaya_dac
cell pavel-demin:user:axis_red_pitaya_dac dac_0 {} {
  aclk pll_0/clk_out1
  ddr_clk pll_0/clk_out2
  wrt_clk pll_0/clk_out3
  locked pll_0/locked
  S_AXIS scaler/M_AXIS
  dac_clk dac_clk_o
  dac_rst dac_rst_o
  dac_sel dac_sel_o
  dac_wrt dac_wrt_o
  dac_dat dac_dat_o
}

# Create axis_broadcaster
cell xilinx.com:ip:axis_broadcaster bcast_mult {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  M_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 8
  M_TDATA_NUM_BYTES 4
  M00_TDATA_REMAP {tdata[31:0]}
  M01_TDATA_REMAP {tdata[63:32]}
} {
  S_AXIS mult_0/M_AXIS_DOUT
  aclk /pll_0/clk_out1
  aresetn /slice_trx_reset/dout
}


# Create cic_compiler
cell xilinx.com:ip:cic_compiler cic_x0 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 3
  FIXED_OR_INITIAL_RATE 8192
  INPUT_SAMPLE_FREQUENCY 125
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 28
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 32
  HAS_ARESETN true
  USE_XTREME_DSP_SLICE true
  HAS_DOUT_TREADY true
} {
  S_AXIS_DATA bcast_mult/M00_AXIS
  aclk /pll_0/clk_out1
  aresetn slice_trx_reset/dout
}

# Create cic_compiler
cell xilinx.com:ip:cic_compiler cic_y0 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 3
  FIXED_OR_INITIAL_RATE 8192
  INPUT_SAMPLE_FREQUENCY 125
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 28
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 32
  HAS_ARESETN true
  USE_XTREME_DSP_SLICE true
  HAS_DOUT_TREADY true
} {
  S_AXIS_DATA bcast_mult/M01_AXIS
  aclk /pll_0/clk_out1
  aresetn slice_trx_reset/dout
}

# Create axis_combiner
cell  xilinx.com:ip:axis_combiner comb_xy {
  NUM_SI 2
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 4
} {
  S00_AXIS cic_x0/M_AXIS_DATA
  S01_AXIS cic_y0/M_AXIS_DATA
  aclk /pll_0/clk_out1
  aresetn slice_trx_reset/dout
  }

# Create axis_dwidth_converter
cell xilinx.com:ip:axis_dwidth_converter: conv_xy {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 8
  M_TDATA_NUM_BYTES 4
} {
  S_AXIS comb_xy/M_AXIS
  aclk /pll_0/clk_out1
  aresetn slice_trx_reset/dout
}

# Create axis_subset_converter
cell xilinx.com:ip:axis_subset_converter subset_multichan {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  M_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 4
  M_TDATA_NUM_BYTES 4
  DEFAULT_TLAST 2  
  M_HAS_TLAST 1
} {
  s_axis conv_xy/M_AXIS
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create xlslice
cell xilinx.com:ip:xlslice slice_decimate {
  DIN_WIDTH 544 DIN_FROM 127 DIN_TO 96
} {
  Din hub_0/cfg_data
}


# Create axis_variable
cell pavel-demin:user:axis_variable rate_x {
  AXIS_TDATA_WIDTH 16
} {
  cfg_data slice_decimate/Dout
  aclk /pll_0/clk_out1
  aresetn slice_trx_reset/dout
}


# Create cic_compiler
cell xilinx.com:ip:cic_compiler cic_xy {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 3
  SAMPLE_RATE_CHANGES Programmable
  MINIMUM_RATE 4
  MAXIMUM_RATE 8192
  Number_Of_Channels 2
  FIXED_OR_INITIAL_RATE 16
  INPUT_SAMPLE_FREQUENCY 0.1
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 32
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 32
  HAS_ARESETN true
  USE_XTREME_DSP_SLICE true
  HAS_DOUT_TREADY true
} {
  S_AXIS_DATA subset_multichan/M_AXIS
  S_AXIS_CONFIG rate_x/M_AXIS
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}



# Create axis_fifo
cell xilinx.com:ip:axis_data_fifo fifo_xy {
  FIFO_DEPTH 32768
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 4
  HAS_WR_DATA_COUNT 1
} {
  S_AXIS cic_xy/M_AXIS_DATA
  s_axis_aclk pll_0/clk_out1
  s_axis_aresetn slice_trx_reset/dout
  M_AXIS hub_0/S00_AXIS
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
  In7 fifo_xy/axis_wr_data_count
  In8 fifo_f/axis_wr_data_count
  In11 slice_interpolate/Dout
  dout hub_0/sts_data
}


