#========================================================
# Vivado BD design auto run script for MPSoC in ZCU102
# Based on Vivado 2017.2
# Author: Yisong Chang (changyisong@ict.ac.cn)
# Date: 22/12/2017
#========================================================

namespace eval mpsoc_bd_val {
	set design_name bram_bd
	set bd_prefix ${mpsoc_bd_val::design_name}_

}


# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${mpsoc_bd_val::design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne ${mpsoc_bd_val::design_name} } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <${mpsoc_bd_val::design_name}> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq ${mpsoc_bd_val::design_name} } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <${mpsoc_bd_val::design_name}> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${mpsoc_bd_val::design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <${mpsoc_bd_val::design_name}> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <${mpsoc_bd_val::design_name}> in project, so creating one..."

   create_bd_design ${mpsoc_bd_val::design_name}

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <${mpsoc_bd_val::design_name}> as current_bd_design."
   current_bd_design ${mpsoc_bd_val::design_name}

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"${mpsoc_bd_val::design_name}\"."

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

#=============================================
# Create IP blocks
#=============================================

  # Create interconnect
  set axi4_to_lite_ic [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi4_to_lite_ic ]
  set_property -dict [list CONFIG.NUM_MI {4} CONFIG.NUM_SI {1}] $axi4_to_lite_ic

  # Create instance: rst_zynq_mpsoc_99M, and set properties
#  set rst_zynq_mpsoc_99M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_zynq_mpsoc_99M ]

  # Create instance: AXI block ram controller and block ram generator
  set mips_bram_ctrl [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.0 mips_bram_ctrl ]
  set_property -dict [list CONFIG.SINGLE_PORT_BRAM {1} \
					CONFIG.PROTOCOL {AXI4Lite} ] $mips_bram_ctrl

  set weight_bram_ctrl [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.0 weight_bram_ctrl ]
  set_property -dict [list CONFIG.SINGLE_PORT_BRAM {1} \
					CONFIG.PROTOCOL {AXI4Lite} ] $weight_bram_ctrl

  set data_bram_ctrl [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.0 data_bram_ctrl ]
  set_property -dict [list CONFIG.SINGLE_PORT_BRAM {1} \
					CONFIG.PROTOCOL {AXI4Lite} ] $data_bram_ctrl

  set mips_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.3 mips_bram ]
  set_property -dict [list CONFIG.use_bram_block {Stand_Alone} \
					CONFIG.Enable_32bit_Address {true} \
					CONFIG.Use_Byte_Write_Enable {true} \
					CONFIG.Byte_Size {8} \
					CONFIG.Write_Width_A {32} \
					CONFIG.Write_Depth_A {16384} \
					CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
					CONFIG.Fill_Remaining_Memory_Locations {true} \
					CONFIG.Use_RSTA_Pin {true} \
					CONFIG.Read_Width_A {32} \
					CONFIG.Load_Init_File {true} \
					CONFIG.Coe_File "${::sim_out_dir}/inst.coe" ] $mips_bram

  set weight_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.3 weight_bram ]
  set_property -dict [list CONFIG.use_bram_block {Stand_Alone} \
					CONFIG.Enable_32bit_Address {true} \
					CONFIG.Use_Byte_Write_Enable {true} \
					CONFIG.Byte_Size {8} \
					CONFIG.Write_Width_A {32} \
					CONFIG.Read_Width_A {32} \
					CONFIG.Write_Depth_A {16384} \
					CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
					CONFIG.Fill_Remaining_Memory_Locations {true} \
					CONFIG.Use_RSTA_Pin {true} \
					CONFIG.Load_Init_File {true} \
					CONFIG.Coe_File "${::sim_out_dir}/../../sources/testbench/weight.coe" ] $weight_bram

  set data_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.3 data_bram ]
  set_property -dict [list CONFIG.use_bram_block {Stand_Alone} \
					CONFIG.Enable_32bit_Address {true} \
					CONFIG.Use_Byte_Write_Enable {true} \
					CONFIG.Byte_Size {8} \
					CONFIG.Write_Width_A {32} \
					CONFIG.Read_Width_A {32} \
					CONFIG.Write_Depth_A {16384} \
					CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
					CONFIG.Fill_Remaining_Memory_Locations {true} \
					CONFIG.Use_RSTA_Pin {true} \
					CONFIG.Load_Init_File {true} \
					CONFIG.Coe_File "${::sim_out_dir}/../../sources/testbench/data.coe" ] $data_bram
  
  # Create instance: AXI UART controller 
  set axi_uart [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uart ]
  set_property -dict [list CONFIG.C_BAUDRATE {115200}] $axi_uart

#=============================================
# Clock ports
#=============================================
  # PS FCLK0 output
  create_bd_port -dir I -type clk user_clk

#==============================================
# Reset ports
#==============================================
  #PL system reset using PS-PL user_reset_n signal
  create_bd_port -dir I -type rst user_reset_n

  set_property CONFIG.ASSOCIATED_RESET {user_reset_n} [get_bd_ports user_clk]

#==============================================
# UART ports
#==============================================
#  create_bd_port -dir I -type data uart_rx
#  create_bd_port -dir O -type data uart_tx
#  create_bd_port -dir O -type data uart_int

#==============================================
# Export AXI Interface
#==============================================
  # Connect to DoCE AXI-Lite slave
  set mips_cpu_axi_mem [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 mips_cpu_axi_mem]
  set_property -dict [ list CONFIG.PROTOCOL {AXI4Lite} ] $mips_cpu_axi_mem

  set_property CONFIG.ASSOCIATED_BUSIF {mips_cpu_axi_mem} [get_bd_ports user_clk]

#=============================================
# System clock connection
#=============================================
	  connect_bd_net -net user_clk [get_bd_pins user_clk] \
			[get_bd_pins axi4_to_lite_ic/S00_ACLK] \
			[get_bd_pins axi4_to_lite_ic/ACLK] \
			[get_bd_pins axi4_to_lite_ic/M00_ACLK] \
			[get_bd_pins axi4_to_lite_ic/M01_ACLK] \
			[get_bd_pins axi4_to_lite_ic/M02_ACLK] \
			[get_bd_pins axi4_to_lite_ic/M03_ACLK] \
			[get_bd_pins axi_uart/s_axi_aclk] \
			[get_bd_pins mips_bram_ctrl/s_axi_aclk] \
			[get_bd_pins weight_bram_ctrl/s_axi_aclk] \
			[get_bd_pins data_bram_ctrl/s_axi_aclk]

#=============================================
# System reset connection
#=============================================

  connect_bd_net -net user_reset_n [get_bd_pins user_reset_n] \
			[get_bd_pins axi4_to_lite_ic/ARESETN] \
			[get_bd_pins axi4_to_lite_ic/S00_ARESETN] \
			[get_bd_pins axi4_to_lite_ic/M00_ARESETN] \
			[get_bd_pins axi4_to_lite_ic/M01_ARESETN] \
			[get_bd_pins axi4_to_lite_ic/M02_ARESETN] \
			[get_bd_pins axi4_to_lite_ic/M03_ARESETN] \
			[get_bd_pins mips_bram_ctrl/s_axi_aresetn] \
			[get_bd_pins weight_bram_ctrl/s_axi_aresetn] \
			[get_bd_pins data_bram_ctrl/s_axi_aresetn] \
			[get_bd_pins axi_uart/s_axi_aresetn]


#==============================================
# AXI Interface Connection
#==============================================
  connect_bd_intf_net -intf_net mips_cpu_master [get_bd_intf_pins axi4_to_lite_ic/S00_AXI] \
			[get_bd_intf_pins mips_cpu_axi_mem] 

  connect_bd_intf_net -intf_net axi_uart [get_bd_intf_pins axi4_to_lite_ic/M00_AXI] \
			[get_bd_intf_pins axi_uart/S_AXI]

  connect_bd_intf_net -intf_net mips_bram_if [get_bd_intf_pins axi4_to_lite_ic/M01_AXI] \
			[get_bd_intf_pins mips_bram_ctrl/S_AXI]

  connect_bd_intf_net -intf_net weight_bram_if [get_bd_intf_pins axi4_to_lite_ic/M02_AXI] \
			[get_bd_intf_pins weight_bram_ctrl/S_AXI]

  connect_bd_intf_net -intf_net data_bram_if [get_bd_intf_pins axi4_to_lite_ic/M03_AXI] \
			[get_bd_intf_pins data_bram_ctrl/S_AXI]

#=============================================
# Other ports
#=============================================
  connect_bd_intf_net [get_bd_intf_pins mips_bram_ctrl/BRAM_PORTA] [get_bd_intf_pins mips_bram/BRAM_PORTA]
  connect_bd_intf_net [get_bd_intf_pins weight_bram_ctrl/BRAM_PORTA] [get_bd_intf_pins weight_bram/BRAM_PORTA]
  connect_bd_intf_net [get_bd_intf_pins data_bram_ctrl/BRAM_PORTA] [get_bd_intf_pins data_bram/BRAM_PORTA]

#  connect_bd_net -net uart_rx [get_bd_pins axi_uart/rx] [get_bd_ports uart_rx]
#  connect_bd_net -net uart_tx [get_bd_pins axi_uart/tx] [get_bd_ports uart_tx]
#  connect_bd_net -net uart_tx [get_bd_pins axi_uart/interrupt] [get_bd_ports uart_int]

#=============================================
# Create address segments
#=============================================

  create_bd_addr_seg -range 0x10000 -offset 0x00000000 [get_bd_addr_spaces mips_cpu_axi_mem] [get_bd_addr_segs mips_bram_ctrl/S_AXI/Mem0] MIPS_MEM
  create_bd_addr_seg -range 0x10000 -offset 0x08000000 [get_bd_addr_spaces mips_cpu_axi_mem] [get_bd_addr_segs weight_bram_ctrl/S_AXI/Mem0] WEIGHT_MEM
  create_bd_addr_seg -range 0x10000 -offset 0x08100000 [get_bd_addr_spaces mips_cpu_axi_mem] [get_bd_addr_segs data_bram_ctrl/S_AXI/Mem0] DATA_MEM
  create_bd_addr_seg -range 0x1000 -offset 0x00010000 [get_bd_addr_spaces mips_cpu_axi_mem] [get_bd_addr_segs axi_uart/S_AXI/Reg] MIPS_UART

#=============================================
# Finish BD creation 
#=============================================

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""

