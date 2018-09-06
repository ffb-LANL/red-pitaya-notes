#Filter
create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis
create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m_axis
create_bd_pin -dir I -type rst aresetn
create_bd_pin -dir I -type clk aclk
create_bd_pin -dir I -type data -from 255 -to 0 cfg

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_2 {
  DIN_WIDTH 256 DIN_FROM 2 DIN_TO 2 DOUT_WIDTH 1
} {
  Din cfg
}


# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_5 {
  DIN_WIDTH 256 DIN_FROM 127 DIN_TO 96 
} {
  Din cfg
}

# Create axis_subset_converter
cell xilinx.com:ip:axis_subset_converter:1.1 subset_0 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  M_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 4
  M_TDATA_NUM_BYTES 2
  TDATA_REMAP {tdata[31:16]}
} {
  S_AXIS s_axis
  aclk aclk
  aresetn aresetn
}

# create filter
module cic_filter_0 {
  source projects/filter_test/cic_filter.tcl
} {
  s_axis subset_0/M_AXIS
  cfg slice_5/Dout
  update  slice_2/Dout
  aclk aclk
  aresetn aresetn 
}

# Create axis_dwidth_converter
cell xilinx.com:ip:axis_dwidth_converter:1.1 conv_0 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 2
  M_TDATA_NUM_BYTES 8
} {
  S_AXIS cic_filter_0/M_AXIS
  m_axis m_axis
  aclk aclk
  aresetn aresetn
}