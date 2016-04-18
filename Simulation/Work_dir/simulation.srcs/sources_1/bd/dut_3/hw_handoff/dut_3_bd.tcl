
################################################################
# This is a generated script based on design: dut_3
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2015.4
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   puts "ERROR: This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source dut_3_script.tcl

# If you do not already have a project created,
# you can create a project using the following command:
#    create_project project_1 myproj -part xc7z010clg400-1

# CHECKING IF PROJECT EXISTS
if { [get_projects -quiet] eq "" } {
   puts "ERROR: Please open or create a project!"
   return 1
}



# CHANGE DESIGN NAME HERE
set design_name dut_3

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "ERROR: Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      puts "INFO: Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   puts "INFO: Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   puts "INFO: Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   puts "INFO: Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

puts "INFO: Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   puts $errMsg
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set M_AXIS [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS ]
  set_property -dict [ list \
CONFIG.CLK_DOMAIN {DUT_aclk} \
CONFIG.FREQ_HZ {125000000} \
 ] $M_AXIS
  set M_AXIS_Y [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS_Y ]
  set_property -dict [ list \
CONFIG.CLK_DOMAIN {DUT_aclk} \
CONFIG.FREQ_HZ {125000000} \
 ] $M_AXIS_Y

  # Create ports
  set aclk [ create_bd_port -dir I -type clk aclk ]
  set_property -dict [ list \
CONFIG.CLK_DOMAIN {DUT_aclk} \
CONFIG.FREQ_HZ {125000000} \
 ] $aclk
  set aresetn [ create_bd_port -dir I -type rst aresetn ]

  # Create instance: axis_broadcaster_0, and set properties
  set axis_broadcaster_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_broadcaster:1.1 axis_broadcaster_0 ]
  set_property -dict [ list \
CONFIG.M00_TDATA_REMAP {tdata[31:0]} \
CONFIG.M01_TDATA_REMAP {tdata[31:0]} \
CONFIG.M_TDATA_NUM_BYTES {4} \
CONFIG.S_TDATA_NUM_BYTES {4} \
 ] $axis_broadcaster_0

  # Create instance: axis_broadcaster_1, and set properties
  set axis_broadcaster_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_broadcaster:1.1 axis_broadcaster_1 ]
  set_property -dict [ list \
CONFIG.HAS_TREADY {1} \
CONFIG.M00_TDATA_REMAP {tdata[31:0]} \
CONFIG.M01_TDATA_REMAP {tdata[63:32]} \
CONFIG.M_TDATA_NUM_BYTES {4} \
CONFIG.S_TDATA_NUM_BYTES {8} \
 ] $axis_broadcaster_1

  # Create instance: axis_lfsr_0, and set properties
  set axis_lfsr_0 [ create_bd_cell -type ip -vlnv pavel-demin:user:axis_lfsr:1.0 axis_lfsr_0 ]

  # Create instance: axis_subset_converter_0, and set properties
  set axis_subset_converter_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_subset_converter:1.1 axis_subset_converter_0 ]
  set_property -dict [ list \
CONFIG.M_HAS_TREADY {1} \
CONFIG.M_TDATA_NUM_BYTES {2} \
CONFIG.S_HAS_TREADY {1} \
CONFIG.S_TDATA_NUM_BYTES {4} \
CONFIG.TDATA_REMAP {tdata[15:0]} \
 ] $axis_subset_converter_0

  # Create instance: cic_compiler_0, and set properties
  set cic_compiler_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:cic_compiler:4.0 cic_compiler_0 ]
  set_property -dict [ list \
CONFIG.Clock_Frequency {125} \
CONFIG.Filter_Type {Decimation} \
CONFIG.Fixed_Or_Initial_Rate {8192} \
CONFIG.HAS_ARESETN {true} \
CONFIG.HAS_DOUT_TREADY {false} \
CONFIG.Input_Data_Width {28} \
CONFIG.Input_Sample_Frequency {125} \
CONFIG.Maximum_Rate {8192} \
CONFIG.Minimum_Rate {8192} \
CONFIG.Output_Data_Width {32} \
CONFIG.Quantization {Truncation} \
CONFIG.SamplePeriod {1} \
 ] $cic_compiler_0

  # Create instance: cic_compiler_1, and set properties
  set cic_compiler_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:cic_compiler:4.0 cic_compiler_1 ]
  set_property -dict [ list \
CONFIG.Clock_Frequency {125} \
CONFIG.Filter_Type {Decimation} \
CONFIG.Fixed_Or_Initial_Rate {8192} \
CONFIG.HAS_ARESETN {true} \
CONFIG.HAS_DOUT_TREADY {false} \
CONFIG.Input_Data_Width {28} \
CONFIG.Input_Sample_Frequency {125} \
CONFIG.Maximum_Rate {8192} \
CONFIG.Minimum_Rate {8192} \
CONFIG.Output_Data_Width {32} \
CONFIG.Quantization {Truncation} \
CONFIG.SamplePeriod {1} \
 ] $cic_compiler_1

  # Create instance: cic_compiler_2, and set properties
  set cic_compiler_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:cic_compiler:4.0 cic_compiler_2 ]
  set_property -dict [ list \
CONFIG.Clock_Frequency {125} \
CONFIG.Filter_Type {Decimation} \
CONFIG.Fixed_Or_Initial_Rate {128} \
CONFIG.HAS_ARESETN {true} \
CONFIG.Input_Data_Width {32} \
CONFIG.Input_Sample_Frequency {125} \
CONFIG.Maximum_Rate {128} \
CONFIG.Minimum_Rate {128} \
CONFIG.Output_Data_Width {32} \
CONFIG.Quantization {Truncation} \
CONFIG.SamplePeriod {1} \
 ] $cic_compiler_2

  # Create instance: cmpy_0, and set properties
  set cmpy_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:cmpy:6.0 cmpy_0 ]
  set_property -dict [ list \
CONFIG.APortWidth {14} \
CONFIG.BPortWidth {14} \
CONFIG.FlowControl {Blocking} \
CONFIG.MinimumLatency {9} \
CONFIG.OutputWidth {28} \
CONFIG.RoundMode {Random_Rounding} \
 ] $cmpy_0

  # Create instance: dds_compiler_0, and set properties
  set dds_compiler_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:dds_compiler:6.0 dds_compiler_0 ]
  set_property -dict [ list \
CONFIG.DDS_Clock_Rate {125} \
CONFIG.Has_ARESETn {true} \
CONFIG.Has_Phase_Out {false} \
CONFIG.Has_TREADY {true} \
CONFIG.Latency {9} \
CONFIG.M_DATA_Has_TUSER {Not_Required} \
CONFIG.Noise_Shaping {None} \
CONFIG.Output_Frequency1 {0} \
CONFIG.Output_Width {14} \
CONFIG.PINC1 {10000000000000000000000000} \
CONFIG.Parameter_Entry {Hardware_Parameters} \
CONFIG.Phase_Width {32} \
 ] $dds_compiler_0

  # Create interface connections
  connect_bd_intf_net -intf_net axis_broadcaster_0_M00_AXIS [get_bd_intf_pins axis_broadcaster_0/M00_AXIS] [get_bd_intf_pins axis_subset_converter_0/S_AXIS]
  connect_bd_intf_net -intf_net axis_broadcaster_0_M01_AXIS [get_bd_intf_pins axis_broadcaster_0/M01_AXIS] [get_bd_intf_pins cmpy_0/S_AXIS_B]
  connect_bd_intf_net -intf_net axis_broadcaster_1_M00_AXIS [get_bd_intf_pins axis_broadcaster_1/M00_AXIS] [get_bd_intf_pins cic_compiler_0/S_AXIS_DATA]
  connect_bd_intf_net -intf_net axis_broadcaster_1_M01_AXIS [get_bd_intf_pins axis_broadcaster_1/M01_AXIS] [get_bd_intf_pins cic_compiler_1/S_AXIS_DATA]
  connect_bd_intf_net -intf_net axis_lfsr_0_M_AXIS [get_bd_intf_pins axis_lfsr_0/M_AXIS] [get_bd_intf_pins cmpy_0/S_AXIS_CTRL]
  connect_bd_intf_net -intf_net axis_subset_converter_0_M_AXIS [get_bd_intf_pins axis_subset_converter_0/M_AXIS] [get_bd_intf_pins cmpy_0/S_AXIS_A]
  connect_bd_intf_net -intf_net cic_compiler_0_M_AXIS_DATA [get_bd_intf_pins cic_compiler_0/M_AXIS_DATA] [get_bd_intf_pins cic_compiler_2/S_AXIS_DATA]
  connect_bd_intf_net -intf_net cic_compiler_1_M_AXIS_DATA [get_bd_intf_ports M_AXIS_Y] [get_bd_intf_pins cic_compiler_1/M_AXIS_DATA]
  connect_bd_intf_net -intf_net cic_compiler_2_M_AXIS_DATA [get_bd_intf_ports M_AXIS] [get_bd_intf_pins cic_compiler_2/M_AXIS_DATA]
  connect_bd_intf_net -intf_net cmpy_0_M_AXIS_DOUT [get_bd_intf_pins axis_broadcaster_1/S_AXIS] [get_bd_intf_pins cmpy_0/M_AXIS_DOUT]
  connect_bd_intf_net -intf_net dds_compiler_0_M_AXIS_DATA [get_bd_intf_pins axis_broadcaster_0/S_AXIS] [get_bd_intf_pins dds_compiler_0/M_AXIS_DATA]

  # Create port connections
  connect_bd_net -net aclk_1 [get_bd_ports aclk] [get_bd_pins axis_broadcaster_0/aclk] [get_bd_pins axis_broadcaster_1/aclk] [get_bd_pins axis_lfsr_0/aclk] [get_bd_pins axis_subset_converter_0/aclk] [get_bd_pins cic_compiler_0/aclk] [get_bd_pins cic_compiler_1/aclk] [get_bd_pins cic_compiler_2/aclk] [get_bd_pins cmpy_0/aclk] [get_bd_pins dds_compiler_0/aclk]
  connect_bd_net -net aresetn_1 [get_bd_ports aresetn] [get_bd_pins axis_broadcaster_0/aresetn] [get_bd_pins axis_broadcaster_1/aresetn] [get_bd_pins axis_lfsr_0/aresetn] [get_bd_pins axis_subset_converter_0/aresetn] [get_bd_pins cic_compiler_0/aresetn] [get_bd_pins cic_compiler_1/aresetn] [get_bd_pins cic_compiler_2/aresetn] [get_bd_pins dds_compiler_0/aresetn]

  # Create address segments

  # Perform GUI Layout
  regenerate_bd_layout -layout_string {
   guistr: "# # String gsaved with Nlview 6.5.5  2015-06-26 bk=1.3371 VDI=38 GEI=35 GUI=JA:1.6
#  -string -flagsOSRD
preplace port M_AXIS_Y -pg 1 -y 320 -defaultsOSRD
preplace port aclk -pg 1 -y 120 -defaultsOSRD
preplace port M_AXIS -pg 1 -y 200 -defaultsOSRD
preplace port aresetn -pg 1 -y 140 -defaultsOSRD
preplace inst axis_broadcaster_0 -pg 1 -lvl 2 -y 150 -defaultsOSRD
preplace inst dds_compiler_0 -pg 1 -lvl 1 -y 130 -defaultsOSRD
preplace inst axis_broadcaster_1 -pg 1 -lvl 5 -y 290 -defaultsOSRD
preplace inst cic_compiler_0 -pg 1 -lvl 7 -y 200 -defaultsOSRD
preplace inst cic_compiler_1 -pg 1 -lvl 7 -y 320 -defaultsOSRD -resize 220 100
preplace inst cmpy_0 -pg 1 -lvl 4 -y 240 -defaultsOSRD
preplace inst cic_compiler_2 -pg 1 -lvl 6 -y -70 -defaultsOSRD
preplace inst axis_lfsr_0 -pg 1 -lvl 3 -y 50 -defaultsOSRD
preplace inst axis_subset_converter_0 -pg 1 -lvl 3 -y 160 -defaultsOSRD
preplace netloc cic_compiler_2_M_AXIS_DATA 1 6 2 NJ -70 1980
preplace netloc axis_broadcaster_1_M01_AXIS 1 5 2 N 300 N
preplace netloc axis_subset_converter_0_M_AXIS 1 3 1 830
preplace netloc axis_broadcaster_0_M00_AXIS 1 2 1 N
preplace netloc cmpy_0_M_AXIS_DOUT 1 4 1 1130
preplace netloc cic_compiler_0_M_AXIS_DATA 1 5 3 1440 0 NJ 0 1970
preplace netloc axis_broadcaster_0_M01_AXIS 1 2 2 550 230 NJ
preplace netloc cic_compiler_1_M_AXIS_DATA 1 7 1 NJ
preplace netloc axis_broadcaster_1_M00_AXIS 1 5 2 1430 180 N
preplace netloc axis_lfsr_0_M_AXIS 1 3 1 850
preplace netloc aresetn_1 1 0 7 -10 190 230 220 570 240 NJ 160 1120 160 1430 160 1700
preplace netloc dds_compiler_0_M_AXIS_DATA 1 1 1 N
preplace netloc aclk_1 1 0 7 -10 70 230 70 560 250 840 140 1140 140 1420 140 1710
levelinfo -pg 1 -30 130 410 700 990 1280 1570 1840 2000 -top -140 -bot 400
",
}

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


