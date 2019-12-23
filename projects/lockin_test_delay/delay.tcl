#Delay
create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis
create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m_axis
create_bd_pin -dir I -type rst aresetn
create_bd_pin -dir I -type clc aclk

# Create slice
cell xilinx.com:ip:axis_register_slice axi_slice_0 {
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 4
  HAS_TREADY.VALUE_SRC USER
  HAS_TREADY 1
} {
  S_AXIS S_AXIS
  aclk aclk
  aresetn aresetn
}





# Create delay
cell xilinx.com:ip:c_shift_ram c_shift_ram_0 {
  WIDTH 32
  DEPTH 28
  CE true
 } {
  D axi_slice_0/m_axis_tdata
  CLK aclk
}


# Create slice
cell xilinx.com:ip:axis_register_slice axi_slice_1 {
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 4
  HAS_TREADY.VALUE_SRC USER
  HAS_TREADY 1
} {
  s_axis_tdata c_shift_ram_0/Q
  s_axis_tvalid axi_slice_0/m_axis_tvalid
  s_axis_tready axi_slice_0/m_axis_tready
  M_axis m_axis
  aclk aclk
  aresetn aresetn
}



# Create logic
cell xilinx.com:ip:util_vector_logic logic_0 {
  C_SIZE 1
  C_OPERATION and
} {
 Op1 axi_slice_0/m_axis_tvalid
 Op2 axi_slice_1/s_axis_tready
 res c_shift_ram_0/CE 
} 

#S00_AXIS bcast_0/M00_AXIS
 # S01_AXIS fifo_0/M_AXIS



