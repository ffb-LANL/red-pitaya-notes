#DDS
create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m_axis
create_bd_pin -dir I -type rst aresetn
create_bd_pin -dir I -type clc aclk
create_bd_pin -dir I -type data -from 31 -to 0 cfg
create_bd_pin -dir I -type data trigger
create_bd_pin -dir O -type data -from 31 -to 0 status


# Create axis_constant
cell pavel-demin:user:axis_constant:1.0 phase_0 {
  AXIS_TDATA_WIDTH 32
} {
  cfg_data cfg
  aclk aclk
}


# Create dds_compiler
cell xilinx.com:ip:dds_compiler:6.0 dds_0 {
  DDS_CLOCK_RATE 125
  parameter_entry Hardware_Parameters
  OUTPUT_WIDTH 14
  PHASE_WIDTH 32 
 PHASE_INCREMENT Streaming
  DSP48_USE Maximal
  HAS_TREADY true
  HAS_PHASE_OUT true
} {
  S_AXIS_PHASE phase_0/M_AXIS
  aclk aclk
  M_AXIS_DATA m_axis
}

# Create axis_snapshot
cell pavel-demin:user:axis_snapshot:1.0 snap_0 {
  AXIS_TDATA_WIDTH 32
} {
  S_AXIS dds_0/M_AXIS_PHASE
  aclk aclk
  aresetn trigger
  data status
}