#Filter

# Create axis_broadcaster
cell xilinx.com:ip:axis_broadcaster bcast_two {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  M_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 8
  M_TDATA_NUM_BYTES 4
  M00_TDATA_REMAP {tdata[31:0]}
  M01_TDATA_REMAP {tdata[63:32]}
} {
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

# Create xlslice
cell xilinx.com:ip:xlslice slice_decimate {
  DIN_WIDTH 256 DIN_FROM 127 DIN_TO 96
} {
}

# Create cic_compiler
cell xilinx.com:ip:cic_compiler cic_filter_x1 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 3
  FIXED_OR_INITIAL_RATE 1024
  INPUT_SAMPLE_FREQUENCY 125
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 28
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 32
  HAS_ARESETN true
  USE_XTREME_DSP_SLICE true
  HAS_DOUT_TREADY true
} {
  S_AXIS_DATA bcast_two/M00_AXIS
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}



# Create cic_compiler
cell xilinx.com:ip:cic_compiler cic_filter_y1 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 3
  FIXED_OR_INITIAL_RATE 1024
  INPUT_SAMPLE_FREQUENCY 125
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 28
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 32
  HAS_ARESETN true
  USE_XTREME_DSP_SLICE true
  HAS_DOUT_TREADY true
} {
  S_AXIS_DATA bcast_two/M01_AXIS
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

