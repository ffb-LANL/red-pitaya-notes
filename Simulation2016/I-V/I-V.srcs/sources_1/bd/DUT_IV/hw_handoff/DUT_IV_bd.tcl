
################################################################
# This is a generated script based on design: DUT_IV
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2016.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source DUT_IV_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7z010clg400-2
}


# CHANGE DESIGN NAME HERE
set design_name DUT_IV

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

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set M_AXIS [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS ]
  set M_AXIS_DATA [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS_DATA ]
  set S_AXIS [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS ]
  set_property -dict [ list \
CONFIG.HAS_TKEEP {0} \
CONFIG.HAS_TLAST {0} \
CONFIG.HAS_TREADY {1} \
CONFIG.HAS_TSTRB {0} \
CONFIG.LAYERED_METADATA {undef} \
CONFIG.TDATA_NUM_BYTES {2} \
CONFIG.TDEST_WIDTH {0} \
CONFIG.TID_WIDTH {0} \
CONFIG.TUSER_WIDTH {0} \
 ] $S_AXIS
  set S_AXIS_DATA [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS_DATA ]
  set_property -dict [ list \
CONFIG.HAS_TKEEP {0} \
CONFIG.HAS_TLAST {0} \
CONFIG.HAS_TREADY {1} \
CONFIG.HAS_TSTRB {0} \
CONFIG.LAYERED_METADATA {undef} \
CONFIG.TDATA_NUM_BYTES {2} \
CONFIG.TDEST_WIDTH {0} \
CONFIG.TID_WIDTH {0} \
CONFIG.TUSER_WIDTH {0} \
 ] $S_AXIS_DATA

  # Create ports
  set aclk [ create_bd_port -dir I -type clk aclk ]
  set aresetn [ create_bd_port -dir I -type rst aresetn ]
  set cfg_data [ create_bd_port -dir I -from 159 -to 0 cfg_data ]
  set cfg_data_1 [ create_bd_port -dir I -from 31 -to 0 cfg_data_1 ]
  set overload [ create_bd_port -dir O overload ]
  set sts_data [ create_bd_port -dir O -from 31 -to 0 sts_data ]

  # Create instance: axis_measure_pulse_0, and set properties
  set axis_measure_pulse_0 [ create_bd_cell -type ip -vlnv pavel-demin:user:axis_measure_pulse:1.0 axis_measure_pulse_0 ]
  set_property -dict [ list \
CONFIG.BRAM_ADDR_WIDTH {16} \
 ] $axis_measure_pulse_0

  # Create instance: axis_variable_0, and set properties
  set axis_variable_0 [ create_bd_cell -type ip -vlnv pavel-demin:user:axis_variable:1.0 axis_variable_0 ]

  # Create instance: blk_mem_gen_0, and set properties
  set blk_mem_gen_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.3 blk_mem_gen_0 ]
  set_property -dict [ list \
CONFIG.Byte_Size {9} \
CONFIG.Coe_File {../../../../../../BRAM.coe} \
CONFIG.Enable_32bit_Address {false} \
CONFIG.Enable_A {Always_Enabled} \
CONFIG.Enable_B {Always_Enabled} \
CONFIG.Load_Init_File {true} \
CONFIG.Memory_Type {True_Dual_Port_RAM} \
CONFIG.Port_B_Clock {100} \
CONFIG.Port_B_Enable_Rate {100} \
CONFIG.Port_B_Write_Rate {50} \
CONFIG.Read_Width_A {16} \
CONFIG.Read_Width_B {32} \
CONFIG.Register_PortA_Output_of_Memory_Primitives {true} \
CONFIG.Register_PortB_Output_of_Memory_Primitives {true} \
CONFIG.Use_Byte_Write_Enable {false} \
CONFIG.Use_RSTA_Pin {false} \
CONFIG.Write_Width_A {16} \
CONFIG.Write_Width_B {32} \
CONFIG.use_bram_block {Stand_Alone} \
 ] $blk_mem_gen_0

  # Create instance: cic_compiler_0, and set properties
  set cic_compiler_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:cic_compiler:4.0 cic_compiler_0 ]
  set_property -dict [ list \
CONFIG.Clock_Frequency {125} \
CONFIG.Fixed_Or_Initial_Rate {16} \
CONFIG.HAS_ARESETN {true} \
CONFIG.HAS_DOUT_TREADY {true} \
CONFIG.Input_Data_Width {16} \
CONFIG.Input_Sample_Frequency {0.001} \
CONFIG.Maximum_Rate {16} \
CONFIG.Minimum_Rate {16} \
CONFIG.Output_Data_Width {16} \
CONFIG.Quantization {Truncation} \
CONFIG.RateSpecification {Sample_Period} \
CONFIG.SamplePeriod {16} \
CONFIG.Sample_Rate_Changes {Fixed} \
 ] $cic_compiler_0

  # Create interface connections
  connect_bd_intf_net -intf_net S_AXIS_1 [get_bd_intf_ports S_AXIS] [get_bd_intf_pins axis_measure_pulse_0/S_AXIS]
  connect_bd_intf_net -intf_net S_AXIS_DATA_1 [get_bd_intf_ports S_AXIS_DATA] [get_bd_intf_pins cic_compiler_0/S_AXIS_DATA]
  connect_bd_intf_net -intf_net axis_measure_pulse_0_BRAM_PORTA [get_bd_intf_pins axis_measure_pulse_0/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_0/BRAM_PORTA]
  connect_bd_intf_net -intf_net axis_measure_pulse_0_M_AXIS [get_bd_intf_ports M_AXIS] [get_bd_intf_pins axis_measure_pulse_0/M_AXIS]
  connect_bd_intf_net -intf_net cic_compiler_0_M_AXIS_DATA [get_bd_intf_ports M_AXIS_DATA] [get_bd_intf_pins cic_compiler_0/M_AXIS_DATA]

  # Create port connections
  connect_bd_net -net aclk_1 [get_bd_ports aclk] [get_bd_pins axis_measure_pulse_0/aclk] [get_bd_pins axis_variable_0/aclk] [get_bd_pins cic_compiler_0/aclk]
  connect_bd_net -net aresetn_1 [get_bd_ports aresetn] [get_bd_pins axis_measure_pulse_0/aresetn] [get_bd_pins axis_variable_0/aresetn] [get_bd_pins cic_compiler_0/aresetn]
  connect_bd_net -net axis_measure_pulse_0_overload [get_bd_ports overload] [get_bd_pins axis_measure_pulse_0/overload]
  connect_bd_net -net axis_measure_pulse_0_sts_data [get_bd_ports sts_data] [get_bd_pins axis_measure_pulse_0/sts_data]
  connect_bd_net -net cfg_data_1 [get_bd_ports cfg_data] [get_bd_pins axis_measure_pulse_0/cfg_data]
  connect_bd_net -net cfg_data_1_1 [get_bd_ports cfg_data_1] [get_bd_pins axis_variable_0/cfg_data]

  # Create address segments

  # Perform GUI Layout
  regenerate_bd_layout -layout_string {
   guistr: "# # String gsaved with Nlview 6.5.12  2016-01-29 bk=1.3547 VDI=39 GEI=35 GUI=JA:1.6
#  -string -flagsOSRD
preplace port S_AXIS -pg 1 -y -170 -defaultsOSRD
preplace port overload -pg 1 -y -140 -defaultsOSRD
preplace port aclk -pg 1 -y -150 -defaultsOSRD
preplace port S_AXIS_DATA -pg 1 -y 30 -defaultsOSRD
preplace port M_AXIS -pg 1 -y -180 -defaultsOSRD
preplace port M_AXIS_DATA -pg 1 -y 50 -defaultsOSRD
preplace port aresetn -pg 1 -y -130 -defaultsOSRD
preplace portBus sts_data -pg 1 -y -100 -defaultsOSRD
preplace portBus cfg_data_1 -pg 1 -y 170 -defaultsOSRD
preplace portBus cfg_data -pg 1 -y -110 -defaultsOSRD
preplace inst cic_compiler_0 -pg 1 -lvl 2 -y 60 -defaultsOSRD
preplace inst axis_variable_0 -pg 1 -lvl 1 -y 150 -defaultsOSRD
preplace inst blk_mem_gen_0 -pg 1 -lvl 3 -y -130 -defaultsOSRD
preplace inst axis_measure_pulse_0 -pg 1 -lvl 2 -y -120 -defaultsOSRD
preplace netloc S_AXIS_DATA_1 1 0 2 N 30 N
preplace netloc axis_measure_pulse_0_M_AXIS 1 2 2 510 -190 NJ
preplace netloc cfg_data_1_1 1 0 1 N
preplace netloc cic_compiler_0_M_AXIS_DATA 1 2 2 NJ 50 NJ
preplace netloc axis_measure_pulse_0_overload 1 2 2 510 -70 NJ
preplace netloc cfg_data_1 1 0 2 -50 -90 N
preplace netloc axis_variable_0_M_AXIS 1 1 1 200
preplace netloc S_AXIS_1 1 0 2 N -170 210
preplace netloc aresetn_1 1 0 2 -40 -110 190
preplace netloc axis_measure_pulse_0_BRAM_PORTA 1 2 1 N
preplace netloc axis_measure_pulse_0_sts_data 1 2 2 500 -60 NJ
preplace netloc aclk_1 1 0 2 -30 -130 210
levelinfo -pg 1 -70 80 360 620 760 -top -310 -bot 220
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


