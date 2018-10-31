#current-voltage 104

# Create clk_wiz
cell xilinx.com:ip:clk_wiz:6.0 pll_0 {
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
cell xilinx.com:ip:processing_system7:5.5 ps_0 {
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
cell xilinx.com:ip:xlconstant:1.1 const_0

# Create proc_sys_reset
cell xilinx.com:ip:proc_sys_reset:5.0 rst_0 {} {
  ext_reset_in const_0/dout
}

# Create axis_red_pitaya_adc
cell pavel-demin:user:axis_red_pitaya_adc:2.0 adc_0 {} {
  aclk pll_0/clk_out1
  adc_dat_a adc_dat_a_i
  adc_dat_b adc_dat_b_i
  adc_csn adc_csn_o
}

# Create c_counter_binary
cell xilinx.com:ip:c_counter_binary:12.0 cntr_0 {
  Output_Width 32
} {
  CLK pll_0/clk_out1
}

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_0 {
  DIN_WIDTH 32 DIN_FROM 28 DIN_TO 28 DOUT_WIDTH 1
} {
  Din cntr_0/Q
 }


# Create axi_cfg_register
cell pavel-demin:user:axi_cfg_register:1.0 cfg_0 {
  CFG_DATA_WIDTH 352
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
  DIN_WIDTH 352 DIN_FROM 134 DIN_TO 128 DOUT_WIDTH 7
} {
  Din cfg_0/cfg_data
}

# Create xlconcat
cell xilinx.com:ip:xlconcat:2.1 concat_0 {
  IN1_WIDTH 7
} {
  In0 slice_0/Dout
  In1 slice_1/Dout
  dout led_o
}


# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_pktzr_reset {
  DIN_WIDTH 352 DIN_FROM 0 DIN_TO 0
} {
  Din cfg_0/cfg_data
}

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_write_enable {
  DIN_WIDTH 352 DIN_FROM 1 DIN_TO 1
} {
  Din cfg_0/cfg_data
}


# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_record_length {
  DIN_WIDTH 352 DIN_FROM 63 DIN_TO 32 DOUT_WIDTH 32
} {
  Din cfg_0/cfg_data
}

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_trig_record {
  DIN_WIDTH 352 DIN_FROM 3 DIN_TO 3
} {
  Din cfg_0/cfg_data
}

# Create xlconstant
cell xilinx.com:ip:xlconstant:1.1 const_1

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_delay {
  DIN_WIDTH 352 DIN_FROM 351 DIN_TO 320
} {
  Din cfg_0/cfg_data
}

# Create gpio_trigger
cell pavel-demin:user:gpio_delayed_trigger:1.0 trigger_0 {
	GPIO_DATA_WIDTH 8
} {
  gpio_data exp_p_tri_io
  soft_trig slice_trig_record/Dout
  delay slice_delay/Dout
  aclk pll_0/clk_out1
  aresetn slice_pktzr_reset/Dout
}

# Create axis_broadcaster
cell xilinx.com:ip:axis_broadcaster:1.1 bcast_ADC {
  S_TDATA_NUM_BYTES 4
  M_TDATA_NUM_BYTES 4
 } {
  S_AXIS adc_0/M_AXIS
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}


# Create blk_mem_gen
cell xilinx.com:ip:blk_mem_gen:8.4 waveform_bram {
    MEMORY_TYPE True_Dual_Port_RAM
    USE_BRAM_BLOCK Stand_Alone
    WRITE_WIDTH_A 32
    WRITE_DEPTH_A 32768
    READ_WIDTH_B 16
    WRITE_WIDTH_B 16
    ENABLE_A Always_Enabled
    ENABLE_B Always_Enabled
    REGISTER_PORTB_OUTPUT_OF_MEMORY_PRIMITIVES false
   }
#   Load_Init_File {true}
#   Coe_File {D:/github/fp/projects/iv_test/BRAM.coe}


# Create axi_bram_writer
cell pavel-demin:user:axi_bram_writer:1.0 waveform_writer {
  AXI_DATA_WIDTH 32
  AXI_ADDR_WIDTH 32
  BRAM_DATA_WIDTH 32
  BRAM_ADDR_WIDTH 15
} {
  BRAM_PORTA waveform_bram/BRAM_PORTA
}

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Master /ps_0/M_AXI_GP0
  Clk Auto
} [get_bd_intf_pins waveform_writer/S_AXI]

set_property RANGE 256K [get_bd_addr_segs ps_0/Data/SEG_waveform_writer_reg0]
set_property OFFSET 0x40040000 [get_bd_addr_segs ps_0/Data/SEG_waveform_writer_reg0]


# Create logic
cell xilinx.com:ip:util_vector_logic:2.0 logic_0 {
  C_SIZE 1
  C_OPERATION and
} {
 Op1 trigger_0/trigger
}

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_measure_pulse {
  DIN_WIDTH 352 DIN_FROM 319 DIN_TO 160
} {
  Din cfg_0/cfg_data
}

# Create axis_unblock
cell pavel-demin:user:axis_unblock:1.0 unblock {
} {
  s_axis bcast_ADC/m01_axis
  aclk pll_0/clk_out1
  aresetn logic_0/res
}



# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_decimate {
  DIN_WIDTH 256 DIN_FROM 127 DIN_TO 96
} {
  Din cfg_0/cfg_data
}

# Create axis_variable
cell pavel-demin:user:axis_variable:1.0 rate_0 {
  AXIS_TDATA_WIDTH 16
} {
  cfg_data slice_decimate/Dout
  aclk pll_0/clk_out1
  aresetn logic_0/res
}

# Create axis_broadcaster
cell xilinx.com:ip:axis_broadcaster:1.1 bcast_rate {
  S_TDATA_NUM_BYTES 2
  M_TDATA_NUM_BYTES 2
 } {
  S_AXIS rate_0/M_AXIS
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create cic_compiler
cell xilinx.com:ip:cic_compiler:4.0 cic_0 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 3
  SAMPLE_RATE_CHANGES Programmable
  MINIMUM_RATE 8
  MAXIMUM_RATE 6250
  FIXED_OR_INITIAL_RATE 64
  INPUT_SAMPLE_FREQUENCY 125
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 14
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 16
  HAS_ARESETN true
  USE_XTREME_DSP_SLICE true
} {
  S_AXIS_DATA unblock/m_axis
  S_AXIS_CONFIG bcast_rate/m01_axis
  aclk pll_0/clk_out1
  aresetn logic_0/res
}


# Create axis_measure_pulse
cell pavel-demin:user:axis_measure_pulse:1.0 measure_pulse {
    AXIS_TDATA_WIDTH 16
    BRAM_DATA_WIDTH 16
    BRAM_ADDR_WIDTH 16
} {
  cfg_data slice_measure_pulse/Dout
  s_axis cic_0/m_axis_data
  BRAM_PORTA waveform_bram/BRAM_PORTB
  aclk pll_0/clk_out1
  aresetn logic_0/res
}



# Create xlconstant
cell xilinx.com:ip:xlconstant:1.1 const_interpol {
  CONST_WIDTH 16
  CONST_VAL 64
}

# Create cic_compiler
cell xilinx.com:ip:cic_compiler:4.0 interpol  {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Interpolation
  NUMBER_OF_STAGES 3
  SAMPLE_RATE_CHANGES Programmable
  MINIMUM_RATE 8
  MAXIMUM_RATE 6250
  FIXED_OR_INITIAL_RATE 64
  INPUT_SAMPLE_FREQUENCY 15.625
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 16
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 16
  HAS_ARESETN true
  USE_XTREME_DSP_SLICE true
  HAS_DOUT_TREADY true
} {
  S_AXIS_DATA measure_pulse/M_AXIS
  S_AXIS_CONFIG bcast_rate/m00_axis
  aclk pll_0/clk_out1
  aresetn logic_0/res
}

# Create axis_constant
cell pavel-demin:user:axis_constant:1.0 measure_result_0 {
  AXIS_TDATA_WIDTH 32
} {
  cfg_data measure_pulse/sts_data
  aclk pll_0/clk_out1
}

# Create axis_combiner
cell  xilinx.com:ip:axis_combiner:1.1 comb_adc_result {
  NUM_SI 2
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 4
} {
  S00_AXIS bcast_ADC/m00_axis
  S01_AXIS measure_result_0/m_axis
  aclk pll_0/clk_out1
  aresetn  slice_pktzr_reset/Dout
  }

# Create axis_circular_packetizer
cell pavel-demin:user:axis_circular_packetizer:1.0 pktzr_0 {
  AXIS_TDATA_WIDTH 64
  CNTR_WIDTH 25
  CONTINUOUS FALSE
} {
  S_AXIS comb_adc_result/m_axis
  cfg_data slice_record_length/Dout
  trigger trigger_0/trigger
  enabled logic_0/Op2
  aclk pll_0/clk_out1
  aresetn slice_pktzr_reset/Dout
}



# Create axis_dwidth_converter
#cell xilinx.com:ip:axis_dwidth_converter:1.1 conv_0 {
#  S_TDATA_NUM_BYTES.VALUE_SRC USER
#  S_TDATA_NUM_BYTES 4
#  M_TDATA_NUM_BYTES 8
#} {
#  S_AXIS pktzr_0/M_AXIS
#  aclk pll_0/clk_out1
#  aresetn slice_write_enable/Dout
#}

# Create xlconstant
cell xilinx.com:ip:xlconstant:1.1 const_2 {
  CONST_WIDTH 32
  CONST_VAL 268435456
}

# Create axis_ram_writer
cell pavel-demin:user:axis_ram_writer:1.0 writer_0 {
  ADDR_WIDTH 25
} {
  S_AXIS pktzr_0/M_AXIS
  M_AXI ps_0/S_AXI_HP0
  cfg_data const_2/dout
  aclk pll_0/clk_out1
  aresetn slice_write_enable/Dout
}

assign_bd_address [get_bd_addr_segs ps_0/S_AXI_HP0/HP0_DDR_LOWOCM]

# Create axis_zeroer
cell pavel-demin:user:axis_zeroer:1.0 zeroer_DAC {
  AXIS_TDATA_WIDTH 32
} {
  S_AXIS interpol/m_axis_data
  aclk pll_0/clk_out1
}

# Create axis_red_pitaya_dac
cell pavel-demin:user:axis_red_pitaya_dac:1.0 dac_0 {} {
  aclk pll_0/clk_out1
  ddr_clk pll_0/clk_out2
  locked pll_0/locked
  S_AXIS zeroer_DAC/M_AXIS
  dac_clk dac_clk_o
  dac_rst dac_rst_o
  dac_sel dac_sel_o
  dac_wrt dac_wrt_o
  dac_dat dac_dat_o
}


# Create xlconstant
cell xilinx.com:ip:xlconstant:1.1 const_ID {
  CONST_WIDTH 16
  CONST_VAL 104
}


# Create xlconcat
cell xilinx.com:ip:xlconcat:2.1 concat_sts {
  NUM_PORTS 11
  IN0_WIDTH 32
  IN1_WIDTH 32
  IN2_WIDTH 1
  IN3_WIDTH 1
  IN4_WIDTH 1
  IN5_WIDTH 1
  IN6_WIDTH 3
  IN7_WIDTH 1
  IN8_WIDTH 8
  IN9_WIDTH 16
  IN10_WIDTH 32
} {
  In0 writer_0/sts_data
  In1 pktzr_0/trigger_pos
  In2 trigger_0/trigger
  In3 pktzr_0/complete 
  In4 measure_pulse/overload
  In5 pktzr_0/enabled 
  In6 measure_pulse/case_id
  In7 logic_0/res
  In9 const_ID/dout
  In10 measure_pulse/sts_data
}

# Create axi_sts_register
cell pavel-demin:user:axi_sts_register:1.0 sts_0 {
  STS_DATA_WIDTH 128
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
