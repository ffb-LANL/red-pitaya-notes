set display_name {GPIO Trigger}

set core [ipx::current_core]

set_property DISPLAY_NAME $display_name $core
set_property DESCRIPTION $display_name $core

core_parameter GPIO_DATA_WIDTH {GPIO DATA WIDTH} {Width of the GPIO data bus.}

