#level_trigger 112


# Create clk_wiz
cell xilinx.com:ip:clk_wiz pll_0 {
  PRIMITIVE PLL
  PRIM_IN_FREQ.VALUE_SRC USER
  PRIM_IN_FREQ 125.0
  PRIM_SOURCE Differential_clock_capable_pin
  CLKOUT1_USED true
  CLKOUT1_REQUESTED_OUT_FREQ 125.0
  CLKOUT2_USED true
  CLKOUT2_REQUESTED_OUT_FREQ 250.0
  CLKOUT2_REQUESTED_PHASE -90.0
  USE_RESET false
} {
  clk_in1_p adc_clk_p_i
  clk_in1_n adc_clk_n_i
}

 
# Create processing_system7
cell xilinx.com:ip:processing_system7 ps_0 {
  PCW_IMPORT_BOARD_PRESET cfg/red_pitaya.xml
  PCW_USE_S_AXI_HP0 1
} {
  M_AXI_GP0_ACLK pll_0/clk_out1
  S_AXI_HP0_ACLK pll_0/clk_out1
}

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {
  make_external {FIXED_IO, DDR}
  Master Disable
  Slave Disable
} [get_bd_cells ps_0]

# Create xlconstant
cell xilinx.com:ip:xlconstant const_0

# Create proc_sys_reset
cell xilinx.com:ip:proc_sys_reset rst_0 {} {
  ext_reset_in const_0/dout
}

# Create axis_red_pitaya_adc
cell pavel-demin:user:axis_red_pitaya_adc adc_0 {} {
  aclk pll_0/clk_out1
  adc_dat_a adc_dat_a_i
  adc_dat_b adc_dat_b_i
  adc_csn adc_csn_o
}

# Create c_counter_binary
cell xilinx.com:ip:c_counter_binary cntr_0 {
  Output_Width 32
} {
  CLK pll_0/clk_out1
}

# Create xlslice
cell xilinx.com:ip:xlslice slice_0 {
  DIN_WIDTH 32 DIN_FROM 25 DIN_TO 25 DOUT_WIDTH 1
} {
  Din cntr_0/Q
 }


# Create axi_cfg_register
cell pavel-demin:user:axi_cfg_register cfg_0 {
  CFG_DATA_WIDTH 384
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
cell xilinx.com:ip:xlslice slice_1 {
  DIN_WIDTH 384 DIN_FROM 134 DIN_TO 128 DOUT_WIDTH 7
} {
  Din cfg_0/cfg_data
}

# Create xlconcat
cell xilinx.com:ip:xlconcat concat_0 {
  IN1_WIDTH 7
} {
  In0 slice_0/Dout
  In1 slice_1/Dout
  dout led_o
}


# Create xlslice
cell xilinx.com:ip:xlslice slice_pktzr_reset {
  DIN_WIDTH 384 DIN_FROM 0 DIN_TO 0
} {
  Din cfg_0/cfg_data
}

# Create xlslice
cell xilinx.com:ip:xlslice slice_write_enable {
  DIN_WIDTH 384 DIN_FROM 1 DIN_TO 1
} {
  Din cfg_0/cfg_data
}


# Create xlslice
cell xilinx.com:ip:xlslice slice_record_length {
  DIN_WIDTH 384 DIN_FROM 63 DIN_TO 32 DOUT_WIDTH 32
} {
  Din cfg_0/cfg_data
}

# Create xlslice
cell xilinx.com:ip:xlslice slice_trig_record {
  DIN_WIDTH 384 DIN_FROM 3 DIN_TO 3
} {
  Din cfg_0/cfg_data
}

# Create xlconstant
cell xilinx.com:ip:xlconstant const_1

# Create xlslice
cell xilinx.com:ip:xlslice slice_frequency {
  DIN_WIDTH 384 DIN_FROM 95 DIN_TO 64
} {
  Din cfg_0/cfg_data
}

# Create axis_constant
cell pavel-demin:user:axis_constant phase_0 {
  AXIS_TDATA_WIDTH 32
} {
  cfg_data slice_frequency/Dout
  aclk pll_0/clk_out1
}

# Create xlconstant
cell xilinx.com:ip:xlconstant const_modulus {
  CONST_WIDTH 32
  CONST_VAL 0
}

# Create dds_compiler
cell xilinx.com:ip:dds_compiler dds_0 {
  DDS_CLOCK_RATE 125
  parameter_entry Hardware_Parameters
  OUTPUT_WIDTH 14
  PHASE_WIDTH 32
  PHASE_INCREMENT Streaming
  DSP48_USE Maximal
  HAS_TREADY true
  Has_ARESETn false
  Has_Phase_Out false
} {
  S_AXIS_PHASE phase_0/M_AXIS
  aclk pll_0/clk_out1
}

#  M02_TDATA_REMAP tdata[95:64]

# Create axis_broadcaster
cell xilinx.com:ip:axis_broadcaster bcast_ADC {
  NUM_MI 2
  S_TDATA_NUM_BYTES 4
  M_TDATA_NUM_BYTES 4
 } {
  S_AXIS  adc_0/M_AXIS
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create xlslice
cell xilinx.com:ip:xlslice slice_trigger_level {
  DIN_WIDTH 384 DIN_FROM 367 DIN_TO 352
} {
  Din cfg_0/cfg_data
}

# Create xlslice
cell xilinx.com:ip:xlslice slice_switch_direction {
  DIN_WIDTH 384 DIN_FROM 7 DIN_TO 7
} {
  Din cfg_0/cfg_data
}

# Create axis_level_cross
cell pavel-demin:user:axis_level_cross level_cross {
  AXIS_TDATA_WIDTH 16
} {
  S_AXIS bcast_ADC/M01_AXIS
  level slice_trigger_level/Dout
  direction slice_switch_direction/Dout
  aclk pll_0/clk_out1
  aresetn slice_pktzr_reset/Dout
}

# Create xlslice
cell xilinx.com:ip:xlslice slice_delay {
  DIN_WIDTH 384 DIN_FROM 351 DIN_TO 320
} {
  Din cfg_0/cfg_data
}

# Create not gate
cell xilinx.com:ip:util_vector_logic comb_trigger {
  C_SIZE 1
  C_OPERATION or
} {
  op1 level_cross/state_out
  op2 slice_trig_record/Dout
}



# Create gpio_trigger
cell pavel-demin:user:gpio_delayed_trigger trigger_0 {
	GPIO_DATA_WIDTH 8
        GPIO_INPUT_WIDTH 2	
} {
  gpio_data exp_p_tri_io
  soft_trig comb_trigger/Res
  out_data comb_trigger/Res
  delay slice_delay/Dout
  aclk pll_0/clk_out1
  aresetn slice_pktzr_reset/Dout
}

# Create axis_packetizer_phase
cell pavel-demin:user:axis_packetizer_phase pktzr_0 {
  AXIS_TDATA_WIDTH 32
  AXIS_TDATA_PHASE_WIDTH 32
  CNTR_WIDTH 26
  CONTINUOUS FALSE
  NON_BLOCKING TRUE
} {
  S_AXIS bcast_ADC/M00_AXIS
  cfg_data slice_record_length/Dout
  trigger trigger_0/instant_trigger
  aclk pll_0/clk_out1
  aresetn slice_pktzr_reset/Dout
}



# Create axis_dwidth_converter
cell xilinx.com:ip:axis_dwidth_converter conv_0 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 4
  M_TDATA_NUM_BYTES 8
} {
  S_AXIS pktzr_0/M_AXIS
  aclk pll_0/clk_out1
  aresetn slice_write_enable/Dout
}

# Create xlconstant
cell xilinx.com:ip:xlconstant const_2 {
  CONST_WIDTH 32
  CONST_VAL 268435456
}

# Create axis_ram_writer
cell pavel-demin:user:axis_ram_writer writer_0 {
  ADDR_WIDTH 25
} {
  S_AXIS conv_0/M_AXIS
  M_AXI ps_0/S_AXI_HP0
  m_axi_awready  ps_0/S_AXI_HP0_AWREADY
  m_axi_wready ps_0/S_AXI_HP0_WREADY
  cfg_data const_2/dout
  aclk pll_0/clk_out1
  aresetn slice_write_enable/Dout
}

assign_bd_address [get_bd_addr_segs ps_0/S_AXI_HP0/HP0_DDR_LOWOCM]

# Create axis_red_pitaya_dac
cell pavel-demin:user:axis_red_pitaya_dac dac_0 {} {
  aclk pll_0/clk_out1
  ddr_clk pll_0/clk_out2
  locked pll_0/locked
  S_AXIS dds_0/M_AXIS_DATA
  dac_clk dac_clk_o
  dac_rst dac_rst_o
  dac_sel dac_sel_o
  dac_wrt dac_wrt_o
  dac_dat dac_dat_o
}



# Create xlconstant
cell xilinx.com:ip:xlconstant const_ID {
  CONST_WIDTH 16
  CONST_VAL 112
}

# Create xlconcat
cell xilinx.com:ip:xlconcat concat_sts {
  NUM_PORTS 11
  IN0_WIDTH 32
  IN1_WIDTH 32
  IN2_WIDTH 1
  IN3_WIDTH 1
  IN4_WIDTH 1
  IN5_WIDTH 1
  IN6_WIDTH 12
  IN7_WIDTH 16
  IN8_WIDTH 32
  IN9_WIDTH 128
  IN10_WIDTH 32 
} {
  In0 writer_0/sts_data
  In1 pktzr_0/trigger_pos
  In2 trigger_0/trigger
  In3 pktzr_0/complete
  In4 ps_0/S_AXI_HP0_AWREADY
  In5 ps_0/S_AXI_HP0_WREADY
  In7 const_ID/dout
  In8 pktzr_0/phase
  In10 const_modulus/dout
}

# Create axi_sts_register
cell pavel-demin:user:axi_sts_register sts_0 {
  STS_DATA_WIDTH 288
  AXI_ADDR_WIDTH 32
  AXI_DATA_WIDTH 32
} {
  sts_data concat_sts/dout
}

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Master /ps_0/M_AXI_GP0
  Clk Auto
} [get_bd_intf_pins sts_0/S_AXI]

set_property RANGE 4K [get_bd_addr_segs ps_0/Data/SEG_sts_0_reg0]
set_property OFFSET 0x40001000 [get_bd_addr_segs ps_0/Data/SEG_sts_0_reg0]

