set display_name {AXI4-Stream Packetizer with Phase}

set core [ipx::current_core]

set_property DISPLAY_NAME $display_name $core
set_property DESCRIPTION $display_name $core

core_parameter AXIS_TDATA_WIDTH {AXIS TDATA WIDTH} {Width of the M_AXIS data bus and signal part of S_AXIS.}
core_parameter AXIS_TDATA_PHASE_WIDTH {AXIS TDATA PHASE WIDTH} {Width of the phase part of S_AXIS data bus.}
core_parameter CNTR_WIDTH {CNTR WIDTH} {Width of the counter register.}
core_parameter CONTINUOUS {CONTINUOUS} {If TRUE, reader runs continuously.}
core_parameter NON_BLOCKING {NON_BLOCKING} {If TRUE, reader acceps and discards incomming stream when not active.}

set bus [ipx::get_bus_interfaces -of_objects $core m_axis]
set_property NAME M_AXIS $bus
set_property INTERFACE_MODE master $bus

set bus [ipx::get_bus_interfaces -of_objects $core s_axis]
set_property NAME S_AXIS $bus
set_property INTERFACE_MODE slave $bus

set bus [ipx::get_bus_interfaces aclk]
set parameter [ipx::get_bus_parameters -of_objects $bus ASSOCIATED_BUSIF]
set_property VALUE M_AXIS:S_AXIS $parameter
