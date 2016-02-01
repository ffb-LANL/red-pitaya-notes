#lockin

# Create processing_system7
cell xilinx.com:ip:processing_system7:5.5 ps_0 {
  PCW_IMPORT_BOARD_PRESET cfg/red_pitaya.xml
  PCW_USE_S_AXI_HP0 1
} {
  M_AXI_GP0_ACLK ps_0/FCLK_CLK0
  S_AXI_HP0_ACLK ps_0/FCLK_CLK0
}

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {
  make_external {FIXED_IO, DDR}
  Master Disable
  Slave Disable
} [get_bd_cells ps_0]

# Create util_ds_buf
cell xilinx.com:ip:util_ds_buf:2.1 buf_0 {
  C_SIZE 2
  C_BUF_TYPE IBUFDS
} {
  IBUF_DS_P daisy_p_i
  IBUF_DS_N daisy_n_i
}

# Create util_ds_buf
cell xilinx.com:ip:util_ds_buf:2.1 buf_1 {
  C_SIZE 2
  C_BUF_TYPE OBUFDS
} {
  OBUF_DS_P daisy_p_o
  OBUF_DS_N daisy_n_o
}

# Create proc_sys_reset
cell xilinx.com:ip:proc_sys_reset:5.0 rst_0


# Create axis_red_pitaya_adc
cell pavel-demin:user:axis_red_pitaya_adc:1.0 adc_0 {} {
  adc_clk_p adc_clk_p_i
  adc_clk_n adc_clk_n_i
  adc_dat_a adc_dat_a_i
  adc_dat_b adc_dat_b_i
  adc_csn adc_csn_o
}

# Create c_counter_binary
cell xilinx.com:ip:c_counter_binary:12.0 cntr_0 {
  Output_Width 32
} {
  CLK adc_0/adc_clk
}

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_0 {
  DIN_WIDTH 32 DIN_FROM 26 DIN_TO 21
} {
  Din cntr_0/Q
 }


# Create axi_cfg_register
cell pavel-demin:user:axi_cfg_register:1.0 cfg_0 {
  CFG_DATA_WIDTH 256
  AXI_ADDR_WIDTH 32
  AXI_DATA_WIDTH 32
}

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Master /ps_0/M_AXI_GP0
  Clk Auto
} [get_bd_intf_pins cfg_0/S_AXI]

set_property RANGE 4K [get_bd_addr_segs ps_0/Data/SEG_cfg_0_reg0]
set_property OFFSET 0x40000000 [get_bd_addr_segs ps_0/Data/SEG_cfg_0_reg0]

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_1 {
  DIN_WIDTH 256 DIN_FROM 129 DIN_TO 128 
} {
  Din cfg_0/cfg_data
}

# Create xlconcat
cell xilinx.com:ip:xlconcat:2.1 concat_0 {
  IN1_WIDTH 2
} {
  In0 slice_0/Dout
  In1 slice_1/Dout
  dout led_o
}

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_pktzr_reset {
  DIN_WIDTH 256 DIN_FROM 0 DIN_TO 0 DOUT_WIDTH 1
} {
  Din cfg_0/cfg_data
}

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_write_enable {
  DIN_WIDTH 256 DIN_FROM 1 DIN_TO 1 DOUT_WIDTH 1
} {
  Din cfg_0/cfg_data
}

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_record_length {
  DIN_WIDTH 256 DIN_FROM 63 DIN_TO 32 DOUT_WIDTH 32
} {
  Din cfg_0/cfg_data
}


# Create xlconstant
cell xilinx.com:ip:xlconstant:1.1 const_1

# Create axis_clock_converter
cell xilinx.com:ip:axis_clock_converter:1.1 fifo_ADC {} {
  S_AXIS adc_0/M_AXIS
  s_axis_aclk adc_0/adc_clk
  s_axis_aresetn const_1/dout
  m_axis_aclk ps_0/FCLK_CLK0
  m_axis_aresetn rst_0/peripheral_aresetn
}

# Create axis_broadcaster
cell xilinx.com:ip:axis_broadcaster:1.1 bcast_ADC {
  S_TDATA_NUM_BYTES 4
  M_TDATA_NUM_BYTES 4
 } {
  S_AXIS fifo_ADC/M_AXIS
  aclk ps_0/FCLK_CLK0
  aresetn rst_0/peripheral_aresetn
}


# Create axis_subset_converter
cell xilinx.com:ip:axis_subset_converter:1.1 subset_ADC_A {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  M_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 4
  M_TDATA_NUM_BYTES 2
  TDATA_REMAP {tdata[15:0]}
} {
 s_axis bcast_ADC/M01_AXIS
  aclk ps_0/FCLK_CLK0
  aresetn rst_0/peripheral_aresetn
}


# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_frequency {
  DIN_WIDTH 256 DIN_FROM 95 DIN_TO 64
} {
  Din cfg_0/cfg_data
}

# Create axis_constant
cell pavel-demin:user:axis_constant:1.0 phase_0 {
  AXIS_TDATA_WIDTH 32
} {
  cfg_data slice_frequency/Dout
  aclk ps_0/FCLK_CLK0
}


# Create axis_broadcaster
cell xilinx.com:ip:axis_broadcaster:1.1 bcast_f {
  S_TDATA_NUM_BYTES 4
  M_TDATA_NUM_BYTES 4
 } {
  S_AXIS phase_0/m_axis
  aclk ps_0/FCLK_CLK0
  aresetn rst_0/peripheral_aresetn
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
  S_AXIS_PHASE bcast_f/M00_AXIS
  aclk ps_0/FCLK_CLK0
}

# Create axis_broadcaster
cell xilinx.com:ip:axis_broadcaster:1.1 bcast_DDS {
  S_TDATA_NUM_BYTES 4
  M_TDATA_NUM_BYTES 4
 } {
  S_AXIS dds_0/M_AXIS_DATA
  aclk ps_0/FCLK_CLK0
  aresetn rst_0/peripheral_aresetn
}


# Create axis_lfsr
cell pavel-demin:user:axis_lfsr:1.0 lfsr_0 {} {
  aclk ps_0/FCLK_CLK0
  aresetn rst_0/peripheral_aresetn
}


# create delay
module delay_0 {
  source projects/lockin_test_delay/delay.tcl
} {
  s_axis bcast_DDS/M01_AXIS
  aclk ps_0/FCLK_CLK0
  aresetn rst_0/peripheral_aresetn
}

#create value
#cell pavel-demin:user:axis_value:1.0 value_1 {
#AXIS_TDATA_WIDTH 16
#} {
#  s_axis bcast_ADC/M00_AXIS
#  aclk ps_0/FCLK_CLK0
#  aresetn rst_0/peripheral_aresetn
#}

# Create cmpy
cell xilinx.com:ip:cmpy:6.0 mult_0 {
  FLOWCONTROL Blocking
  APORTWIDTH.VALUE_SRC USER
  BPORTWIDTH.VALUE_SRC USER
  APORTWIDTH 14
  BPORTWIDTH 14
  ROUNDMODE Random_Rounding
  OUTPUTWIDTH 28
} {
  S_AXIS_A subset_ADC_A/M_AXIS
  s_AXIS_B delay_0/M_AXIS
  S_AXIS_CTRL lfsr_0/M_AXIS
  aclk ps_0/FCLK_CLK0
}


# Create clk_wiz
cell xilinx.com:ip:clk_wiz:5.2 pll_0 {
  PRIMITIVE PLL
  PRIM_IN_FREQ.VALUE_SRC USER
  PRIM_IN_FREQ 125.0
  CLKOUT1_USED true
  CLKOUT2_USED true
  CLKOUT1_REQUESTED_OUT_FREQ 125.0
  CLKOUT2_REQUESTED_OUT_FREQ 250.0
} {
  clk_in1 adc_0/adc_clk
}

# Create dac_clock_converter
cell xilinx.com:ip:axis_clock_converter:1.1 fifo_dac {
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 4
} {
  S_AXIS bcast_DDS/M00_AXIS
  s_axis_aclk ps_0/FCLK_CLK0
  s_axis_aresetn rst_0/peripheral_aresetn
  m_axis_aclk pll_0/clk_out1
  m_axis_aresetn const_1/dout
}

# Create axis_red_pitaya_dac
cell pavel-demin:user:axis_red_pitaya_dac:1.0 dac_0 {} {
  aclk pll_0/clk_out1
  ddr_clk pll_0/clk_out2
  locked pll_0/locked
  S_AXIS fifo_dac/M_AXIS
  dac_clk dac_clk_o
  dac_rst dac_rst_o
  dac_sel dac_sel_o
  dac_wrt dac_wrt_o
  dac_dat dac_dat_o
}


# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_trig_record {
  DIN_WIDTH 256 DIN_FROM 3 DIN_TO 3 DOUT_WIDTH 1
} {
  Din cfg_0/cfg_data
}


# Create axis_packetizer
cell pavel-demin:user:axis_circular_packetizer:1.0 pktzr_0 {
  AXIS_TDATA_WIDTH 32
  CNTR_WIDTH 21
  CONTINUOUS FALSE
  NON_BLOCKING TRUE
} {
  s_AXIS bcast_ADC/M00_AXIS
  cfg_data slice_record_length/Dout
  trigger slice_trig_record/Dout
  aclk ps_0/FCLK_CLK0
  aresetn slice_pktzr_reset/Dout
}



# Create axis_dwidth_converter
cell xilinx.com:ip:axis_dwidth_converter:1.1 conv_0 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 4
  M_TDATA_NUM_BYTES 8
} {
  S_AXIS pktzr_0/M_AXIS
  aclk ps_0/FCLK_CLK0
  aresetn slice_write_enable/Dout
}

# Create xlconstant
cell xilinx.com:ip:xlconstant:1.1 const_2 {
  CONST_WIDTH 32
  CONST_VAL 268435456
}

# Create axis_ram_writer
cell pavel-demin:user:axis_ram_writer:1.0 writer_0 {
  ADDR_WIDTH 25
} {
  S_AXIS conv_0/M_AXIS
  M_AXI ps_0/S_AXI_HP0
  cfg_data const_2/dout
  aclk ps_0/FCLK_CLK0
  aresetn slice_write_enable/Dout
}

assign_bd_address [get_bd_addr_segs ps_0/S_AXI_HP0/HP0_DDR_LOWOCM]

# Create axis_snapshot
cell pavel-demin:user:axis_snapshot:1.0 snap_phase {
  AXIS_TDATA_WIDTH 32
} {
  S_AXIS dds_0/M_AXIS_PHASE
  aclk ps_0/FCLK_CLK0
  aresetn slice_trig_record/Dout
}


# create filter
module filter_xyf {
  source projects/filter_test/filter_xyf.tcl
} {
  s_axis mult_0/M_AXIS_DOUT
  s_axis_f  bcast_f/M01_AXIS
  cfg cfg_0/cfg_data
  aclk ps_0/FCLK_CLK0
  aresetn rst_0/peripheral_aresetn
}



# Create axis_data_fifo
cell xilinx.com:ip:axis_data_fifo:1.1 fifo_xyf {
  FIFO_DEPTH 16384
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 12
} {
  s_axis  filter_xyf/m_axis
  s_axis_aclk ps_0/FCLK_CLK0
  s_axis_aresetn rst_0/peripheral_aresetn
}

# Create axis_dwidth_converter
cell xilinx.com:ip:axis_dwidth_converter:1.1 conv_xyf {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 4
  M_TDATA_NUM_BYTES 8
} {
  S_AXIS fifo_xyf/M_AXIS
  aclk ps_0/FCLK_CLK0
  aresetn rst_0/peripheral_aresetn
}


# Create axi_axis_reader
cell pavel-demin:user:axi_axis_reader:1.0 reader_xyf {
  AXI_DATA_WIDTH 32
} {
  S_AXIS conv_xyf/M_AXIS
  aclk ps_0/FCLK_CLK0
  aresetn rst_0/peripheral_aresetn
}

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Master /ps_0/M_AXI_GP0
  Clk Auto
} [get_bd_intf_pins reader_xyf/S_AXI]

set_property RANGE 8K [get_bd_addr_segs ps_0/Data/SEG_reader_xyf_reg0]
set_property OFFSET 0x40004000 [get_bd_addr_segs ps_0/Data/SEG_reader_xyf_reg0]


# Create axis_value
cell pavel-demin:user:axis_value:1.0 value_xy {
  AXIS_TDATA_WIDTH 96
} {
  
  aclk ps_0/FCLK_CLK0
  aresetn rst_0/peripheral_aresetn
}


# Create xlconcat
cell xilinx.com:ip:xlconcat:2.1 concat_status {
  NUM_PORTS 5
  IN0_WIDTH 32
  IN1_WIDTH 32
  IN2_WIDTH 32
  IN3_WIDTH 96
  IN4_WIDTH 32
} {
  In0 writer_0/sts_data
  In1 pktzr_0/trigger_pos
  In2 snap_phase/data
  In3 value_xy/data
  In4 fifo_xyf/axis_data_count
}

# Create axi_sts_register
cell pavel-demin:user:axi_sts_register:1.0 sts_0 {
  STS_DATA_WIDTH 256
  AXI_ADDR_WIDTH 32
  AXI_DATA_WIDTH 32
} {
  sts_data concat_status/dout
}


# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Master /ps_0/M_AXI_GP0
  Clk Auto
} [get_bd_intf_pins sts_0/S_AXI]


set_property RANGE 4K [get_bd_addr_segs ps_0/Data/SEG_sts_0_reg0]
set_property OFFSET 0x40001000 [get_bd_addr_segs ps_0/Data/SEG_sts_0_reg0]

