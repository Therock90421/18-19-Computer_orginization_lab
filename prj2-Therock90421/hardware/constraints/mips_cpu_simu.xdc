create_clock -period 10 -name clk -waveform {0 5} [get_ports mips_cpu_clk]

set_property IOSTANDARD LVCMOS18 [get_ports mips_cpu_clk]
set_property package_pin C4 [get_ports mips_cpu_clk]

set_property IOSTANDARD LVCMOS18 [get_ports mips_cpu_reset]
set_property package_pin B8 [get_ports mips_cpu_reset]

set_property IOSTANDARD LVCMOS18 [get_ports mips_cpu_pc_sig]
set_property package_pin C8 [get_ports mips_cpu_pc_sig]

