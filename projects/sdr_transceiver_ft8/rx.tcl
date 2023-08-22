# Create port_slicer
cell pavel-demin:user:port_slicer slice_0 {
  DIN_WIDTH 8 DIN_FROM 0 DIN_TO 0
}

for {set i 0} {$i <= 7} {incr i} {

  # Create port_slicer
  cell pavel-demin:user:port_slicer slice_[expr $i + 1] {
    DIN_WIDTH 288 DIN_FROM [expr $i] DIN_TO [expr $i]
  }

  # Create port_selector
  cell pavel-demin:user:port_selector selector_$i {
    DOUT_WIDTH 16
  } {
    cfg slice_[expr $i + 1]/dout
    din /adc_0/m_axis_tdata
  }

  # Create port_slicer
  cell pavel-demin:user:port_slicer slice_[expr $i + 9] {
    DIN_WIDTH 288 DIN_FROM [expr 32 * $i + 63] DIN_TO [expr 32 * $i + 32]
  }

  # Create axis_constant
  cell pavel-demin:user:axis_constant phase_$i {
    AXIS_TDATA_WIDTH 32
  } {
    cfg_data slice_[expr $i + 9]/dout
    aclk /pll_0/clk_out1
  }

  # Create dds_compiler
  cell xilinx.com:ip:dds_compiler dds_$i {
    DDS_CLOCK_RATE 125
    SPURIOUS_FREE_DYNAMIC_RANGE 138
    FREQUENCY_RESOLUTION 0.2
    PHASE_INCREMENT Streaming
    HAS_PHASE_OUT false
    PHASE_WIDTH 30
    OUTPUT_WIDTH 24
    DSP48_USE Minimal
    NEGATIVE_SINE true
  } {
    S_AXIS_PHASE phase_$i/M_AXIS
    aclk /pll_0/clk_out1
  }

}

# Create xlconstant
cell xilinx.com:ip:xlconstant const_0

for {set i 0} {$i <= 15} {incr i} {

  # Create port_slicer
  cell pavel-demin:user:port_slicer dds_slice_$i {
    DIN_WIDTH 48 DIN_FROM [expr 24 * ($i % 2) + 23] DIN_TO [expr 24 * ($i % 2)]
  } {
    din dds_[expr $i / 2]/m_axis_data_tdata
  }

  # Create dsp48
  cell pavel-demin:user:dsp48 mult_$i {
    A_WIDTH 24
    B_WIDTH 14
    P_WIDTH 24
  } {
    A dds_slice_$i/dout
    B selector_[expr $i / 2]/dout
    CLK /pll_0/clk_out1
  }

  # Create cic_compiler
  cell xilinx.com:ip:cic_compiler cic_$i {
    INPUT_DATA_WIDTH.VALUE_SRC USER
    FILTER_TYPE Decimation
    NUMBER_OF_STAGES 6
    SAMPLE_RATE_CHANGES Fixed
    FIXED_OR_INITIAL_RATE 125
    INPUT_SAMPLE_FREQUENCY 125
    CLOCK_FREQUENCY 125
    INPUT_DATA_WIDTH 24
    QUANTIZATION Truncation
    OUTPUT_DATA_WIDTH 32
    USE_XTREME_DSP_SLICE false
    HAS_DOUT_TREADY true
    HAS_ARESETN true
  } {
    s_axis_data_tdata mult_$i/P
    s_axis_data_tvalid const_0/dout
    aclk /pll_0/clk_out1
    aresetn /rst_0/peripheral_aresetn
  }

}

# Create axis_combiner
cell  xilinx.com:ip:axis_combiner comb_0 {
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 4
  NUM_SI 16
} {
  S00_AXIS cic_0/M_AXIS_DATA
  S01_AXIS cic_1/M_AXIS_DATA
  S02_AXIS cic_2/M_AXIS_DATA
  S03_AXIS cic_3/M_AXIS_DATA
  S04_AXIS cic_4/M_AXIS_DATA
  S05_AXIS cic_5/M_AXIS_DATA
  S06_AXIS cic_6/M_AXIS_DATA
  S07_AXIS cic_7/M_AXIS_DATA
  S08_AXIS cic_8/M_AXIS_DATA
  S09_AXIS cic_9/M_AXIS_DATA
  S10_AXIS cic_10/M_AXIS_DATA
  S11_AXIS cic_11/M_AXIS_DATA
  S12_AXIS cic_12/M_AXIS_DATA
  S13_AXIS cic_13/M_AXIS_DATA
  S14_AXIS cic_14/M_AXIS_DATA
  S15_AXIS cic_15/M_AXIS_DATA
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

# Create axis_dwidth_converter
cell xilinx.com:ip:axis_dwidth_converter conv_0 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 64
  M_TDATA_NUM_BYTES 4
} {
  S_AXIS comb_0/M_AXIS
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

# Create cic_compiler
cell xilinx.com:ip:cic_compiler cic_16 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 6
  SAMPLE_RATE_CHANGES Fixed
  FIXED_OR_INITIAL_RATE 125
  INPUT_SAMPLE_FREQUENCY 1
  CLOCK_FREQUENCY 125
  NUMBER_OF_CHANNELS 16
  INPUT_DATA_WIDTH 32
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 32
  USE_XTREME_DSP_SLICE false
  HAS_DOUT_TREADY true
  HAS_ARESETN true
} {
  S_AXIS_DATA conv_0/M_AXIS
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

# Create fir_compiler
cell xilinx.com:ip:fir_compiler fir_0 {
  DATA_WIDTH.VALUE_SRC USER
  DATA_WIDTH 32
  COEFFICIENTVECTOR {-1.6477639552e-08, -4.7322398249e-08, -7.9311409775e-10, 3.0934160749e-08, 1.8626860457e-08, 3.2748557120e-08, -6.2990865366e-09, -1.5227986158e-07, -8.3046084786e-08, 3.1453549182e-07, 3.0562673833e-07, -4.7417269422e-07, -7.1349504942e-07, 5.4732396824e-07, 1.3346218315e-06, -4.1414075502e-07, -2.1505100620e-06, -6.7741001572e-08, 3.0754648545e-06, 1.0370225542e-06, -3.9443639371e-06, -2.5919131159e-06, 4.5153751942e-06, 4.7478257577e-06, -4.4928424580e-06, -7.3982459612e-06, 3.5721630429e-06, 1.0289531399e-05, -1.5038200096e-06, -1.3020866944e-05, -1.8320780741e-06, 1.5078157871e-05, 6.3546486992e-06, -1.5905693254e-05, -1.1732482243e-05, 1.5011014603e-05, 1.7371981550e-05, -1.2094352463e-05, -2.2466882726e-05, 7.1697434417e-06, 2.6103268500e-05, -6.6357607870e-07, -2.7429279457e-05, -6.5506232292e-06, 2.5864354890e-05, 1.3204315242e-05, -2.1317037730e-05, -1.7790015052e-05, 1.4366401658e-05, 1.8819648804e-05, -6.3576957562e-06, -1.5162467161e-05, -6.3454751890e-07, 6.4157454794e-06, 4.0077900105e-06, 6.7576033639e-06, -1.0053804557e-06, -2.2403023407e-05, -1.0762630262e-05, 3.7233383457e-05, 3.2700816121e-05, -4.6860517011e-05, -6.4652658151e-05, 4.6259987990e-05, 1.0440186152e-04, -3.0540394819e-05, -1.4745720335e-04, -4.1201370727e-06, 1.8718591031e-04, 5.9472285269e-05, -2.1537491758e-04, -1.3430207308e-04, 2.2322415298e-04, 2.2383529854e-04, -2.0270064628e-04, -3.1962371627e-04, 1.4809620807e-04, 4.1005036861e-04, -5.7559785442e-05, -4.8151499596e-04, -6.5676313349e-05, 5.2025099911e-04, 2.1266416434e-04, -5.1461871942e-04, -3.6900584284e-04, 4.5746738987e-04, 5.1597365609e-04, -3.4847793976e-04, -6.3288127995e-04, 1.9564979495e-04, 7.0018874915e-04, -1.5799271763e-05, -7.0320539204e-04, -1.6637669771e-04, 6.3584392061e-04, 3.2083226194e-04, -5.0381108421e-04, -4.1625531993e-04, 3.2656999167e-04, 4.2539187592e-04, -1.3746695449e-04, -3.3104533584e-04, -1.8432241920e-05, 1.3195287043e-04, 8.8991373620e-05, 1.5240645111e-04, -2.2005955258e-05, -4.7910932766e-04, -2.2615894370e-04, 7.8159610890e-04, 6.8033628724e-04, -9.7384157378e-04, -1.3374308681e-03, 9.5750542955e-04, 2.1582379593e-03, -6.3305849791e-04, -3.0623958357e-03, -8.6277386830e-05, 3.9274923777e-03, 1.2589008658e-03, -4.5932013829e-03, -2.8990646220e-03, 4.8708089214e-03, 4.9627165218e-03, -4.5578812687e-03, -7.3366723336e-03, 3.4571636048e-03, 9.8325360800e-03, -1.3981932434e-03, -1.2186163713e-02, -1.7403432886e-03, 1.4062282609e-02, 6.0085367250e-03, -1.5065575155e-02, -1.1370141606e-02, 1.4748357578e-02, 1.7687227432e-02, -1.2618525849e-02, -2.4713165549e-02, 8.1309035026e-03, 3.2086471101e-02, -6.4515135347e-04, -3.9317049352e-02, -1.0692407507e-02, 4.5736643978e-02, 2.7250170322e-02, -5.0321471240e-02, -5.1715839268e-02, 5.1019578536e-02, 9.0570896036e-02, -4.1608582780e-02, -1.6374794004e-01, -1.0799124751e-02, 3.5639198057e-01, 5.5482162063e-01, 3.5639198057e-01, -1.0799124751e-02, -1.6374794004e-01, -4.1608582780e-02, 9.0570896036e-02, 5.1019578536e-02, -5.1715839268e-02, -5.0321471240e-02, 2.7250170322e-02, 4.5736643978e-02, -1.0692407507e-02, -3.9317049352e-02, -6.4515135347e-04, 3.2086471101e-02, 8.1309035026e-03, -2.4713165549e-02, -1.2618525849e-02, 1.7687227432e-02, 1.4748357578e-02, -1.1370141606e-02, -1.5065575155e-02, 6.0085367250e-03, 1.4062282609e-02, -1.7403432886e-03, -1.2186163713e-02, -1.3981932434e-03, 9.8325360800e-03, 3.4571636048e-03, -7.3366723336e-03, -4.5578812687e-03, 4.9627165218e-03, 4.8708089214e-03, -2.8990646220e-03, -4.5932013829e-03, 1.2589008658e-03, 3.9274923777e-03, -8.6277386830e-05, -3.0623958357e-03, -6.3305849791e-04, 2.1582379593e-03, 9.5750542955e-04, -1.3374308681e-03, -9.7384157378e-04, 6.8033628724e-04, 7.8159610890e-04, -2.2615894370e-04, -4.7910932766e-04, -2.2005955258e-05, 1.5240645111e-04, 8.8991373620e-05, 1.3195287043e-04, -1.8432241920e-05, -3.3104533584e-04, -1.3746695449e-04, 4.2539187592e-04, 3.2656999167e-04, -4.1625531993e-04, -5.0381108421e-04, 3.2083226194e-04, 6.3584392061e-04, -1.6637669771e-04, -7.0320539204e-04, -1.5799271763e-05, 7.0018874915e-04, 1.9564979495e-04, -6.3288127995e-04, -3.4847793976e-04, 5.1597365609e-04, 4.5746738987e-04, -3.6900584284e-04, -5.1461871942e-04, 2.1266416434e-04, 5.2025099911e-04, -6.5676313349e-05, -4.8151499596e-04, -5.7559785442e-05, 4.1005036861e-04, 1.4809620807e-04, -3.1962371627e-04, -2.0270064628e-04, 2.2383529854e-04, 2.2322415298e-04, -1.3430207308e-04, -2.1537491758e-04, 5.9472285269e-05, 1.8718591031e-04, -4.1201370727e-06, -1.4745720335e-04, -3.0540394819e-05, 1.0440186152e-04, 4.6259987990e-05, -6.4652658151e-05, -4.6860517011e-05, 3.2700816121e-05, 3.7233383457e-05, -1.0762630262e-05, -2.2403023407e-05, -1.0053804557e-06, 6.7576033639e-06, 4.0077900105e-06, 6.4157454794e-06, -6.3454751890e-07, -1.5162467161e-05, -6.3576957562e-06, 1.8819648804e-05, 1.4366401658e-05, -1.7790015052e-05, -2.1317037730e-05, 1.3204315242e-05, 2.5864354890e-05, -6.5506232292e-06, -2.7429279457e-05, -6.6357607870e-07, 2.6103268500e-05, 7.1697434417e-06, -2.2466882726e-05, -1.2094352463e-05, 1.7371981550e-05, 1.5011014603e-05, -1.1732482243e-05, -1.5905693254e-05, 6.3546486992e-06, 1.5078157871e-05, -1.8320780741e-06, -1.3020866944e-05, -1.5038200096e-06, 1.0289531399e-05, 3.5721630429e-06, -7.3982459612e-06, -4.4928424580e-06, 4.7478257577e-06, 4.5153751942e-06, -2.5919131159e-06, -3.9443639371e-06, 1.0370225542e-06, 3.0754648545e-06, -6.7741001572e-08, -2.1505100620e-06, -4.1414075502e-07, 1.3346218315e-06, 5.4732396824e-07, -7.1349504942e-07, -4.7417269422e-07, 3.0562673833e-07, 3.1453549182e-07, -8.3046084786e-08, -1.5227986158e-07, -6.2990865366e-09, 3.2748557120e-08, 1.8626860457e-08, 3.0934160749e-08, -7.9311409775e-10, -4.7322398249e-08, -1.6477639552e-08}
  COEFFICIENT_WIDTH 32
  QUANTIZATION Maximize_Dynamic_Range
  BESTPRECISION true
  FILTER_TYPE Decimation
  DECIMATION_RATE 2
  NUMBER_CHANNELS 16
  NUMBER_PATHS 1
  SAMPLE_FREQUENCY 0.008
  CLOCK_FREQUENCY 125
  OUTPUT_ROUNDING_MODE Convergent_Rounding_to_Even
  OUTPUT_WIDTH 33
  M_DATA_HAS_TREADY true
  HAS_ARESETN true
} {
  S_AXIS_DATA cic_16/M_AXIS_DATA
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

# Create axis_subset_converter
cell xilinx.com:ip:axis_subset_converter subset_0 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  M_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 5
  M_TDATA_NUM_BYTES 4
  TDATA_REMAP {tdata[31:0]}
} {
  S_AXIS fir_0/M_AXIS_DATA
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

# Create floating_point
cell xilinx.com:ip:floating_point fp_0 {
  OPERATION_TYPE Fixed_to_float
  A_PRECISION_TYPE.VALUE_SRC USER
  C_A_EXPONENT_WIDTH.VALUE_SRC USER
  C_A_FRACTION_WIDTH.VALUE_SRC USER
  A_PRECISION_TYPE Custom
  C_A_EXPONENT_WIDTH 2
  C_A_FRACTION_WIDTH 30
  RESULT_PRECISION_TYPE Single
  HAS_ARESETN true
} {
  S_AXIS_A subset_0/M_AXIS
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

# Create axis_dwidth_converter
cell xilinx.com:ip:axis_dwidth_converter conv_1 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 4
  M_TDATA_NUM_BYTES 64
} {
  S_AXIS fp_0/M_AXIS_RESULT
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

# Create axis_fifo
cell pavel-demin:user:axis_fifo fifo_0 {
  S_AXIS_TDATA_WIDTH 512
  M_AXIS_TDATA_WIDTH 512
  WRITE_DEPTH 1024
  ALWAYS_READY TRUE
} {
  S_AXIS conv_1/M_AXIS
  aclk /pll_0/clk_out1
  aresetn slice_0/dout
}

# Create axis_dwidth_converter
cell xilinx.com:ip:axis_dwidth_converter conv_2 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 64
  M_TDATA_NUM_BYTES 4
} {
  S_AXIS fifo_0/M_AXIS
  aclk /pll_0/clk_out1
  aresetn slice_0/dout
}
