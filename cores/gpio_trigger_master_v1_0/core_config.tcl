set display_name {GPIO Trigger Master}

set core [ipx::current_core]

set_property DISPLAY_NAME $display_name $core
set_property DESCRIPTION $display_name $core

core_parameter GPIO_DATA_WIDTH {GPIO DATA WIDTH} {Width of the GPIO data bus.}
core_parameter GPIO_INPUT_WIDTH {GPIO INPUT WIDTH} {Input subset of GPIO data bus.}
core_parameter GPIO_OUTPUT_WIDTH {GPIO OUTPUT WIDTH} {Output subset of GPIO data bus.}