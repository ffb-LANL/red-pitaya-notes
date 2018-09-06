#Filter
create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis
create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis_f
create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m_axis
create_bd_pin -dir I -type rst aresetn
create_bd_pin -dir I -type clk aclk
create_bd_pin -dir I -type data -from 255 -to 0 cfg

# Create axis_broadcaster
cell xilinx.com:ip:axis_broadcaster:1.1 bcast_two {
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
cell xilinx.com:ip:xlslice:1.0 slice_decimate {
  DIN_WIDTH 256 DIN_FROM 127 DIN_TO 96
} {
  Din cfg
}

# create filter
module cic_filter_0 {
  source projects/filter_test/cic_filter_32.tcl
} {
  s_axis bcast_two/M00_AXIS
  cfg slice_decimate/Dout
  aclk aclk
  aresetn aresetn 
}


# create filter
module cic_filter_1 {
  source projects/filter_test/cic_filter_32.tcl
} {
  s_axis bcast_two/M01_AXIS
  cfg slice_decimate/Dout
  aclk aclk
  aresetn aresetn 
}

# create delay
module delay_f {
  source projects/lockin_test_delay/delay.tcl
} {
  s_axis s_axis_f
  aclk aclk 
  aresetn aresetn
}


# Create axis_decimator
cell pavel-demin:user:axis_decimator:1.0 dcmtr_f {
  AXIS_TDATA_WIDTH 32
  CNTR_WIDTH 16
} {
  S_AXIS delay_f/M_AXIS
  cfg_data slice_decimate/Dout
  aclk aclk 
  aresetn aresetn 
}

# Create axis_combiner
cell  xilinx.com:ip:axis_combiner:1.1 comb_xy {
  NUM_SI 3
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 4
} {
  S00_AXIS cic_filter_0/M_AXIS
  S01_AXIS cic_filter_1/M_AXIS
  S02_AXIS dcmtr_f/M_AXIS
  m_axis m_axis
  aclk aclk
  aresetn aresetn
  }

