
## Clock signal
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]
#create_clock -period 12.000 -name sys_clk_pin -waveform {0.000 6.000} -add [get_ports clk]

set_property -dict { PACKAGE_PIN C12   IOSTANDARD LVCMOS33 } [get_ports { reset }]; #IO_L3P_T0_DQS_AD1P_15 Sch=cpu_resetn


#set_input_delay -clock [get_clocks sys_clk_pin] -min -add_delay 0.130 [get_ports {address[*]}]
#set_input_delay -clock [get_clocks sys_clk_pin] -max -add_delay 0.140 [get_ports {address[*]}]
#set_input_delay -clock [get_clocks sys_clk_pin] -min -add_delay 0.130 [get_ports {data_in[*]}]
#set_input_delay -clock [get_clocks sys_clk_pin] -max -add_delay 0.140 [get_ports {data_in[*]}]
#set_input_delay -clock [get_clocks sys_clk_pin] -min -add_delay 0.130 [get_ports write_enable]
#set_input_delay -clock [get_clocks sys_clk_pin] -max -add_delay 0.140 [get_ports write_enable]
#set_output_delay -clock [get_clocks sys_clk_pin] -min -add_delay 1.160 [get_ports {data_out[*]}]
#set_output_delay -clock [get_clocks sys_clk_pin] -max -add_delay 1.160 [get_ports {data_out[*]}]
#set_output_delay -clock [get_clocks sys_clk_pin] -min -add_delay 0.13 [get_ports {select_type[*]}]
#set_output_delay -clock [get_clocks sys_clk_pin] -max -add_delay 0.14 [get_ports {select_type[*]}]
#set_output_delay -clock [get_clocks sys_clk_pin] -min -add_delay 0.13 [get_ports {signed_unsigned}]
#set_output_delay -clock [get_clocks sys_clk_pin] -max -add_delay 0.14 [get_ports {signed_unsigned}]

#set_input_delay -clock [get_clocks sys_clk_pin] -min -add_delay 0.130 [get_ports {select_type[*]}]
#set_input_delay -clock [get_clocks sys_clk_pin] -max -add_delay 0.140 [get_ports {select_type[*]}]

set_property -dict { PACKAGE_PIN H17   IOSTANDARD LVCMOS33 } [get_ports { dcache_out[0] }]; #IO_L18P_T2_A24_15 Sch=dcache_out[]
set_property -dict { PACKAGE_PIN K15   IOSTANDARD LVCMOS33 } [get_ports { dcache_out[1] }]; #IO_L24P_T3_RS1_15 Sch=dcache_out[]
set_property -dict { PACKAGE_PIN J13   IOSTANDARD LVCMOS33 } [get_ports { dcache_out[2] }]; #IO_L17N_T2_A25_15 Sch=dcache_out[]
set_property -dict { PACKAGE_PIN N14   IOSTANDARD LVCMOS33 } [get_ports { dcache_out[3] }]; #IO_L8P_T1_D11_14 Sch=dcache_out[]
set_property -dict { PACKAGE_PIN R18   IOSTANDARD LVCMOS33 } [get_ports { dcache_out[4] }]; #IO_L7P_T1_D09_14 Sch=dcache_out[]
set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports { dcache_out[5] }]; #IO_L18N_T2_A11_D27_14 Sch=dcache_out[]
set_property -dict { PACKAGE_PIN U17   IOSTANDARD LVCMOS33 } [get_ports { dcache_out[6] }]; #IO_L17P_T2_A14_D30_14 Sch=dcache_out[]
set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS33 } [get_ports { dcache_out[7] }]; #IO_L18P_T2_A12_D28_14 Sch=dcache_out[]
set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports { dcache_out[8] }]; #IO_L16N_T2_A15_D31_14 Sch=dcache_out[]
set_property -dict { PACKAGE_PIN T15   IOSTANDARD LVCMOS33 } [get_ports { dcache_out[9] }]; #IO_L14N_T2_SRCC_14 Sch=dcache_out[]
set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33 } [get_ports { dcache_out[10] }]; #IO_L22P_T3_A05_D21_14 Sch=dcache_out[]
set_property -dict { PACKAGE_PIN T16   IOSTANDARD LVCMOS33 } [get_ports { dcache_out[11] }]; #IO_L15N_T2_DQS_DOUT_CSO_B_14 Sch=dcache_out[]
set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports { dcache_out[12] }]; #IO_L16P_T2_CSI_B_14 Sch=dcache_out[]
set_property -dict { PACKAGE_PIN V14   IOSTANDARD LVCMOS33 } [get_ports { dcache_out[13] }]; #IO_L22N_T3_A04_D20_14 Sch=dcache_out[]
set_property -dict { PACKAGE_PIN V12   IOSTANDARD LVCMOS33 } [get_ports { dcache_out[14] }]; #IO_L20N_T3_A07_D23_14 Sch=dcache_out[]
set_property -dict { PACKAGE_PIN V11   IOSTANDARD LVCMOS33 } [get_ports { dcache_out[15] }]; #IO_L21N_T3_DQS_A06_D22_14 Sch=dcache_out[]

