#digitizer_4adc 158

# Create clk_buf
cell xilinx.com:ip:util_ds_buf i_clk_01 {
  CONFIG.FREQ_HZ 125000000
} {
  ibuf_ds_p  adc_clk_p_i
  ibuf_ds_n  adc_clk_n_i
}


# Create clk_wiz
cell xilinx.com:ip:clk_wiz pll_0 {
  PRIMITIVE PLL
  PRIM_IN_FREQ.VALUE_SRC USER
  PRIM_IN_FREQ 125.0
  PRIM_SOURCE Global_buffer
  CLKOUT1_USED true
  CLKOUT1_REQUESTED_OUT_FREQ 125.0
  CLKOUT2_USED true
  CLKOUT2_REQUESTED_OUT_FREQ 200.0
  USE_RESET false
} {
     clk_in1 i_clk_01/IBUF_OUT
}

# Create clk_buf
cell xilinx.com:ip:util_ds_buf i_clk_23 {} {
  ibuf_ds_p  adc_clk_p_i2
  ibuf_ds_n  adc_clk_n_i2
}


cell xilinx.com:ip:clk_wiz pll_1 {
  PRIMITIVE PLL
  PRIM_IN_FREQ.VALUE_SRC USER
  PRIM_IN_FREQ 125.0
  PRIM_SOURCE Global_buffer
  CLKOUT1_USED true
  CLKOUT1_REQUESTED_OUT_FREQ 125.0
  USE_RESET false
} {
     clk_in1 i_clk_23/IBUF_OUT
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


# Create axis_gpio_reader
cell pavel-demin:user:axis_gpio_reader_writer gpio_0 {
  AXIS_TDATA_WIDTH 8
  GPIO_IN_DATA_WIDTH 1
  GPIO_OUT_DATA_WIDTH 1
} {
  gpio_data_in exp_p_tri_io
  gpio_data_out exp_n_tri_io
  aclk pll_0/clk_out1
}

# Create axi_hub
cell pavel-demin:user:axi_hub hub_0 {
  CFG_DATA_WIDTH 448
  STS_DATA_WIDTH 320
} {
  S_AXI ps_0/M_AXI_GP0
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create port_slicer
cell pavel-demin:user:port_slicer writer_reset_slice {
  DIN_WIDTH 448 DIN_FROM 0 DIN_TO 0
} {
  din hub_0/cfg_data
}


# Create port_slicer
cell pavel-demin:user:port_slicer run_slice {
  DIN_WIDTH 448 DIN_FROM 1 DIN_TO 1
} {
  din hub_0/cfg_data
}

# Create xlslice
cell pavel-demin:user:port_slicer slice_trig_record {
  DIN_WIDTH 448 DIN_FROM 3 DIN_TO 3
} {
   din hub_0/cfg_data
}

# Create port_slicer
cell pavel-demin:user:port_slicer slice_idly_rst {
  DIN_WIDTH 192 DIN_FROM 4 DIN_TO 4
} {
  din hub_0/cfg_data
}


cell xilinx.com:ip:xlconstant trig_polarity_slice {
  CONST_WIDTH 1
  CONST_VAL 0
}

# Create xlconstant
cell xilinx.com:ip:xlconstant trig_mask_slice {
  CONST_WIDTH 16
  CONST_VAL 1
}

cell xilinx.com:ip:xlconstant trig_level_slice {
  CONST_WIDTH 16
  CONST_VAL 1
}

# Create port_slicer
cell pavel-demin:user:port_slicer pre_data_slice {
  DIN_WIDTH 448 DIN_FROM 447 DIN_TO 416
} {
  din hub_0/cfg_data
}

# Create port_slicer
cell pavel-demin:user:port_slicer tot_data_slice {
  DIN_WIDTH 448 DIN_FROM 63 DIN_TO 32
} {
  din hub_0/cfg_data
}

# Create axis_trigger
cell pavel-demin:user:axis_soft_trigger trig_0 {
  AXIS_TDATA_WIDTH 8
  AXIS_TDATA_SIGNED FALSE
} {
  S_AXIS gpio_0/M_AXIS
  trg_flag gpio_0/data
  pol_data trig_polarity_slice/dout
  msk_data trig_mask_slice/dout
  lvl_data trig_level_slice/dout
  soft_trigger slice_trig_record/dout
  aclk pll_0/clk_out1
}

# Create xlconstant
cell xilinx.com:ip:xlconstant const_1 {
  CONST_WIDTH 1
  CONST_VAL 1
}

# Create proc_sys_reset
cell xilinx.com:ip:proc_sys_reset rst_1 {} {
  ext_reset_in const_0/dout
  dcm_locked const_1/dout
  slowest_sync_clk ps_0/fclk_clk0
}

# Create spi_cfg_4adc 90 deg clock delay, normal format
cell pavel-demin:user:spi_cfg_4adc cfg_adc_0 {
   TIMING 16'b0101
   FORMAT 16'b000000
} {
  aclk ps_0/fclk_clk0
  aresetn rst_1/peripheral_aresetn
}

# Create spi_cfg_4adc
cell pavel-demin:user:spi_master spi_0 {
} {
  aclk ps_0/fclk_clk0
  aresetn rst_1/peripheral_aresetn
  spi_cs_o         spi_csa_o
  spi_cs_o         spi_csb_o
  spi_clk_o        spi_clk_o
  spi_mosi_o       spi_mosi_o
  spi_start_i      cfg_adc_0/spi_start_o   
  dat_wr_h_i       cfg_adc_0/spi_adr    
  dat_wr_l_i       cfg_adc_0/spi_dat     
  cfg_rw_i         cfg_adc_0/spi_rw     
  cfg_cs_act_i     cfg_adc_0/spi_cs_sel 
  cfg_h_lng_i      cfg_adc_0/spi_h_lng  
  cfg_l_lng_i      cfg_adc_0/spi_l_lng  
  cfg_clk_presc_i  cfg_adc_0/spi_clk_pre 
  cfg_clk_wr_edg_i cfg_adc_0/spi_wr_edg  
  cfg_clk_rd_edg_i cfg_adc_0/spi_rd_edg  
  cfg_clk_idle_i   cfg_adc_0/spi_clk_idle
  sts_spi_busy_o   cfg_adc_0/spi_busy    
}  

# Create c_counter_binary
cell xilinx.com:ip:c_counter_binary cntr_0 {
  Output_Width 32
} {
  CLK ps_0/fclk_clk0
}

# Create c_counter_binary
cell xilinx.com:ip:c_counter_binary cntr_1 {
  Output_Width 32
} {
  CLK pll_0/clk_out1
}


# Create port_slicer
cell pavel-demin:user:port_slicer slice_0 {
  DIN_WIDTH 32 DIN_FROM 26 DIN_TO 26
} {
  din cntr_0/Q
}


# Create port_slicer
cell pavel-demin:user:port_slicer slice_1 {
  DIN_WIDTH 32 DIN_FROM 26 DIN_TO 26
} {
  din cntr_1/Q
}

# Create xlconcat
cell xilinx.com:ip:xlconcat concat_1 {
  NUM_PORTS 2
  IN0_WIDTH 1
  IN1_WIDTH 1
} {
  In0 slice_0/dout
  In1 slice_1/dout
  dout led_o
 }

# Create axis_red_pitaya_4adc
cell pavel-demin:user:axis_red_pitaya_4adc adc_0 {
   IDELAY_TYPE "FIXED"
   IDELAY_VALUE 8
} {
  aclk             pll_0/clk_out1
  adc_clk_23       pll_1/clk_out1
  adc_buf_clk01    i_clk_01/IBUF_OUT
  adc_buf_clk23    i_clk_23/IBUF_OUT
  idelay_ctrl_clk  pll_0/clk_out2
  idelay_ctrl_rst  slice_idly_rst/dout
  adc_dat_i        adc_dat_i
  aresetn          rst_0/peripheral_aresetn
  S_AXIS           hub_0/M00_AXIS
}

# Create axis_inf_counter
cell pavel-demin:user:axis_inf_counter inf_cntr_1 {
  AXIS_TDATA_WIDTH 64
  CNTR_WIDTH 64
} {
  run_flag run_slice/dout
  trg_flag trig_0/trg_flag
  aclk pll_0/clk_out1
  aresetn writer_reset_slice/dout
}


# Create axis_broadcaster
cell xilinx.com:ip:axis_broadcaster bcast_0 {
  NUM_MI 8
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  M_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 8
  M_TDATA_NUM_BYTES 2
  M00_TDATA_REMAP {tdata[15:0]}
  M01_TDATA_REMAP {tdata[31:16]}
  M02_TDATA_REMAP {tdata[47:32]}
  M03_TDATA_REMAP {tdata[63:48]}
  M04_TDATA_REMAP {tdata[15:0]}
  M05_TDATA_REMAP {tdata[31:16]}
  M06_TDATA_REMAP {tdata[47:32]}
  M07_TDATA_REMAP {tdata[63:48]}
} {
  S_AXIS adc_0/M_AXIS
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create port_slicer
cell pavel-demin:user:port_slicer decimation_rate {
  DIN_WIDTH 512 DIN_FROM 127 DIN_TO 96
} {
  din hub_0/cfg_data
}

# Create axis_variable
cell pavel-demin:user:axis_variable rate_0 {
  AXIS_TDATA_WIDTH 16
} {
  cfg_data decimation_rate/dout
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create axis_variable
cell pavel-demin:user:axis_variable rate_1 {
  AXIS_TDATA_WIDTH 16
} {
  cfg_data decimation_rate/dout
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create axis_variable
cell pavel-demin:user:axis_variable rate_2 {
  AXIS_TDATA_WIDTH 16
} {
  cfg_data decimation_rate/dout
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create axis_variable
cell pavel-demin:user:axis_variable rate_3 {
  AXIS_TDATA_WIDTH 16
} {
  cfg_data decimation_rate/dout
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create cic_compiler
cell xilinx.com:ip:cic_compiler cic_0 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 6
  SAMPLE_RATE_CHANGES Programmable
  MINIMUM_RATE 4
  MAXIMUM_RATE 6250
  FIXED_OR_INITIAL_RATE 125
  INPUT_SAMPLE_FREQUENCY 125
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 14
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 16
  USE_XTREME_DSP_SLICE false
  HAS_ARESETN true
} {
  S_AXIS_DATA bcast_0/M00_AXIS
  S_AXIS_CONFIG rate_0/M_AXIS
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create cic_compiler
cell xilinx.com:ip:cic_compiler cic_1 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 6
  SAMPLE_RATE_CHANGES Programmable
  MINIMUM_RATE 4
  MAXIMUM_RATE 6250
  FIXED_OR_INITIAL_RATE 125
  INPUT_SAMPLE_FREQUENCY 125
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 14
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 16
  USE_XTREME_DSP_SLICE false
  HAS_ARESETN true
} {
  S_AXIS_DATA bcast_0/M01_AXIS
  S_AXIS_CONFIG rate_1/M_AXIS
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}
# Create cic_compiler
cell xilinx.com:ip:cic_compiler cic_2 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 6
  SAMPLE_RATE_CHANGES Programmable
  MINIMUM_RATE 4
  MAXIMUM_RATE 6250
  FIXED_OR_INITIAL_RATE 125
  INPUT_SAMPLE_FREQUENCY 125
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 14
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 16
  USE_XTREME_DSP_SLICE false
  HAS_ARESETN true
} {
  S_AXIS_DATA bcast_0/M02_AXIS
  S_AXIS_CONFIG rate_2/M_AXIS
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create cic_compiler
cell xilinx.com:ip:cic_compiler cic_3 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 6
  SAMPLE_RATE_CHANGES Programmable
  MINIMUM_RATE 4
  MAXIMUM_RATE 6250
  FIXED_OR_INITIAL_RATE 125
  INPUT_SAMPLE_FREQUENCY 125
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 14
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 16
  USE_XTREME_DSP_SLICE false
  HAS_ARESETN true
} {
  S_AXIS_DATA bcast_0/M03_AXIS
  S_AXIS_CONFIG rate_3/M_AXIS
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create axis_combiner
cell  xilinx.com:ip:axis_combiner comb_0 {
  NUM_SI 4
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 2
} {
  S00_AXIS cic_0/M_AXIS_DATA
  S01_AXIS cic_1/M_AXIS_DATA
  S02_AXIS cic_2/M_AXIS_DATA
  S03_AXIS cic_3/M_AXIS_DATA
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create axis_packetizer
cell pavel-demin:user:axis_oscilloscope scope_0 {
  AXIS_TDATA_WIDTH 64
  CNTR_WIDTH 25
} {
  S_AXIS comb_0/M_AXIS
  run_flag run_slice/dout
  trg_flag trig_0/trg_flag
  pre_data pre_data_slice/dout
  tot_data tot_data_slice/dout
  aclk pll_0/clk_out1
  aresetn writer_reset_slice/dout
}

# Create xlconstant
cell xilinx.com:ip:xlconstant const_size {
  CONST_WIDTH 21
  CONST_VAL 2097151
}

# Create xlconstant
cell xilinx.com:ip:xlconstant writer_address_start {
  CONST_WIDTH 32
  CONST_VAL 268435456
}

# Create axis_ram_writer
cell pavel-demin:user:axis_ram_writer writer_0 {
  ADDR_WIDTH 21
  AXI_ID_WIDTH 3
  AXIS_TDATA_WIDTH 64
  FIFO_WRITE_DEPTH 1024
} {
  S_AXIS scope_0/M_AXIS
  M_AXI ps_0/S_AXI_HP0
  min_addr writer_address_start/dout
  cfg_data const_size/dout
  aclk pll_0/clk_out1
  aresetn writer_reset_slice/dout
}

# Create cic_compiler
cell xilinx.com:ip:cic_compiler cic_dc0_0 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 6
  SAMPLE_RATE_CHANGES Fixed
  MINIMUM_RATE 8192
  MAXIMUM_RATE 8192
  FIXED_OR_INITIAL_RATE 8192
  INPUT_SAMPLE_FREQUENCY 125
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 14
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 32
  USE_XTREME_DSP_SLICE false
  HAS_ARESETN true
} {
  S_AXIS_DATA bcast_0/M04_AXIS
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create cic_compiler
cell xilinx.com:ip:cic_compiler cic_dc1_0 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 6
  SAMPLE_RATE_CHANGES Fixed
  MINIMUM_RATE 512
  MAXIMUM_RATE 512
  FIXED_OR_INITIAL_RATE 512
  INPUT_SAMPLE_FREQUENCY 125
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 32
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 32
  USE_XTREME_DSP_SLICE false
  HAS_ARESETN true
} {
  S_AXIS_DATA cic_dc0_0/M_AXIS_DATA
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}


# Create cic_compiler
cell xilinx.com:ip:cic_compiler cic_dc0_1 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 6
  SAMPLE_RATE_CHANGES Fixed
  MINIMUM_RATE 8192
  MAXIMUM_RATE 8192
  FIXED_OR_INITIAL_RATE 8192
  INPUT_SAMPLE_FREQUENCY 125
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 14
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 32
  USE_XTREME_DSP_SLICE false
  HAS_ARESETN true
} {
  S_AXIS_DATA bcast_0/M05_AXIS
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create cic_compiler
cell xilinx.com:ip:cic_compiler cic_dc1_1 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 6
  SAMPLE_RATE_CHANGES Fixed
  MINIMUM_RATE 512
  MAXIMUM_RATE 512
  FIXED_OR_INITIAL_RATE 512
  INPUT_SAMPLE_FREQUENCY 125
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 32
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 32
  USE_XTREME_DSP_SLICE false
  HAS_ARESETN true
} {
  S_AXIS_DATA cic_dc0_1/M_AXIS_DATA
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}


# Create cic_compiler
cell xilinx.com:ip:cic_compiler cic_dc0_2 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 6
  SAMPLE_RATE_CHANGES Fixed
  MINIMUM_RATE 8192
  MAXIMUM_RATE 8192
  FIXED_OR_INITIAL_RATE 8192
  INPUT_SAMPLE_FREQUENCY 125
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 14
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 32
  USE_XTREME_DSP_SLICE false
  HAS_ARESETN true
} {
  S_AXIS_DATA bcast_0/M06_AXIS
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create cic_compiler
cell xilinx.com:ip:cic_compiler cic_dc1_2 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 6
  SAMPLE_RATE_CHANGES Fixed
  MINIMUM_RATE 512
  MAXIMUM_RATE 512
  FIXED_OR_INITIAL_RATE 512
  INPUT_SAMPLE_FREQUENCY 125
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 32
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 32
  USE_XTREME_DSP_SLICE false
  HAS_ARESETN true
} {
  S_AXIS_DATA cic_dc0_2/M_AXIS_DATA
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create cic_compiler
cell xilinx.com:ip:cic_compiler cic_dc0_3 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 6
  SAMPLE_RATE_CHANGES Fixed
  MINIMUM_RATE 8192
  MAXIMUM_RATE 8192
  FIXED_OR_INITIAL_RATE 8192
  INPUT_SAMPLE_FREQUENCY 125
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 14
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 32
  USE_XTREME_DSP_SLICE false
  HAS_ARESETN true
} {
  S_AXIS_DATA bcast_0/M07_AXIS
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create cic_compiler
cell xilinx.com:ip:cic_compiler cic_dc1_3 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 6
  SAMPLE_RATE_CHANGES Fixed
  MINIMUM_RATE 512
  MAXIMUM_RATE 512
  FIXED_OR_INITIAL_RATE 512
  INPUT_SAMPLE_FREQUENCY 125
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 32
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 32
  USE_XTREME_DSP_SLICE false
  HAS_ARESETN true
} {
  S_AXIS_DATA cic_dc0_3/M_AXIS_DATA
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# Create axis_combiner
cell  xilinx.com:ip:axis_combiner comb_dc {
  NUM_SI 4
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 4
} {
  S00_AXIS cic_dc1_0/M_AXIS_DATA
  S01_AXIS cic_dc1_1/M_AXIS_DATA
  S02_AXIS cic_dc1_2/M_AXIS_DATA
  S03_AXIS cic_dc1_3/M_AXIS_DATA
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
  }

#create value
cell pavel-demin:user:axis_value value_dc {
AXIS_TDATA_WIDTH 128
} {
  s_axis comb_dc/M_AXIS
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}


# Create xlconstant
cell xilinx.com:ip:xlconstant const_ID {
  CONST_WIDTH 16
  CONST_VAL 158
}


# Create xlconcat
cell xilinx.com:ip:xlconcat concat_0 {
  NUM_PORTS 10
  IN0_WIDTH 32
  IN1_WIDTH 32
  IN2_WIDTH 1
  IN3_WIDTH 1
  IN4_WIDTH 14 
  IN5_WIDTH 16
  IN6_WIDTH 32
  IN7_WIDTH 128
  IN8_WITDH 32
  IN9_WITDH 32
} {
  In0 writer_0/sts_data	
  In1 scope_0/sts_data
  In2 scope_0/triggered
  In3 scope_0/complete
  In5 const_ID/dout
  In7 value_dc/data
  dout hub_0/sts_data
}
