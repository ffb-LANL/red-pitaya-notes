#sptream split test

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
cell xilinx.com:ip:xlslice slice_trx_reset {
  DIN_WIDTH 256 DIN_FROM 4 DIN_TO 4
} {
  Din hub_0/cfg_data
}

#cell xilinx.com:ip:util_vector_logic comb_rst {
#  C_SIZE 2
#  C_OPERATION and
#} {
#  op1 rst_0/peripheral_aresetn
#  op2 slice_trx_reset/dout
#}

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
cell xilinx.com:ip:xlslice slice_decimate {
  DIN_WIDTH 256 DIN_FROM 127 DIN_TO 96
} {
  Din hub_0/cfg_data
}

# Create xlslice
cell xilinx.com:ip:xlslice slice_interpolate {
  DIN_WIDTH 256 DIN_FROM 159 DIN_TO 128
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
cell xilinx.com:ip:axis_broadcaster bcast_dds {
  NUM_MI 3
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  M_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 4
  M_TDATA_NUM_BYTES 4
  M00_TDATA_REMAP {16'b0,tdata[15:0]}
  M01_TDATA_REMAP {tdata[31:0]}
  M02_TDATA_REMAP {16'b0,tdata[15:0]}
} {
  S_AXIS dds_0/M_AXIS_DATA
  aclk /pll_0/clk_out1
  aresetn slice_trx_reset/dout
}

# Create axis_lfsr
cell pavel-demin:user:axis_lfsr lfsr_0 {} {
  aclk pll_0/clk_out1
  aresetn slice_trx_reset/dout
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
  S_AXIS_A bcast_dds/M00_AXIS
  s_axis_b bcast_dds/M01_AXIS
  S_AXIS_CTRL lfsr_0/M_AXIS
  aclk pll_0/clk_out1
  aresetn slice_trx_reset/dout
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
cell xilinx.com:ip:cic_compiler cic_filter_x0 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 3
  FIXED_OR_INITIAL_RATE 8192
  INPUT_SAMPLE_FREQUENCY 125
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 32
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

# Create axis_variable
cell pavel-demin:user:axis_variable rate_x {
  AXIS_TDATA_WIDTH 16
} {
  cfg_data slice_decimate/Dout
  aclk /pll_0/clk_out1
  aresetn slice_trx_reset/dout
}

# Create cic_compiler
cell xilinx.com:ip:cic_compiler cic_x1 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 3
  SAMPLE_RATE_CHANGES Programmable
  MINIMUM_RATE 4
  MAXIMUM_RATE 8192
  FIXED_OR_INITIAL_RATE 128
  INPUT_SAMPLE_FREQUENCY 125
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 32
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 32
  HAS_ARESETN true
  USE_XTREME_DSP_SLICE true
  HAS_DOUT_TREADY true
} {
  S_AXIS_DATA cic_filter_x0/M_AXIS_DATA
  S_AXIS_CONFIG rate_x/M_AXIS
  aclk /pll_0/clk_out1
  aresetn slice_trx_reset/dout
}


# Create axis_fifo
cell xilinx.com:ip:axis_data_fifo fifo_x {
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 4
  HAS_WR_DATA_COUNT 1
  FIFO_DEPTH 8192
} {
  S_AXIS cic_x1/M_AXIS_DATA
  s_axis_aclk /pll_0/clk_out1
  s_axis_aresetn slice_trx_reset/dout
  M_AXIS hub_0/S01_AXIS
}

# Create cic_compiler
cell xilinx.com:ip:cic_compiler cic_filter_y0 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 3
  FIXED_OR_INITIAL_RATE 8192
  INPUT_SAMPLE_FREQUENCY 125
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 32
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

# Create axis_variable
cell pavel-demin:user:axis_variable rate_y {
  AXIS_TDATA_WIDTH 16
} {
  cfg_data slice_decimate/Dout
  aclk /pll_0/clk_out1
  aresetn slice_trx_reset/dout
}

# Create cic_compiler
cell xilinx.com:ip:cic_compiler cic_y1 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 3
  SAMPLE_RATE_CHANGES Programmable
  MINIMUM_RATE 4
  MAXIMUM_RATE 8192
  FIXED_OR_INITIAL_RATE 128
  INPUT_SAMPLE_FREQUENCY 125
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 32
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 32
  HAS_ARESETN true
  USE_XTREME_DSP_SLICE true
  HAS_DOUT_TREADY true
} {
  S_AXIS_DATA cic_filter_y0/M_AXIS_DATA
  S_AXIS_CONFIG rate_y/M_AXIS
  aclk /pll_0/clk_out1
  aresetn slice_trx_reset/dout
}

# Create axis_fifo
cell xilinx.com:ip:axis_data_fifo fifo_y {
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 4
  HAS_WR_DATA_COUNT 1
  FIFO_DEPTH 8192
} {
  S_AXIS cic_y1/M_AXIS_DATA
  s_axis_aclk /pll_0/clk_out1
  s_axis_aresetn slice_trx_reset/dout
  M_AXIS hub_0/S02_AXIS
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
  S_AXIS bcast_DDS/M02_AXIS
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



# Create xlconcat
cell xilinx.com:ip:xlconcat concat_status {
  NUM_PORTS 5
  IN0_WIDTH 192
  IN1_WIDTH 32
  IN2_WIDTH 32
  IN3_WIDTH 32
  IN4_WIDTH 32
} {
  In1 fifo_x/axis_wr_data_count
  In3 fifo_y/axis_wr_data_count
  In4 slice_interpolate/Dout
  dout hub_0/sts_data
}


