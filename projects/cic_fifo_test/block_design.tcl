#lockin_sweep

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


# Create axi_axis_writer
cell pavel-demin:user:axi_axis_writer:1.0 writer_f {
  AXI_DATA_WIDTH 32
} {
  aclk /ps_0/FCLK_CLK0
  aresetn /rst_0/peripheral_aresetn
}

# Create axis_data_fifo
cell xilinx.com:ip:axis_data_fifo:1.1 fifo_f {
  FIFO_DEPTH 16384
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 4
} {
  s_axis  writer_f/m_axis
  s_axis_aclk ps_0/FCLK_CLK0
  s_axis_aresetn rst_0/peripheral_aresetn
}

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_decimate {
  DIN_WIDTH 256 DIN_FROM 127 DIN_TO 96
} {
  Din cfg_0/cfg_data
}

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_trx_reset {
  DIN_WIDTH 256 DIN_FROM 4 DIN_TO 4
} {
  Din cfg_0/cfg_data
}

# Create logic
cell xilinx.com:ip:util_vector_logic:2.0 logic_0 {
  C_SIZE 1
  C_OPERATION not
} {
 Op1 slice_trx_reset/dout 
} 

# Create xlconcat
cell xilinx.com:ip:xlconcat:2.1 concat_interpol {
 IN0_WIDTH 13
 IN1_WIDTH 19
} {

  In1 slice_decimate/Dout

}

# Create axis_interpolator
cell pavel-demin:user:axis_interpolator:1.0 inter_f {
  AXIS_TDATA_WIDTH 32
  CNTR_WIDTH 32
} {
  S_AXIS fifo_f/M_AXIS
  cfg_data concat_interpol/Dout
  aclk ps_0/FCLK_CLK0
  aresetn rst_0/peripheral_aresetn
}

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Master /ps_0/M_AXI_GP0
  Clk Auto
} [get_bd_intf_pins writer_f/S_AXI]

set_property RANGE 16K [get_bd_addr_segs ps_0/Data/SEG_writer_f_reg0]
set_property OFFSET 0x40020000 [get_bd_addr_segs ps_0/Data/SEG_writer_f_reg0]


# Create dds_compiler
cell xilinx.com:ip:dds_compiler:6.0 dds_0 {
  DDS_CLOCK_RATE 125
  parameter_entry Hardware_Parameters
  OUTPUT_WIDTH 14
  PHASE_WIDTH 32 
 PHASE_INCREMENT Streaming
  DSP48_USE Maximal
  HAS_TREADY true
  HAS_PHASE_OUT false
} {
  S_AXIS_PHASE inter_f/m_axis
  aclk ps_0/FCLK_CLK0
}

# Create clk_wiz
cell xilinx.com:ip:clk_wiz:5.2 pll_0 {
  PRIM_IN_FREQ.VALUE_SRC USER
  PRIM_IN_FREQ 125.0
  CLKOUT1_USED true
  CLKOUT1_REQUESTED_OUT_FREQ 250.0
} {
  clk_in1 adc_0/adc_clk
}

# Create dac_clock_converter
cell xilinx.com:ip:axis_clock_converter:1.1 fifo_dac {
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 4
} {
  S_AXIS dds_0/M_AXIS_DATA
  s_axis_aclk ps_0/FCLK_CLK0
  s_axis_aresetn rst_0/peripheral_aresetn
  m_axis_aclk adc_0/adc_clk
  m_axis_aresetn const_1/dout
}


# Create axis_red_pitaya_dac
cell pavel-demin:user:axis_red_pitaya_dac:1.0 dac_0 {} {
  aclk adc_0/adc_clk
  ddr_clk pll_0/clk_out1
  locked pll_0/locked
  S_AXIS fifo_dac/M_AXIS
  dac_clk dac_clk_o
  dac_rst dac_rst_o
  dac_sel dac_sel_o
  dac_wrt dac_wrt_o
  dac_dat dac_dat_o
}

# Create axis_broadcaster
cell xilinx.com:ip:axis_broadcaster:1.1 bcast_ADC {
  S_TDATA_NUM_BYTES 2
  M_TDATA_NUM_BYTES 2
 } {
  S_AXIS fifo_ADC/M_AXIS
  aclk ps_0/FCLK_CLK0
  aresetn rst_0/peripheral_aresetn
}

# Create xlconstant
cell xilinx.com:ip:xlconstant:1.1 const_record_length {
  CONST_WIDTH 32
  CONST_VAL 16777216
}

# Create axis_packetizer
cell pavel-demin:user:axis_circular_packetizer:1.0 pktzr_0 {
  AXIS_TDATA_WIDTH 16
  CNTR_WIDTH 26
  CONTINUOUS FALSE
  NON_BLOCKING TRUE
} {
  s_AXIS bcast_ADC/M00_AXIS
  cfg_data const_record_length/Dout
  trigger logic_0/res
  aclk ps_0/FCLK_CLK0
  aresetn slice_trx_reset/dout
}

# Create axis_dwidth_converter
cell xilinx.com:ip:axis_dwidth_converter:1.1 conv_0 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 2
  M_TDATA_NUM_BYTES 8
} {
  S_AXIS pktzr_0/M_AXIS
  aclk ps_0/FCLK_CLK0
  aresetn slice_trx_reset/dout
}

# Create xlconstant
cell xilinx.com:ip:xlconstant:1.1 const_ram_start {
  CONST_WIDTH 32
  CONST_VAL 268435456
}

# Create axis_ram_writer
cell pavel-demin:user:axis_ram_writer:1.0 writer_0 {
  ADDR_WIDTH 25
} {
  S_AXIS conv_0/M_AXIS
  M_AXI ps_0/S_AXI_HP0
  cfg_data const_ram_start/dout
  aclk ps_0/FCLK_CLK0
  aresetn slice_trx_reset/dout
}

assign_bd_address [get_bd_addr_segs ps_0/S_AXI_HP0/HP0_DDR_LOWOCM]

# Create cic_compiler
cell xilinx.com:ip:cic_compiler:4.0 cic_filter_x {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 3
  FIXED_OR_INITIAL_RATE 8192
  INPUT_SAMPLE_FREQUENCY 125
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 14
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 32
  HAS_ARESETN true
  USE_XTREME_DSP_SLICE true
  HAS_DOUT_TREADY true
} {
  S_AXIS_DATA bcast_ADC/M01_AXIS
  aclk ps_0/FCLK_CLK0
  aresetn slice_trx_reset/dout
}




# Create fifo_generator
#cell xilinx.com:ip:fifo_generator:13.1 fifo_generator_0 {
#  PERFORMANCE_OPTIONS First_Word_Fall_Through
#  INPUT_DATA_WIDTH 32
#  INPUT_DEPTH 8192
#  OUTPUT_DATA_WIDTH 32
#  OUTPUT_DEPTH 8192
#  DATA_COUNT true
#  DATA_COUNT_WIDTH 14
#} {
#  clk ps_0/FCLK_CLK0
#  srst logic_0/res
#}

# Create axis_fifo
#cell pavel-demin:user:axis_fifo:1.0 fifo_xy {
#  S_AXIS_TDATA_WIDTH 32
#  M_AXIS_TDATA_WIDTH 32
#} {
#  S_AXIS cic_filter_x/M_AXIS_DATA
#  FIFO_READ fifo_generator_0/FIFO_READ
#  FIFO_WRITE fifo_generator_0/FIFO_WRITE
#  aclk ps_0/FCLK_CLK0
#}


# Create axis_data_fifo
cell xilinx.com:ip:axis_data_fifo:1.1 fifo_xy {
  FIFO_DEPTH 16384
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 4
} {
  s_axis  cic_filter_x/M_AXIS_DATA
  s_axis_aclk ps_0/FCLK_CLK0
  s_axis_aresetn slice_trx_reset/dout 
}


# Create axi_axis_reader
cell pavel-demin:user:axi_axis_reader:1.0 reader_xy {
  AXI_DATA_WIDTH 32
} {
  S_AXIS fifo_xy/M_AXIS
  aclk ps_0/FCLK_CLK0
  aresetn rst_0/peripheral_aresetn
}

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Master /ps_0/M_AXI_GP0
  Clk Auto
} [get_bd_intf_pins reader_xy/S_AXI]

set_property RANGE 16K [get_bd_addr_segs ps_0/Data/SEG_reader_xy_reg0]
set_property OFFSET 0x40010000 [get_bd_addr_segs ps_0/Data/SEG_reader_xy_reg0]

# Create xlconstant
cell xilinx.com:ip:xlconstant:1.1 const_ID {
  CONST_WIDTH 16
  CONST_VAL 19539
}

# Create xlconcat
cell xilinx.com:ip:xlconcat:2.1 concat_status {
  NUM_PORTS 7
  IN0_WIDTH 32
  IN1_WIDTH 32
  IN2_WIDTH 16
  IN3_WIDTH 16
  IN4_WIDTH 96
  IN5_WIDTH 32
  IN6_WIDTH 32
} {
  In0 writer_0/sts_data
  In1 pktzr_0/trigger_pos
  IN3 const_ID/dout
  In5 fifo_xy/axis_data_count
  In6 fifo_f/axis_data_count
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