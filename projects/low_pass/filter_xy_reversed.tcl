#Filter xy reversed

create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis
create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m_axis_x
create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m_axis_y
create_bd_pin -dir I -type rst aresetn
create_bd_pin -dir I -type clk aclk
create_bd_pin -dir I -type data -from 255 -to 0 cfg

# Create axis_broadcaster
cell xilinx.com:ip:axis_broadcaster bcast_two {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  M_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 8
  M_TDATA_NUM_BYTES 4
  M00_TDATA_REMAP {tdata[31:0]}
  M01_TDATA_REMAP {tdata[63:32]}
} {
  S_AXIS s_axis
  aclk aclk
  aresetn aresetn
}

# Create xlslice
cell xilinx.com:ip:xlslice slice_decimate {
  DIN_WIDTH 256 DIN_FROM 127 DIN_TO 96
} {
  Din cfg
}



# create filter
module cic_filter_x_var {
  source projects/low_pass/cic_filter_28_32.tcl
} {
  s_axis bcast_two/M00_AXIS
  cfg slice_decimate/Dout
  aclk aclk
  aresetn aresetn 
}


# Create cic_compiler
cell xilinx.com:ip:cic_compiler cic_filter_x_fixed {
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
  S_AXIS_DATA cic_filter_x_var/M_AXIS
  M_AXIS_DATA m_axis_x
  aclk aclk
  aresetn aresetn
}



# create filter
module cic_filter_y_var {
  source projects/low_pass/cic_filter_28_32.tcl
} {
  s_axis bcast_two/M01_AXIS
  cfg slice_decimate/Dout
  aclk aclk
  aresetn aresetn 
}

# Create cic_compiler
cell xilinx.com:ip:cic_compiler cic_filter_y_fixed {
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
  S_AXIS_DATA cic_filter_y_var/M_AXIS
  M_AXIS_DATA m_axis_y
  aclk aclk
  aresetn aresetn
}
