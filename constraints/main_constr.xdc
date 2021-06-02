
## Clock signal
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]

set_input_delay -clock [get_clocks sys_clk_pin] -min -add_delay 0.130 [get_ports {address[*]}]
set_input_delay -clock [get_clocks sys_clk_pin] -max -add_delay 0.140 [get_ports {address[*]}]
set_input_delay -clock [get_clocks sys_clk_pin] -min -add_delay 0.130 [get_ports {data_in[*]}]
set_input_delay -clock [get_clocks sys_clk_pin] -max -add_delay 0.140 [get_ports {data_in[*]}]
set_input_delay -clock [get_clocks sys_clk_pin] -min -add_delay 0.130 [get_ports write_enable]
set_input_delay -clock [get_clocks sys_clk_pin] -max -add_delay 0.140 [get_ports write_enable]
set_output_delay -clock [get_clocks sys_clk_pin] -min -add_delay 1.160 [get_ports {data_out[*]}]
set_output_delay -clock [get_clocks sys_clk_pin] -max -add_delay 1.160 [get_ports {data_out[*]}]
set_output_delay -clock [get_clocks sys_clk_pin] -min -add_delay 0.13 [get_ports {select_type[*]}]
set_output_delay -clock [get_clocks sys_clk_pin] -max -add_delay 0.14 [get_ports {select_type[*]}]
set_output_delay -clock [get_clocks sys_clk_pin] -min -add_delay 0.13 [get_ports {signed_unsigned}]
set_output_delay -clock [get_clocks sys_clk_pin] -max -add_delay 0.14 [get_ports {signed_unsigned}]

set_input_delay -clock [get_clocks sys_clk_pin] -min -add_delay 0.130 [get_ports {select_type[*]}]
set_input_delay -clock [get_clocks sys_clk_pin] -max -add_delay 0.140 [get_ports {select_type[*]}]
