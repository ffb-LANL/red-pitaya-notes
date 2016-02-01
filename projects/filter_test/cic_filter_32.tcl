#Filter
create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis
create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m_axis
create_bd_pin -dir I -type rst aresetn
create_bd_pin -dir I -type clc aclk
create_bd_pin -dir I -type data -from 15 -to 0 cfg


# Create axis_variable
cell pavel-demin:user:axis_variable:1.0 rate_0 {
  AXIS_TDATA_WIDTH 16
} {
  cfg_data cfg
  aclk aclk
  aresetn aresetn
}

# Create cic_compiler
cell xilinx.com:ip:cic_compiler:4.0 cic_0 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 3
  SAMPLE_RATE_CHANGES Programmable
  MINIMUM_RATE 4
  MAXIMUM_RATE 8192
  FIXED_OR_INITIAL_RATE 8192
  INPUT_SAMPLE_FREQUENCY 125
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 32
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 32
  HAS_ARESETN true
  USE_XTREME_DSP_SLICE true
} {
  S_AXIS_DATA s_axis
  S_AXIS_CONFIG rate_0/M_AXIS
  m_axis_data m_axis
  aclk aclk
  aresetn aresetn
}

