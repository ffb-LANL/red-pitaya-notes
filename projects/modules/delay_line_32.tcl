#Delay Line
create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis
create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m_axis
create_bd_pin -dir I -type rst aresetn
create_bd_pin -dir I -type clc aclk
create_bd_pin -dir I -type data -from 255 -to 0 cfg

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_delay {
  DIN_WIDTH 256 DIN_FROM 255 DIN_TO 224
} {
  Din cfg
}

# Create axis_data_fifo
cell xilinx.com:ip:axis_data_fifo:1.1 fifo_delay {
  FIFO_DEPTH 512
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 4
} {
  s_axis_aclk aclk
  s_axis_aresetn aresetn
}

# create delay
cell pavel-demin:user:axis_delay:1.0 delay {
  AXIS_TDATA_WIDTH 32
} {
  s_axis s_axis
  s_axis_fifo fifo_delay/m_axis
  m_axis_fifo fifo_delay/s_axis 
  m_axis m_axis
  axis_data_count fifo_delay/axis_data_count
  cfg_data slice_delay/dout
  aclk aclk
  aresetn aresetn
}


