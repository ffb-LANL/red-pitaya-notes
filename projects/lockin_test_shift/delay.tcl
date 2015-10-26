#Delay
create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_if_axis
create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m_if_axis
set_property -dict [list CONFIG.DATA_WIDTH 32 CONFIG.HAS_TDATA 1 CONFIG.HAS_TREADY 1 CONFIG.HAS_TVALID 1] [get_bd_intf_pins /delay_0/s_if_axis]
set_property -dict [list CONFIG.DATA_WIDTH 32 CONFIG.HAS_TDATA 1 CONFIG.HAS_TREADY 1 CONFIG.HAS_TVALID 1] [get_bd_intf_pins /delay_0/m_if_axis]
create_bd_pin -dir I -type rst aresetn
create_bd_pin -dir I -type clc aclk

# Create slice
cell xilinx.com:ip:axis_register_slice:1.1 axi_slice_0 {
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 4
} {
  S_AXIS s_if_axis
  M_axis m_if_axis
 aclk aclk
  aresetn aresetn
}





# Create delay
cell xilinx.com:ip:c_shift_ram:12.0 c_shift_ram_0 {
  WIDTH 32
  DEPTH 30
  CE true
 } {
  D s_if_axis_tdata
  Q m_if_axis_tdata
  CLK aclk
}

# Create logic
cell xilinx.com:ip:util_vector_logic:2.0 logic_0 {
  C_SIZE 1
  C_OPERATION and
} {
 Op1 s_if_axis_tvalid 
 Op2 m_if_axis_tready
 res c_shift_ram_0/CE 
} 

#S00_AXIS bcast_0/M00_AXIS
 # S01_AXIS fifo_0/M_AXIS



