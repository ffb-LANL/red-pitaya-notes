
### ADC

create_bd_port -dir I -from 27 -to 0 adc_dat_i

# create_bd_port -dir I -from 3 -to 0 adc_clk_i

create_bd_port -dir I -type clk -freq_hz 125000000 adc_clk_p_i
create_bd_port -dir I -type clk -freq_hz 125000000 adc_clk_n_i

# set_property CONFIG.FREQ_HZ 125000000 [get_bd_ports adc_clk_p_i]
# set_property CONFIG.FREQ_HZ 125000000 [get_bd_ports adc_clk_n_i]

create_bd_port -dir I -type clk -freq_hz 125000000 adc_clk_p_i2
create_bd_port -dir I -type clk -freq_hz 125000000 adc_clk_n_i2

set_property CONFIG.FREQ_HZ 125000000 [get_bd_ports adc_clk_p_i2]
set_property CONFIG.FREQ_HZ 125000000 [get_bd_ports adc_clk_n_i2]

### SPI interface

create_bd_port -dir O spi_csa_o
create_bd_port -dir O spi_csb_o
create_bd_port -dir O spi_clk_o
create_bd_port -dir O spi_mosi_o

### XADC

create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vp_Vn
create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux0
create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux1
create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux9
create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_analog_io_rtl:1.0 Vaux8

### Expansion connector

create_bd_port -dir IO -from 7 -to 0 exp_p_tri_io
create_bd_port -dir IO -from 7 -to 0 exp_n_tri_io

### LED

create_bd_port -dir O -from 7 -to 0 led_o
