#========================================================
# IP creation for RISC-V Block RAM and AXI BRAM controller  
# Based on Vivado 2017.2
# Author: Ran Zhao (zhaoran@ict.ac.cn)
# Date: 11/04/2018
#
#========================================================

namespace eval riscv_bram_val {
	set ip_gen_loc ./${::project_name}/${::project_name}.srcs/sources_1/ip
}

# Create AXI BRAM controller 
set ip_name axi_bram_if
create_ip -name axi_bram_ctrl -vendor xilinx.com -library ip -version 4.0 -module_name ${ip_name} 
set_property -dict [ list CONFIG.SINGLE_PORT_BRAM {1} \
					CONFIG.PROTOCOL {AXI4} \
					CONFIG.MEM_DEPTH {16384} \
					CONFIG.BMG_INSTANCE {EXTERNAL} ] [get_ips ${ip_name}]
set_property GENERATE_SYNTH_CHECKPOINT {FALSE} [ get_files ${riscv_bram_val::ip_gen_loc}/${ip_name}/${ip_name}.xci ]
generate_target all [ get_files ${riscv_bram_val::ip_gen_loc}/${ip_name}/${ip_name}.xci ]

# Create Block RAM
set ip_name riscv_bram 
create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.3 -module_name ${ip_name} 
set_property -dict [ list CONFIG.Enable_32bit_Address {true} \
					CONFIG.Write_Depth_A {16384} \
					CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
					CONFIG.Load_Init_File {true} \
					CONFIG.Coe_File "${::sim_out_dir}/inst.coe" \
					CONFIG.Fill_Remaining_Memory_Locations {true} ] [get_ips ${ip_name}]
set_property GENERATE_SYNTH_CHECKPOINT {FALSE} [ get_files ${riscv_bram_val::ip_gen_loc}/${ip_name}/${ip_name}.xci ]
generate_target all [ get_files ${riscv_bram_val::ip_gen_loc}/${ip_name}/${ip_name}.xci ]

# Create UART
set ip_name riscv_uart 
create_ip -name axi_uartlite -vendor xilinx.com -library ip -version 2.0 -module_name ${ip_name} 
set_property -dict [ list CONFIG.C_BAUDRATE {115200} ] [get_ips ${ip_name}]
set_property GENERATE_SYNTH_CHECKPOINT {FALSE} [ get_files ${riscv_bram_val::ip_gen_loc}/${ip_name}/${ip_name}.xci ]
generate_target all [ get_files ${riscv_bram_val::ip_gen_loc}/${ip_name}/${ip_name}.xci ]

