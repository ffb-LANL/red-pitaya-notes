
################################################################
# This is a generated script based on design: dut_4
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
# source dut_4_script.tcl

# If you do not already have a project created,
# you can create a project using the following command:
#    create_project project_1 myproj -part xc7z010clg400-1

# CHECKING IF PROJECT EXISTS
if { [get_projects -quiet] eq "" } {
   puts "ERROR: Please open or create a project!"
   return 1
}



# CHANGE DESIGN NAME HERE
set design_name dut_4

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
  set S_AXIS [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS ]
  set_property -dict [ list \
CONFIG.FREQ_HZ {100000000} \
CONFIG.HAS_TKEEP {0} \
CONFIG.HAS_TLAST {0} \
CONFIG.HAS_TREADY {1} \
CONFIG.HAS_TSTRB {0} \
CONFIG.LAYERED_METADATA {undef} \
CONFIG.PHASE {0.000} \
CONFIG.TDATA_NUM_BYTES {4} \
CONFIG.TDEST_WIDTH {0} \
CONFIG.TID_WIDTH {0} \
CONFIG.TUSER_WIDTH {0} \
 ] $S_AXIS

  # Create ports
  set aclk [ create_bd_port -dir I -type clk aclk ]
  set aresetn [ create_bd_port -dir I -type rst aresetn ]
  set cfg_data [ create_bd_port -dir I -from 15 -to 0 cfg_data ]

  # Create instance: axis_register_slice_0, and set properties
  set axis_register_slice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_register_slice:1.1 axis_register_slice_0 ]

  # Create instance: axis_variable_0, and set properties
  set axis_variable_0 [ create_bd_cell -type ip -vlnv pavel-demin:user:axis_variable:1.0 axis_variable_0 ]
  set_property -dict [ list \
CONFIG.AXIS_TDATA_WIDTH {16} \
 ] $axis_variable_0

  # Create instance: dds_compiler_0, and set properties
  set dds_compiler_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:dds_compiler:6.0 dds_compiler_0 ]
  set_property -dict [ list \
CONFIG.DATA_Has_TLAST {Not_Required} \
CONFIG.DDS_Clock_Rate {125} \
CONFIG.DSP48_Use {Maximal} \
CONFIG.Has_ARESETn {true} \
CONFIG.Has_TREADY {true} \
CONFIG.Latency {8} \
CONFIG.M_DATA_Has_TUSER {Not_Required} \
CONFIG.Noise_Shaping {None} \
CONFIG.Output_Frequency1 {0} \
CONFIG.Output_Width {3} \
CONFIG.PINC1 {0} \
CONFIG.Parameter_Entry {Hardware_Parameters} \
CONFIG.PartsPresent {Phase_Generator_only} \
CONFIG.Phase_Increment {Programmable} \
CONFIG.Phase_Width {16} \
CONFIG.S_PHASE_Has_TUSER {Not_Required} \
 ] $dds_compiler_0

  # Create interface connections
  connect_bd_intf_net -intf_net axis_register_slice_0_M_AXIS [get_bd_intf_pins axis_register_slice_0/M_AXIS] [get_bd_intf_pins dds_compiler_0/S_AXIS_CONFIG]
  connect_bd_intf_net -intf_net axis_variable_0_M_AXIS [get_bd_intf_pins axis_register_slice_0/S_AXIS] [get_bd_intf_pins axis_variable_0/M_AXIS]
  connect_bd_intf_net -intf_net dds_compiler_0_M_AXIS_PHASE [get_bd_intf_ports M_AXIS] [get_bd_intf_pins dds_compiler_0/M_AXIS_PHASE]

  # Create port connections
  connect_bd_net -net Net [get_bd_ports aresetn] [get_bd_pins axis_register_slice_0/aresetn] [get_bd_pins axis_variable_0/aresetn] [get_bd_pins dds_compiler_0/aresetn]
  connect_bd_net -net Net1 [get_bd_ports aclk] [get_bd_pins axis_register_slice_0/aclk] [get_bd_pins axis_variable_0/aclk] [get_bd_pins dds_compiler_0/aclk]
  connect_bd_net -net cfg_data_1 [get_bd_ports cfg_data] [get_bd_pins axis_variable_0/cfg_data]

  # Create address segments

  # Perform GUI Layout
  regenerate_bd_layout -layout_string {
   guistr: "# # String gsaved with Nlview 6.5.5  2015-06-26 bk=1.3371 VDI=38 GEI=35 GUI=JA:1.6
#  -string -flagsOSRD
preplace port S_AXIS -pg 1 -y 40 -defaultsOSRD
preplace port aclk -pg 1 -y 20 -defaultsOSRD
preplace port M_AXIS -pg 1 -y 90 -defaultsOSRD
preplace port aresetn -pg 1 -y 80 -defaultsOSRD
preplace portBus cfg_data -pg 1 -y 100 -defaultsOSRD
preplace inst dds_compiler_0 -pg 1 -lvl 3 -y 120 -defaultsOSRD
preplace inst axis_register_slice_0 -pg 1 -lvl 2 -y 100 -defaultsOSRD
preplace inst axis_variable_0 -pg 1 -lvl 1 -y 80 -defaultsOSRD
preplace netloc cfg_data_1 1 0 1 NJ
preplace netloc axis_variable_0_M_AXIS 1 1 1 N
preplace netloc dds_compiler_0_M_AXIS_PHASE 1 3 1 N
preplace netloc Net 1 0 3 20 150 250 180 NJ
preplace netloc Net1 1 0 3 20 10 240 170 NJ
preplace netloc axis_register_slice_0_M_AXIS 1 2 1 N
levelinfo -pg 1 0 130 340 610 800 -top 0 -bot 200
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


