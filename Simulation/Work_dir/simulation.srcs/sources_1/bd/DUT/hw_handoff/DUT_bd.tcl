
################################################################
# This is a generated script based on design: DUT
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
# source DUT_script.tcl

# If you do not already have a project created,
# you can create a project using the following command:
#    create_project project_1 myproj -part xc7z010clg400-1

# CHECKING IF PROJECT EXISTS
if { [get_projects -quiet] eq "" } {
   puts "ERROR: Please open or create a project!"
   return 1
}



# CHANGE DESIGN NAME HERE
set design_name DUT

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
CONFIG.FREQ_HZ {125000000} \
 ] $M_AXIS

  # Create ports
  set aclk [ create_bd_port -dir I -type clk aclk ]
  set_property -dict [ list \
CONFIG.FREQ_HZ {125000000} \
 ] $aclk
  set aresetn [ create_bd_port -dir I -type rst aresetn ]
  set clk_out1 [ create_bd_port -dir O -type clk clk_out1 ]
  set trig [ create_bd_port -dir I -type data trig ]
  set trig_out [ create_bd_port -dir O -from 0 -to 0 -type data trig_out ]

  # Create instance: axis_clock_converter_0, and set properties
  set axis_clock_converter_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_clock_converter:1.1 axis_clock_converter_0 ]
  set_property -dict [ list \
CONFIG.TUSER_WIDTH {1} \
 ] $axis_clock_converter_0

  # Create instance: axis_subset_converter_0, and set properties
  set axis_subset_converter_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_subset_converter:1.1 axis_subset_converter_0 ]
  set_property -dict [ list \
CONFIG.M_TDATA_NUM_BYTES {2} \
CONFIG.S_TDATA_NUM_BYTES {4} \
CONFIG.TDATA_REMAP {tdata[15:0]} \
 ] $axis_subset_converter_0

  # Create instance: axis_usr_merge_0, and set properties
  set axis_usr_merge_0 [ create_bd_cell -type ip -vlnv pavel-demin:user:axis_usr_merge:1.0 axis_usr_merge_0 ]
  set_property -dict [ list \
CONFIG.AXIS_TDATA_WIDTH {16} \
 ] $axis_usr_merge_0

  # Create instance: axis_usr_split_0, and set properties
  set axis_usr_split_0 [ create_bd_cell -type ip -vlnv pavel-demin:user:axis_usr_split:1.0 axis_usr_split_0 ]
  set_property -dict [ list \
CONFIG.AXIS_TDATA_WIDTH {16} \
 ] $axis_usr_split_0

  # Create instance: clk_wiz_0, and set properties
  set clk_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:5.2 clk_wiz_0 ]
  set_property -dict [ list \
CONFIG.CLKIN1_JITTER_PS {80.0} \
CONFIG.CLKOUT1_DRIVES {BUFG} \
CONFIG.CLKOUT1_JITTER {119.348} \
CONFIG.CLKOUT1_PHASE_ERROR {96.948} \
CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {125} \
CONFIG.CLKOUT2_DRIVES {BUFG} \
CONFIG.CLKOUT2_JITTER {104.759} \
CONFIG.CLKOUT2_PHASE_ERROR {96.948} \
CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {250} \
CONFIG.CLKOUT2_USED {true} \
CONFIG.CLKOUT3_DRIVES {BUFG} \
CONFIG.CLKOUT4_DRIVES {BUFG} \
CONFIG.CLKOUT5_DRIVES {BUFG} \
CONFIG.CLKOUT6_DRIVES {BUFG} \
CONFIG.CLKOUT7_DRIVES {BUFG} \
CONFIG.JITTER_SEL {No_Jitter} \
CONFIG.MMCM_CLKFBOUT_MULT_F {8} \
CONFIG.MMCM_CLKIN1_PERIOD {8.0} \
CONFIG.MMCM_CLKOUT0_DIVIDE_F {8} \
CONFIG.MMCM_CLKOUT0_DUTY_CYCLE {0.5} \
CONFIG.MMCM_CLKOUT1_DIVIDE {4} \
CONFIG.MMCM_CLKOUT1_DUTY_CYCLE {0.5} \
CONFIG.MMCM_COMPENSATION {ZHOLD} \
CONFIG.MMCM_DIVCLK_DIVIDE {1} \
CONFIG.NUM_OUT_CLKS {2} \
CONFIG.PRIMITIVE {PLL} \
CONFIG.PRIM_IN_FREQ {125} \
CONFIG.USE_MIN_POWER {true} \
 ] $clk_wiz_0

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
CONFIG.PINC1 {1000000000000000000000000000} \
CONFIG.Parameter_Entry {Hardware_Parameters} \
CONFIG.Phase_Width {32} \
 ] $dds_compiler_0

  # Create interface connections
  connect_bd_intf_net -intf_net axis_clock_converter_0_M_AXIS [get_bd_intf_pins axis_clock_converter_0/M_AXIS] [get_bd_intf_pins axis_usr_split_0/S_AXIS]
  connect_bd_intf_net -intf_net axis_subset_converter_0_M_AXIS [get_bd_intf_pins axis_subset_converter_0/M_AXIS] [get_bd_intf_pins axis_usr_merge_0/S_AXIS]
  connect_bd_intf_net -intf_net axis_usr_merge_0_M_AXIS [get_bd_intf_pins axis_clock_converter_0/S_AXIS] [get_bd_intf_pins axis_usr_merge_0/M_AXIS]
  connect_bd_intf_net -intf_net axis_usr_split_0_M_AXIS [get_bd_intf_ports M_AXIS] [get_bd_intf_pins axis_usr_split_0/M_AXIS]
  connect_bd_intf_net -intf_net dds_compiler_0_M_AXIS_DATA [get_bd_intf_pins axis_subset_converter_0/S_AXIS] [get_bd_intf_pins dds_compiler_0/M_AXIS_DATA]

  # Create port connections
  connect_bd_net -net aclk_1 [get_bd_ports aclk] [get_bd_pins axis_clock_converter_0/s_axis_aclk] [get_bd_pins axis_subset_converter_0/aclk] [get_bd_pins axis_usr_merge_0/aclk] [get_bd_pins clk_wiz_0/clk_in1] [get_bd_pins dds_compiler_0/aclk]
  connect_bd_net -net aresetn_1 [get_bd_ports aresetn] [get_bd_pins axis_clock_converter_0/m_axis_aresetn] [get_bd_pins axis_clock_converter_0/s_axis_aresetn] [get_bd_pins axis_subset_converter_0/aresetn] [get_bd_pins dds_compiler_0/aresetn]
  connect_bd_net -net axis_usr_split_0_user_data [get_bd_ports trig_out] [get_bd_pins axis_usr_split_0/user_data]
  connect_bd_net -net clk_wiz_0_clk_out1 [get_bd_ports clk_out1] [get_bd_pins axis_clock_converter_0/m_axis_aclk] [get_bd_pins axis_usr_split_0/aclk] [get_bd_pins clk_wiz_0/clk_out1]
  connect_bd_net -net trig_1 [get_bd_ports trig] [get_bd_pins axis_usr_merge_0/user_data]

  # Create address segments

  # Perform GUI Layout
  regenerate_bd_layout -layout_string {
   guistr: "# # String gsaved with Nlview 6.5.5  2015-06-26 bk=1.3371 VDI=38 GEI=35 GUI=JA:1.6
#  -string -flagsOSRD
preplace port clk_out1 -pg 1 -y 290 -defaultsOSRD
preplace port trig -pg 1 -y 20 -defaultsOSRD
preplace port aclk -pg 1 -y 40 -defaultsOSRD
preplace port M_AXIS -pg 1 -y 170 -defaultsOSRD
preplace port aresetn -pg 1 -y 60 -defaultsOSRD
preplace portBus trig_out -pg 1 -y 150 -defaultsOSRD
preplace inst dds_compiler_0 -pg 1 -lvl 1 -y 100 -defaultsOSRD
preplace inst axis_usr_merge_0 -pg 1 -lvl 3 -y 150 -defaultsOSRD
preplace inst axis_clock_converter_0 -pg 1 -lvl 4 -y 170 -defaultsOSRD
preplace inst axis_usr_split_0 -pg 1 -lvl 5 -y 230 -defaultsOSRD
preplace inst axis_subset_converter_0 -pg 1 -lvl 2 -y 120 -defaultsOSRD
preplace inst clk_wiz_0 -pg 1 -lvl 2 -y 310 -defaultsOSRD
preplace netloc axis_usr_merge_0_M_AXIS 1 3 1 760
preplace netloc axis_subset_converter_0_M_AXIS 1 2 1 500
preplace netloc axis_usr_split_0_M_AXIS 1 5 1 1230
preplace netloc axis_usr_split_0_user_data 1 5 1 1220
preplace netloc axis_clock_converter_0_M_AXIS 1 4 1 1000
preplace netloc clk_wiz_0_clk_out1 1 2 4 NJ 260 770 260 NJ 290 NJ
preplace netloc aresetn_1 1 0 4 10 40 210 50 NJ 50 770
preplace netloc dds_compiler_0_M_AXIS_DATA 1 1 1 N
preplace netloc aclk_1 1 0 4 0 20 220 190 NJ 220 760
preplace netloc trig_1 1 0 3 NJ 10 NJ 10 NJ
levelinfo -pg 1 -30 110 370 650 890 1110 1260 -top 0 -bot 1170
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


