
################################################################
# This is a generated script based on design: DUT_2
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
# source DUT_2_script.tcl

# If you do not already have a project created,
# you can create a project using the following command:
#    create_project project_1 myproj -part xc7z010clg400-1

# CHECKING IF PROJECT EXISTS
if { [get_projects -quiet] eq "" } {
   puts "ERROR: Please open or create a project!"
   return 1
}



# CHANGE DESIGN NAME HERE
set design_name DUT_2

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
  set M_AXI [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI ]
  set_property -dict [ list \
CONFIG.ADDR_WIDTH {32} \
CONFIG.CLK_DOMAIN {DUT_aclk} \
CONFIG.DATA_WIDTH {64} \
CONFIG.FREQ_HZ {125000000} \
CONFIG.HAS_BRESP {0} \
CONFIG.HAS_BURST {0} \
CONFIG.HAS_CACHE {0} \
CONFIG.HAS_LOCK {0} \
CONFIG.HAS_PROT {0} \
CONFIG.HAS_QOS {0} \
CONFIG.HAS_REGION {0} \
CONFIG.HAS_RRESP {0} \
CONFIG.NUM_READ_OUTSTANDING {2} \
CONFIG.NUM_WRITE_OUTSTANDING {2} \
CONFIG.PROTOCOL {AXI3} \
CONFIG.READ_WRITE_MODE {WRITE_ONLY} \
 ] $M_AXI

  # Create ports
  set aclk [ create_bd_port -dir I -type clk aclk ]
  set_property -dict [ list \
CONFIG.ASSOCIATED_RESET {enable:aresetn:enable_wr} \
CONFIG.CLK_DOMAIN {DUT_aclk} \
CONFIG.FREQ_HZ {125000000} \
 ] $aclk
  set aresetn [ create_bd_port -dir I -type rst aresetn ]
  set cfg_data [ create_bd_port -dir I -from 6 -to 0 cfg_data ]
  set enable [ create_bd_port -dir I -type rst enable ]
  set enable_wr [ create_bd_port -dir I -type rst enable_wr ]
  set trig [ create_bd_port -dir I trig ]

  # Create instance: axis_circular_packetizer_0, and set properties
  set axis_circular_packetizer_0 [ create_bd_cell -type ip -vlnv pavel-demin:user:axis_circular_packetizer:1.0 axis_circular_packetizer_0 ]
  set_property -dict [ list \
CONFIG.CNTR_WIDTH {7} \
 ] $axis_circular_packetizer_0

  # Create instance: axis_dwidth_converter_0, and set properties
  set axis_dwidth_converter_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_dwidth_converter:1.1 axis_dwidth_converter_0 ]
  set_property -dict [ list \
CONFIG.M_TDATA_NUM_BYTES {8} \
CONFIG.S_TDATA_NUM_BYTES {4} \
 ] $axis_dwidth_converter_0

  # Create instance: axis_ram_writer_0, and set properties
  set axis_ram_writer_0 [ create_bd_cell -type ip -vlnv pavel-demin:user:axis_ram_writer:1.0 axis_ram_writer_0 ]
  set_property -dict [ list \
CONFIG.ADDR_WIDTH {6} \
 ] $axis_ram_writer_0

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
CONFIG.PINC1 {1000000000000000000000000000000} \
CONFIG.Parameter_Entry {Hardware_Parameters} \
CONFIG.Phase_Width {32} \
 ] $dds_compiler_0

  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]
  set_property -dict [ list \
CONFIG.CONST_VAL {268435456} \
CONFIG.CONST_WIDTH {32} \
 ] $xlconstant_0

  # Create interface connections
  connect_bd_intf_net -intf_net axis_circular_packetizer_0_M_AXIS [get_bd_intf_pins axis_circular_packetizer_0/M_AXIS] [get_bd_intf_pins axis_dwidth_converter_0/S_AXIS]
  connect_bd_intf_net -intf_net axis_dwidth_converter_0_M_AXIS [get_bd_intf_pins axis_dwidth_converter_0/M_AXIS] [get_bd_intf_pins axis_ram_writer_0/S_AXIS]
  connect_bd_intf_net -intf_net axis_ram_writer_0_M_AXI [get_bd_intf_ports M_AXI] [get_bd_intf_pins axis_ram_writer_0/M_AXI]
  connect_bd_intf_net -intf_net dds_compiler_0_M_AXIS_DATA [get_bd_intf_pins axis_circular_packetizer_0/S_AXIS] [get_bd_intf_pins dds_compiler_0/M_AXIS_DATA]

  # Create port connections
  connect_bd_net -net aclk_1 [get_bd_ports aclk] [get_bd_pins axis_circular_packetizer_0/aclk] [get_bd_pins axis_dwidth_converter_0/aclk] [get_bd_pins axis_ram_writer_0/aclk] [get_bd_pins dds_compiler_0/aclk]
  connect_bd_net -net aresetn_1_1 [get_bd_ports enable_wr] [get_bd_pins axis_dwidth_converter_0/aresetn] [get_bd_pins axis_ram_writer_0/aresetn]
  connect_bd_net -net aresetn_2 [get_bd_ports aresetn] [get_bd_pins dds_compiler_0/aresetn]
  connect_bd_net -net cfg_data_1 [get_bd_ports cfg_data] [get_bd_pins axis_circular_packetizer_0/cfg_data]
  connect_bd_net -net enable_1 [get_bd_ports enable] [get_bd_pins axis_circular_packetizer_0/aresetn]
  connect_bd_net -net trig_1 [get_bd_ports trig] [get_bd_pins axis_circular_packetizer_0/trigger]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins axis_ram_writer_0/cfg_data] [get_bd_pins xlconstant_0/dout]

  # Create address segments
  create_bd_addr_seg -range 0x20000000 -offset 0x0 [get_bd_addr_spaces axis_ram_writer_0/M_AXI] [get_bd_addr_segs M_AXI/Reg] SEG_M_AXI_Reg

  # Perform GUI Layout
  regenerate_bd_layout -layout_string {
   guistr: "# # String gsaved with Nlview 6.5.5  2015-06-26 bk=1.3371 VDI=38 GEI=35 GUI=JA:1.6
#  -string -flagsOSRD
preplace port enable_wr -pg 1 -y 210 -defaultsOSRD
preplace port enable -pg 1 -y 120 -defaultsOSRD
preplace port M_AXI -pg 1 -y 180 -defaultsOSRD
preplace port trig -pg 1 -y 160 -defaultsOSRD
preplace port aclk -pg 1 -y 20 -defaultsOSRD
preplace port aresetn -pg 1 -y 80 -defaultsOSRD
preplace portBus cfg_data -pg 1 -y 140 -defaultsOSRD
preplace inst dds_compiler_0 -pg 1 -lvl 1 -y 70 -defaultsOSRD
preplace inst xlconstant_0 -pg 1 -lvl 3 -y 250 -defaultsOSRD
preplace inst axis_dwidth_converter_0 -pg 1 -lvl 3 -y 120 -defaultsOSRD
preplace inst axis_circular_packetizer_0 -pg 1 -lvl 2 -y 110 -defaultsOSRD
preplace inst axis_ram_writer_0 -pg 1 -lvl 4 -y 190 -defaultsOSRD
preplace netloc axis_circular_packetizer_0_M_AXIS 1 2 1 N
preplace netloc axis_dwidth_converter_0_M_AXIS 1 3 1 690
preplace netloc aresetn_1_1 1 0 4 NJ 200 NJ 200 480 200 NJ
preplace netloc xlconstant_0_dout 1 3 1 NJ
preplace netloc cfg_data_1 1 0 2 NJ 140 NJ
preplace netloc dds_compiler_0_M_AXIS_DATA 1 1 1 N
preplace netloc aresetn_2 1 0 1 NJ
preplace netloc aclk_1 1 0 4 20 10 220 20 480 50 NJ
preplace netloc axis_ram_writer_0_M_AXI 1 4 1 N
preplace netloc trig_1 1 0 2 NJ 150 NJ
preplace netloc enable_1 1 0 2 NJ 130 NJ
levelinfo -pg 1 0 120 360 590 810 940 -top 0 -bot 300
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


