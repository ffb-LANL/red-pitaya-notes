#lockin_sweep 103

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
  CLKOUT2_REQUESTED_PHASE 157.5
  CLKOUT3_USED true
  CLKOUT3_REQUESTED_OUT_FREQ 250.0
  CLKOUT3_REQUESTED_PHASE 202.5
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
  dcm_locked pll_0/locked
  slowest_sync_clk pll_0/clk_out1
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


# Create axi_hub
cell pavel-demin:user:axi_hub hub_0 {
  CFG_DATA_WIDTH 256
  STS_DATA_WIDTH 512
} {
  S_AXI ps_0/M_AXI_GP0
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}


# Create xlslice
cell xilinx.com:ip:xlslice slice_1 {
  DIN_WIDTH 256 DIN_FROM 129 DIN_TO 128 
} {
  Din hub_0/cfg_data
}

# Create xlslice
cell xilinx.com:ip:xlslice slice_trx_reset {
  DIN_WIDTH 256 DIN_FROM 4 DIN_TO 4
} {
  Din hub_0/cfg_data
}


# Create xlconcat
cell xilinx.com:ip:xlconcat concat_0 {
  IN1_WIDTH 2
} {
  In0 slice_0/Dout
  In1 slice_1/Dout
  dout led_o
}

# Create xlconstant
cell xilinx.com:ip:xlconstant const_1

# Create axis_subset_converter
cell xilinx.com:ip:axis_subset_converter subset_ADC_A {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  M_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 4
  M_TDATA_NUM_BYTES 2
  TDATA_REMAP {tdata[15:0]}
} {
 s_axis adc_0/M_AXIS
  aclk pll_0/clk_out1
  aresetn slice_trx_reset/dout
}


# Create axis_fifo
cell pavel-demin:user:axis_fifo fifo_f {
  S_AXIS_TDATA_WIDTH 32
  M_AXIS_TDATA_WIDTH 32
  WRITE_DEPTH 16384
  ALWAYS_READY FALSE
} {
  S_AXIS hub_0/M00_AXIS
  aclk /pll_0/clk_out1
  aresetn slice_trx_reset/dout
}

# Create xlslice
cell xilinx.com:ip:xlslice slice_decimate {
  DIN_WIDTH 256 DIN_FROM 127 DIN_TO 96
} {
  Din hub_0/cfg_data
}

# Create xlconcat
cell xilinx.com:ip:xlconcat concat_interpol {
 IN0_WIDTH 13
 IN1_WIDTH 19
} {

  In1 slice_decimate/Dout

}


# Create axis_interpolator
cell pavel-demin:user:axis_interpolator inter_f {
  AXIS_TDATA_WIDTH 32
  CNTR_WIDTH 32
} {
  S_AXIS fifo_f/M_AXIS
  cfg_data concat_interpol/Dout
  aclk pll_0/clk_out1
  aresetn slice_trx_reset/dout
}


# Create axis_broadcaster
cell xilinx.com:ip:axis_broadcaster bcast_f {
  S_TDATA_NUM_BYTES 4
  M_TDATA_NUM_BYTES 4
 } {
  S_AXIS inter_f/m_axis
  aclk pll_0/clk_out1
  aresetn slice_trx_reset/dout
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
  HAS_PHASE_OUT false
  HAS_ARESETn true
} {
  S_AXIS_PHASE bcast_f/M00_AXIS
  aclk pll_0/clk_out1
  aresetn slice_trx_reset/dout
}

# Create axis_broadcaster
cell xilinx.com:ip:axis_broadcaster bcast_DDS {
  S_TDATA_NUM_BYTES 4
  M_TDATA_NUM_BYTES 4
 } {
  S_AXIS dds_0/M_AXIS_DATA
  aclk pll_0/clk_out1
  aresetn slice_trx_reset/dout
}

# Create axis_lfsr
cell pavel-demin:user:axis_lfsr lfsr_0 {} {
  aclk pll_0/clk_out1
  aresetn slice_trx_reset/dout
}

# Create xlslice
cell xilinx.com:ip:xlslice slice_dds_delay {
  DIN_WIDTH 256 DIN_FROM 255 DIN_TO 224
} {
  Din hub_0/cfg_data
}

# create delay
cell pavel-demin:user:axis_fixed_delay delay_dds { 
 DEPTH 17
} {
  s_axis bcast_DDS/M01_AXIS
  aclk pll_0/clk_out1
}

# Create cmpy
cell xilinx.com:ip:cmpy mult_0 {
  FLOWCONTROL Blocking
  APORTWIDTH.VALUE_SRC USER
  BPORTWIDTH.VALUE_SRC USER
  APORTWIDTH 14
  BPORTWIDTH 14
  ROUNDMODE Random_Rounding
  OUTPUTWIDTH 28
  aresetn true
} {
  S_AXIS_A subset_ADC_A/M_AXIS
  s_axis_b delay_dds/M_AXIS
  S_AXIS_CTRL lfsr_0/M_AXIS
  aclk pll_0/clk_out1
  aresetn slice_trx_reset/dout
}

# Create xlslice
cell xilinx.com:ip:xlslice scale_factor {
  DIN_WIDTH 256 DIN_FROM 159 DIN_TO 144
} {
  Din hub_0/cfg_data
}


# Create axis_scaler
cell pavel-demin:user:axis_scaler scaler {
  AXIS_TDATA_WIDTH 14
} {
  S_AXIS bcast_DDS/M00_AXIS
  cfg_data scale_factor/Dout
  aclk pll_0/clk_out1
  aresetn slice_trx_reset/dout
}


# Create axis_red_pitaya_dac
cell pavel-demin:user:axis_red_pitaya_dac dac_0 {} {
  aclk pll_0/clk_out1
  ddr_clk pll_0/clk_out2
  wrt_clk pll_0/clk_out3
  locked pll_0/locked
  S_AXIS scaler/M_AXIS
  dac_clk dac_clk_o
  dac_rst dac_rst_o
  dac_sel dac_sel_o
  dac_wrt dac_wrt_o
  dac_dat dac_dat_o
}

# create filter
module filter_xy {
  source projects/low_pass/filter_xy.tcl
} {
  s_axis mult_0/M_AXIS_DOUT
  cfg hub_0/cfg_data
  aclk pll_0/clk_out1
  aresetn slice_trx_reset/dout
}

# create delay
cell pavel-demin:user:axis_fixed_delay delay_f { 
 DEPTH 16
} {
  s_axis bcast_f/M01_AXIS
  aclk pll_0/clk_out1
}

# Create axis_decimator
cell pavel-demin:user:axis_decimator dcmtr_f {
  AXIS_TDATA_WIDTH 32
  CNTR_WIDTH 32
} {
  S_AXIS delay_f/M_AXIS
  cfg_data concat_interpol/Dout
  aclk pll_0/clk_out1
  aresetn slice_trx_reset/dout
}

# Create axis_fifo
cell pavel-demin:user:axis_fifo fifo_x {
  S_AXIS_TDATA_WIDTH 32
  M_AXIS_TDATA_WIDTH 32
  WRITE_DEPTH 16384
  ALWAYS_READY FALSE
} {
  S_AXIS filter_xy/M_AXIS_x
  aclk pll_0/clk_out1
  aresetn slice_trx_reset/dout
  M_AXIS hub_0/S00_AXIS
}

# Create axis_fifo
cell pavel-demin:user:axis_fifo fifo_y {
  S_AXIS_TDATA_WIDTH 32
  M_AXIS_TDATA_WIDTH 32
  WRITE_DEPTH 16384
  ALWAYS_READY FALSE
} {
  S_AXIS filter_xy/M_AXIS_y
  aclk pll_0/clk_out1
  aresetn slice_trx_reset/dout
  M_AXIS hub_0/S01_AXIS
}

# Create axis_fifo
cell pavel-demin:user:axis_fifo fifo_fout {
  S_AXIS_TDATA_WIDTH 32
  M_AXIS_TDATA_WIDTH 32
  WRITE_DEPTH 16384
  ALWAYS_READY FALSE
} {
  S_AXIS dcmtr_f/M_AXIS
  aclk pll_0/clk_out1
  aresetn slice_trx_reset/dout
  M_AXIS hub_0/S02_AXIS
}


# Create xlconstant
cell xilinx.com:ip:xlconstant const_lockin_sweep_ID {
  CONST_WIDTH 16
  CONST_VAL 103
}

# Create xlconcat
cell xilinx.com:ip:xlconcat concat_status {
  NUM_PORTS 9
  IN0_WIDTH 32
  IN1_WIDTH 32
  IN2_WIDTH 16
  IN3_WIDTH 16
  IN4_WIDTH 96
  IN5_WIDTH 32
  IN6_WIDTH 32
  IN7_WIDTH 32
  IN8_WIDTH 32
} {
  IN3 const_lockin_sweep_ID/dout
  In5 fifo_x/read_count
  In6 fifo_f/write_count
  In7 fifo_y/read_count
  In8 fifo_fout/read_count
  dout hub_0/sts_data
}


