
################################################################
# This is a generated script based on design: design
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2017.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source design_script.tcl


# The design that will be created by this Tcl script contains the following
# module references:
# adder, counter

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xczu2eg-sfva625-1-e
   set_property BOARD_PART interwiser:none:part0:2.0 [current_project]
}


# CHANGE DESIGN NAME HERE
set design_name mpsoc

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

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES:
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

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


  # Create instance: axi_gpio to alu and set properties
  set axi_gpio_alu_operand [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_alu_operand ]
  set_property -dict [ list CONFIG.C_ALL_INPUTS {0} \
		CONFIG.C_ALL_OUTPUTS {1} \
		CONFIG.C_GPIO_WIDTH {32} \
		CONFIG.C_IS_DUAL {1} \
		CONFIG.C_ALL_INPUTS_2 {0} \
		CONFIG.C_ALL_OUTPUTS_2 {1} \
		CONFIG.C_GPIO2_WIDTH {32} ] $axi_gpio_alu_operand

  set axi_gpio_alu_op [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_alu_op ]
  set_property -dict [ list CONFIG.C_ALL_INPUTS {0} \
		CONFIG.C_ALL_OUTPUTS {1} \
		CONFIG.C_GPIO_WIDTH {3} ] $axi_gpio_alu_op

  set axi_gpio_alu_res [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_alu_res ]
  set_property -dict [ list CONFIG.C_ALL_INPUTS {1} \
		CONFIG.C_ALL_OUTPUTS {0} \
		CONFIG.C_GPIO_WIDTH {32} \
		CONFIG.C_IS_DUAL {1} \
		CONFIG.C_ALL_INPUTS_2 {1} \
		CONFIG.C_ALL_OUTPUTS_2 {0} \
		CONFIG.C_GPIO2_WIDTH {3} ] $axi_gpio_alu_res

  # Create instance: axi_gpio to reg_file and set properties
  set axi_gpio_gpr_wr [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_gpr_wr ]
  set_property -dict [ list CONFIG.C_ALL_INPUTS {0} \
		CONFIG.C_ALL_OUTPUTS {1} \
		CONFIG.C_GPIO_WIDTH {5} \
		CONFIG.C_IS_DUAL {1} \
		CONFIG.C_ALL_INPUTS_2 {0} \
		CONFIG.C_ALL_OUTPUTS_2 {1} \
		CONFIG.C_GPIO2_WIDTH {32} ] $axi_gpio_gpr_wr

  set axi_gpio_gpr_wen [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_gpr_wen ]
  set_property -dict [ list CONFIG.C_ALL_INPUTS {0} \
		CONFIG.C_ALL_OUTPUTS {1} \
		CONFIG.C_GPIO_WIDTH {1} ] $axi_gpio_gpr_wen

  set axi_gpio_gpr_raddr [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_gpr_raddr ]
  set_property -dict [ list CONFIG.C_ALL_INPUTS {0} \
		CONFIG.C_ALL_OUTPUTS {1} \
		CONFIG.C_GPIO_WIDTH {5} \
		CONFIG.C_IS_DUAL {1} \
		CONFIG.C_ALL_INPUTS_2 {0} \
		CONFIG.C_ALL_OUTPUTS_2 {1} \
		CONFIG.C_GPIO2_WIDTH {5} ] $axi_gpio_gpr_raddr

  set axi_gpio_gpr_rdata [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_gpr_rdata ]
  set_property -dict [ list CONFIG.C_ALL_INPUTS {1} \
		CONFIG.C_ALL_OUTPUTS {0} \
		CONFIG.C_GPIO_WIDTH {32} \
		CONFIG.C_IS_DUAL {1} \
		CONFIG.C_ALL_INPUTS_2 {1} \
		CONFIG.C_ALL_OUTPUTS_2 {0} \
		CONFIG.C_GPIO2_WIDTH {32} ] $axi_gpio_gpr_rdata

  # Create instance: ps8_0_axi_periph, and set properties
  set ps8_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 ps8_0_axi_periph ]
  set_property -dict [ list CONFIG.NUM_MI {7} ] $ps8_0_axi_periph

  # Create instance: rst_ps8_0_99M, and set properties
  set rst_ps8_0_99M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_ps8_0_99M ]

  # Create instance: zynq_ultra_ps_e_0, and set properties
  set zynq_ultra_ps_e_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:zynq_ultra_ps_e:3.0 zynq_ultra_ps_e_0 ]
  set_property -dict [ list \
CONFIG.PSU_BANK_0_IO_STANDARD {LVCMOS18} \
CONFIG.PSU_BANK_2_IO_STANDARD {LVCMOS18} \
CONFIG.PSU_BANK_3_IO_STANDARD {LVCMOS33} \
CONFIG.PSU_DDR_RAM_HIGHADDR {0x7FFFFFFF} \
CONFIG.PSU_DDR_RAM_LOWADDR_OFFSET {0x80000000} \
CONFIG.PSU_MIO_TREE_PERIPHERALS {Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Feedback Clk#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#GPIO0 MIO#I2C 0#I2C 0#I2C 1#I2C 1#GPIO0 MIO#GPIO0 MIO#GPIO0 MIO#GPIO0 MIO#GPIO0 MIO#GPIO0 MIO#CAN 1#CAN 1#GPIO1 MIO#DPAUX#DPAUX#DPAUX#DPAUX#PCIE#UART 1#UART 1#UART 0#UART 0#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#SD 1#SD 1#SD 1#SD 1#SD 1#SD 1#SD 1#SD 1#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#MDIO 3#MDIO 3} \
CONFIG.PSU_MIO_TREE_SIGNALS {sclk_out#so_mo1#mo2#mo3#si_mi0#n_ss_out#clk_for_lpbk#n_ss_out_upper#mo_upper[0]#mo_upper[1]#mo_upper[2]#mo_upper[3]#sclk_out_upper#gpio0[13]#scl_out#sda_out#scl_out#sda_out#gpio0[18]#gpio0[19]#gpio0[20]#gpio0[21]#gpio0[22]#gpio0[23]#phy_tx#phy_rx#gpio1[26]#dp_aux_data_out#dp_hot_plug_detect#dp_aux_data_oe#dp_aux_data_in#reset_n#txd#rxd#rxd#txd#gpio1[36]#gpio1[37]#gpio1[38]#gpio1[39]#gpio1[40]#gpio1[41]#gpio1[42]#gpio1[43]#sdio1_wp#sdio1_cd_n#sdio1_data_out[0]#sdio1_data_out[1]#sdio1_data_out[2]#sdio1_data_out[3]#sdio1_cmd_out#sdio1_clk_out#ulpi_clk_in#ulpi_dir#ulpi_tx_data[2]#ulpi_nxt#ulpi_tx_data[0]#ulpi_tx_data[1]#ulpi_stp#ulpi_tx_data[3]#ulpi_tx_data[4]#ulpi_tx_data[5]#ulpi_tx_data[6]#ulpi_tx_data[7]#rgmii_tx_clk#rgmii_txd[0]#rgmii_txd[1]#rgmii_txd[2]#rgmii_txd[3]#rgmii_tx_ctl#rgmii_rx_clk#rgmii_rxd[0]#rgmii_rxd[1]#rgmii_rxd[2]#rgmii_rxd[3]#rgmii_rx_ctl#gem3_mdc#gem3_mdio_out} \
CONFIG.PSU__CAN1__GRP_CLK__ENABLE {0} \
CONFIG.PSU__CAN1__PERIPHERAL__ENABLE {1} \
CONFIG.PSU__CAN1__PERIPHERAL__IO {MIO 24 .. 25} \
CONFIG.PSU__CRF_APB__ACPU_CTRL__FREQMHZ {1200} \
CONFIG.PSU__CRF_APB__DDR_CTRL__FREQMHZ {1067} \
CONFIG.PSU__CRF_APB__DPDMA_REF_CTRL__FREQMHZ {600} \
CONFIG.PSU__CRF_APB__DPDMA_REF_CTRL__SRCSEL {APLL} \
CONFIG.PSU__CRF_APB__DP_AUDIO_REF_CTRL__SRCSEL {RPLL} \
CONFIG.PSU__CRF_APB__DP_STC_REF_CTRL__SRCSEL {RPLL} \
CONFIG.PSU__CRF_APB__DP_VIDEO_REF_CTRL__SRCSEL {VPLL} \
CONFIG.PSU__CRF_APB__GDMA_REF_CTRL__FREQMHZ {600} \
CONFIG.PSU__CRF_APB__GDMA_REF_CTRL__SRCSEL {APLL} \
CONFIG.PSU__CRF_APB__GPU_REF_CTRL__FREQMHZ {500} \
CONFIG.PSU__CRF_APB__GPU_REF_CTRL__SRCSEL {IOPLL} \
CONFIG.PSU__CRF_APB__TOPSW_MAIN_CTRL__FREQMHZ {533.33} \
CONFIG.PSU__CRF_APB__TOPSW_MAIN_CTRL__SRCSEL {DPLL} \
CONFIG.PSU__CRL_APB__AMS_REF_CTRL__FREQMHZ {52} \
CONFIG.PSU__CRL_APB__DLL_REF_CTRL__ACT_FREQMHZ {1499.985} \
CONFIG.PSU__CRL_APB__IOU_SWITCH_CTRL__FREQMHZ {250} \
CONFIG.PSU__CRL_APB__IOU_SWITCH_CTRL__SRCSEL {IOPLL} \
CONFIG.PSU__CRL_APB__PCAP_CTRL__ACT_FREQMHZ {187.498} \
CONFIG.PSU__CRL_APB__QSPI_REF_CTRL__ACT_FREQMHZ {124.999} \
CONFIG.PSU__CRL_APB__QSPI_REF_CTRL__FREQMHZ {125} \
CONFIG.PSU__CRL_APB__SDIO1_REF_CTRL__ACT_FREQMHZ {199.998} \
CONFIG.PSU__CRL_APB__TIMESTAMP_REF_CTRL__SRCSEL {IOPLL} \
CONFIG.PSU__CRL_APB__UART0_REF_CTRL__ACT_FREQMHZ {99.999} \
CONFIG.PSU__CSUPMU__PERIPHERAL__VALID {0} \
CONFIG.PSU__DDRC__BG_ADDR_COUNT {1} \
CONFIG.PSU__DDRC__CL {16} \
CONFIG.PSU__DDRC__CWL {14} \
CONFIG.PSU__DDRC__DEVICE_CAPACITY {8192 MBits} \
CONFIG.PSU__DDRC__DRAM_WIDTH {16 Bits} \
CONFIG.PSU__DDRC__ENABLE {1} \
CONFIG.PSU__DDRC__ROW_ADDR_COUNT {16} \
CONFIG.PSU__DDRC__SPEED_BIN {DDR4_2133P} \
CONFIG.PSU__DDRC__T_FAW {32} \
CONFIG.PSU__DDRC__T_RAS_MIN {36} \
CONFIG.PSU__DDRC__T_RC {52} \
CONFIG.PSU__DDRC__T_RCD {16} \
CONFIG.PSU__DDRC__T_RP {16} \
CONFIG.PSU__DDR__INTERFACE__FREQMHZ {533.500} \
CONFIG.PSU__DISPLAYPORT__PERIPHERAL__ENABLE {1} \
CONFIG.PSU__DLL__ISUSED {1} \
CONFIG.PSU__DPAUX__PERIPHERAL__IO {MIO 27 .. 30} \
CONFIG.PSU__DP__LANE_SEL {Single Lower} \
CONFIG.PSU__DP__REF_CLK_SEL {Ref Clk3} \
CONFIG.PSU__ENET3__GRP_MDIO__ENABLE {1} \
CONFIG.PSU__ENET3__PERIPHERAL__ENABLE {1} \
CONFIG.PSU__GPIO0_MIO__IO {MIO 0 .. 25} \
CONFIG.PSU__GPIO0_MIO__PERIPHERAL__ENABLE {1} \
CONFIG.PSU__GPIO1_MIO__IO {MIO 26 .. 51} \
CONFIG.PSU__GPIO1_MIO__PERIPHERAL__ENABLE {1} \
CONFIG.PSU__GPIO2_MIO__IO {MIO 52 .. 77} \
CONFIG.PSU__GPIO2_MIO__PERIPHERAL__ENABLE {1} \
CONFIG.PSU__I2C0__PERIPHERAL__ENABLE {1} \
CONFIG.PSU__I2C0__PERIPHERAL__IO {MIO 14 .. 15} \
CONFIG.PSU__I2C1__PERIPHERAL__ENABLE {1} \
CONFIG.PSU__I2C1__PERIPHERAL__IO {MIO 16 .. 17} \
CONFIG.PSU__PCIE__CLASS_CODE_SUB {0x4} \
CONFIG.PSU__PCIE__DEVICE_ID {0xD021} \
CONFIG.PSU__PCIE__DEVICE_PORT_TYPE {Root Port} \
CONFIG.PSU__PCIE__PERIPHERAL__ENABLE {1} \
CONFIG.PSU__PCIE__PERIPHERAL__ROOTPORT_IO {MIO 31} \
CONFIG.PSU__PROTECTION__MASTERS {USB1:NonSecure;0|USB0:NonSecure;1|S_AXI_LPD:NA;0|S_AXI_HPC1_FPD:NA;0|S_AXI_HPC0_FPD:NA;0|S_AXI_HP3_FPD:NA;0|S_AXI_HP2_FPD:NA;0|S_AXI_HP1_FPD:NA;0|S_AXI_HP0_FPD:NA;0|S_AXI_ACP:NA;0|S_AXI_ACE:NA;0|SD1:NonSecure;1|SD0:NonSecure;0|SATA1:NonSecure;1|SATA0:NonSecure;1|RPU1:Secure;1|RPU0:Secure;1|QSPI:NonSecure;1|PMU:NA;1|PCIe:NonSecure;1|NAND:NonSecure;0|LDMA:NonSecure;1|GPU:NonSecure;1|GEM3:NonSecure;1|GEM2:NonSecure;0|GEM1:NonSecure;0|GEM0:NonSecure;0|FDMA:NonSecure;1|DP:NonSecure;1|DAP:NA;1|Coresight:NA;1|CSU:NA;1|APU:NA;1} \
CONFIG.PSU__PROTECTION__SLAVES {LPD;USB3_1_XHCI;FE300000;FE3FFFFF;0|LPD;USB3_1;FF9E0000;FF9EFFFF;0|LPD;USB3_0_XHCI;FE200000;FE2FFFFF;1|LPD;USB3_0;FF9D0000;FF9DFFFF;1|LPD;UART1;FF010000;FF01FFFF;1|LPD;UART0;FF000000;FF00FFFF;1|LPD;TTC3;FF140000;FF14FFFF;1|LPD;TTC2;FF130000;FF13FFFF;1|LPD;TTC1;FF120000;FF12FFFF;1|LPD;TTC0;FF110000;FF11FFFF;1|FPD;SWDT1;FD4D0000;FD4DFFFF;0|LPD;SWDT0;FF150000;FF15FFFF;0|LPD;SPI1;FF050000;FF05FFFF;0|LPD;SPI0;FF040000;FF04FFFF;0|FPD;SMMU_REG;FD5F0000;FD5FFFFF;1|FPD;SMMU;FD800000;FDFFFFFF;1|FPD;SIOU;FD3D0000;FD3DFFFF;1|FPD;SERDES;FD400000;FD47FFFF;1|LPD;SD1;FF170000;FF17FFFF;1|LPD;SD0;FF160000;FF16FFFF;0|FPD;SATA;FD0C0000;FD0CFFFF;1|LPD;RTC;FFA60000;FFA6FFFF;1|LPD;RSA_CORE;FFCE0000;FFCEFFFF;1|LPD;RPU;FF9A0000;FF9AFFFF;1|FPD;RCPU_GIC;F9000000;F900FFFF;1|LPD;R5_TCM_RAM_GLOBAL;FFE00000;FFE3FFFF;1|LPD;R5_1_Instruction_Cache;FFEC0000;FFECFFFF;1|LPD;R5_1_Data_Cache;FFED0000;FFEDFFFF;1|LPD;R5_1_BTCM_GLOBAL;FFEB0000;FFEBFFFF;1|LPD;R5_1_ATCM_GLOBAL;FFE90000;FFE9FFFF;1|LPD;R5_0_Instruction_Cache;FFE40000;FFE4FFFF;1|LPD;R5_0_Data_Cache;FFE50000;FFE5FFFF;1|LPD;R5_0_BTCM_GLOBAL;FFE20000;FFE2FFFF;1|LPD;R5_0_ATCM_GLOBAL;FFE00000;FFE0FFFF;1|LPD;QSPI_Linear_Address;C0000000;DFFFFFFF;1|LPD;QSPI;FF0F0000;FF0FFFFF;1|LPD;PMU_RAM;FFDC0000;FFDDFFFF;1|LPD;PMU_GLOBAL;FFD80000;FFDBFFFF;1|FPD;PCIE_MAIN;FD0E0000;FD0EFFFF;1|FPD;PCIE_LOW;E0000000;EFFFFFFF;1|FPD;PCIE_HIGH2;8000000000;BFFFFFFFFF;1|FPD;PCIE_HIGH1;600000000;7FFFFFFFF;1|FPD;PCIE_DMA;FD0F0000;FD0FFFFF;1|FPD;PCIE_ATTRIB;FD480000;FD48FFFF;1|LPD;OCM_XMPU_CFG;FFA70000;FFA7FFFF;1|LPD;OCM_SLCR;FF960000;FF96FFFF;1|OCM;OCM;FFFC0000;FFFFFFFF;1|LPD;NAND;FF100000;FF10FFFF;0|LPD;MBISTJTAG;FFCF0000;FFCFFFFF;1|LPD;LPD_XPPU_SINK;FF9C0000;FF9CFFFF;1|LPD;LPD_XPPU;FF980000;FF98FFFF;1|LPD;LPD_SLCR_SECURE;FF4B0000;FF4DFFFF;1|LPD;LPD_SLCR;FF410000;FF4AFFFF;1|LPD;LPD_GPV;FE100000;FE1FFFFF;1|LPD;LPD_DMA_7;FFAF0000;FFAFFFFF;1|LPD;LPD_DMA_6;FFAE0000;FFAEFFFF;1|LPD;LPD_DMA_5;FFAD0000;FFADFFFF;1|LPD;LPD_DMA_4;FFAC0000;FFACFFFF;1|LPD;LPD_DMA_3;FFAB0000;FFABFFFF;1|LPD;LPD_DMA_2;FFAA0000;FFAAFFFF;1|LPD;LPD_DMA_1;FFA90000;FFA9FFFF;1|LPD;LPD_DMA_0;FFA80000;FFA8FFFF;1|LPD;IPI_CTRL;FF380000;FF3FFFFF;1|LPD;IOU_SLCR;FF180000;FF23FFFF;1|LPD;IOU_SECURE_SLCR;FF240000;FF24FFFF;1|LPD;IOU_SCNTRS;FF260000;FF26FFFF;1|LPD;IOU_SCNTR;FF250000;FF25FFFF;1|LPD;IOU_GPV;FE000000;FE0FFFFF;1|LPD;I2C1;FF030000;FF03FFFF;1|LPD;I2C0;FF020000;FF02FFFF;1|FPD;GPU;FD4B0000;FD4BFFFF;1|LPD;GPIO;FF0A0000;FF0AFFFF;1|LPD;GEM3;FF0E0000;FF0EFFFF;1|LPD;GEM2;FF0D0000;FF0DFFFF;0|LPD;GEM1;FF0C0000;FF0CFFFF;0|LPD;GEM0;FF0B0000;FF0BFFFF;0|FPD;FPD_XMPU_SINK;FD4F0000;FD4FFFFF;1|FPD;FPD_XMPU_CFG;FD5D0000;FD5DFFFF;1|FPD;FPD_SLCR_SECURE;FD690000;FD6CFFFF;1|FPD;FPD_SLCR;FD610000;FD68FFFF;1|FPD;FPD_GPV;FD700000;FD7FFFFF;1|FPD;FPD_DMA_CH7;FD570000;FD57FFFF;1|FPD;FPD_DMA_CH6;FD560000;FD56FFFF;1|FPD;FPD_DMA_CH5;FD550000;FD55FFFF;1|FPD;FPD_DMA_CH4;FD540000;FD54FFFF;1|FPD;FPD_DMA_CH3;FD530000;FD53FFFF;1|FPD;FPD_DMA_CH2;FD520000;FD52FFFF;1|FPD;FPD_DMA_CH1;FD510000;FD51FFFF;1|FPD;FPD_DMA_CH0;FD500000;FD50FFFF;1|LPD;EFUSE;FFCC0000;FFCCFFFF;1|FPD;Display Port;FD4A0000;FD4AFFFF;1|FPD;DPDMA;FD4C0000;FD4CFFFF;1|FPD;DDR_XMPU5_CFG;FD050000;FD05FFFF;1|FPD;DDR_XMPU4_CFG;FD040000;FD04FFFF;1|FPD;DDR_XMPU3_CFG;FD030000;FD03FFFF;1|FPD;DDR_XMPU2_CFG;FD020000;FD02FFFF;1|FPD;DDR_XMPU1_CFG;FD010000;FD01FFFF;1|FPD;DDR_XMPU0_CFG;FD000000;FD00FFFF;1|FPD;DDR_QOS_CTRL;FD090000;FD09FFFF;1|FPD;DDR_PHY;FD080000;FD08FFFF;1|DDR;DDR_LOW;0;7FFFFFFF;1|DDR;DDR_HIGH;800000000;800000000;0|FPD;DDDR_CTRL;FD070000;FD070FFF;1|LPD;Coresight;FE800000;FEFFFFFF;1|LPD;CSU_DMA;FFC80000;FFC9FFFF;1|LPD;CSU;FFCA0000;FFCAFFFF;0|LPD;CRL_APB;FF5E0000;FF85FFFF;1|FPD;CRF_APB;FD1A0000;FD2DFFFF;1|FPD;CCI_REG;FD5E0000;FD5EFFFF;1|FPD;CCI_GPV;FD6E0000;FD6EFFFF;1|LPD;CAN1;FF070000;FF07FFFF;1|LPD;CAN0;FF060000;FF06FFFF;0|FPD;APU;FD5C0000;FD5CFFFF;1|LPD;APM_INTC_IOU;FFA20000;FFA2FFFF;1|LPD;APM_FPD_LPD;FFA30000;FFA3FFFF;1|FPD;APM_5;FD490000;FD49FFFF;1|FPD;APM_0;FD0B0000;FD0BFFFF;1|LPD;APM2;FFA10000;FFA1FFFF;1|LPD;APM1;FFA00000;FFA0FFFF;1|LPD;AMS;FFA50000;FFA5FFFF;1|FPD;AFI_5;FD3B0000;FD3BFFFF;1|FPD;AFI_4;FD3A0000;FD3AFFFF;1|FPD;AFI_3;FD390000;FD39FFFF;1|FPD;AFI_2;FD380000;FD38FFFF;1|FPD;AFI_1;FD370000;FD37FFFF;1|FPD;AFI_0;FD360000;FD36FFFF;1|LPD;AFIFM6;FF9B0000;FF9BFFFF;1|FPD;ACPU_GIC;F9000000;F907FFFF;1} \
CONFIG.PSU__PSS_ALT_REF_CLK__ENABLE {0} \
CONFIG.PSU__QSPI__GRP_FBCLK__ENABLE {1} \
CONFIG.PSU__QSPI__PERIPHERAL__DATA_MODE {x4} \
CONFIG.PSU__QSPI__PERIPHERAL__ENABLE {1} \
CONFIG.PSU__QSPI__PERIPHERAL__IO {MIO 0 .. 12} \
CONFIG.PSU__QSPI__PERIPHERAL__MODE {Dual Parallel} \
CONFIG.PSU__SATA__LANE0__ENABLE {0} \
CONFIG.PSU__SATA__LANE1__ENABLE {1} \
CONFIG.PSU__SATA__LANE1__IO {GT Lane3} \
CONFIG.PSU__SATA__PERIPHERAL__ENABLE {1} \
CONFIG.PSU__SATA__REF_CLK_FREQ {125} \
CONFIG.PSU__SATA__REF_CLK_SEL {Ref Clk1} \
CONFIG.PSU__SD0__PERIPHERAL__ENABLE {0} \
CONFIG.PSU__SD1__DATA_TRANSFER_MODE {4Bit} \
CONFIG.PSU__SD1__GRP_CD__ENABLE {1} \
CONFIG.PSU__SD1__GRP_CD__IO {MIO 45} \
CONFIG.PSU__SD1__GRP_POW__ENABLE {0} \
CONFIG.PSU__SD1__GRP_WP__ENABLE {1} \
CONFIG.PSU__SD1__PERIPHERAL__ENABLE {1} \
CONFIG.PSU__SD1__PERIPHERAL__IO {MIO 46 .. 51} \
CONFIG.PSU__SD1__SLOT_TYPE {SD 2.0} \
CONFIG.PSU__TTC0__PERIPHERAL__ENABLE {1} \
CONFIG.PSU__TTC1__PERIPHERAL__ENABLE {1} \
CONFIG.PSU__TTC2__PERIPHERAL__ENABLE {1} \
CONFIG.PSU__TTC3__PERIPHERAL__ENABLE {1} \
CONFIG.PSU__UART0__BAUD_RATE {115200} \
CONFIG.PSU__UART0__PERIPHERAL__ENABLE {1} \
CONFIG.PSU__UART0__PERIPHERAL__IO {MIO 34 .. 35} \
CONFIG.PSU__UART1__PERIPHERAL__ENABLE {1} \
CONFIG.PSU__UART1__PERIPHERAL__IO {MIO 32 .. 33} \
CONFIG.PSU__USB0__PERIPHERAL__ENABLE {1} \
CONFIG.PSU__USB0__REF_CLK_SEL {Ref Clk2} \
CONFIG.PSU__USB2_0__EMIO__ENABLE {0} \
CONFIG.PSU__USB3_0__PERIPHERAL__ENABLE {1} \
CONFIG.PSU__USB3_0__PERIPHERAL__IO {GT Lane2} \
CONFIG.PSU__USE__IRQ0 {0} \
CONFIG.PSU__USE__M_AXI_GP2 {1} \
CONFIG.PSU__VIDEO_REF_CLK__ENABLE {0} \
 ] $zynq_ultra_ps_e_0

  # Create interface connections
  connect_bd_intf_net -intf_net ps8_0_axi_periph_M00_AXI [get_bd_intf_pins axi_gpio_alu_operand/S_AXI] [get_bd_intf_pins ps8_0_axi_periph/M00_AXI]
  connect_bd_intf_net -intf_net ps8_0_axi_periph_M01_AXI [get_bd_intf_pins axi_gpio_alu_op/S_AXI] [get_bd_intf_pins ps8_0_axi_periph/M01_AXI]
  connect_bd_intf_net -intf_net ps8_0_axi_periph_M02_AXI [get_bd_intf_pins axi_gpio_alu_res/S_AXI] [get_bd_intf_pins ps8_0_axi_periph/M02_AXI]
  connect_bd_intf_net -intf_net ps8_0_axi_periph_M03_AXI [get_bd_intf_pins axi_gpio_gpr_wr/S_AXI] [get_bd_intf_pins ps8_0_axi_periph/M03_AXI]
  connect_bd_intf_net -intf_net ps8_0_axi_periph_M04_AXI [get_bd_intf_pins axi_gpio_gpr_wen/S_AXI] [get_bd_intf_pins ps8_0_axi_periph/M04_AXI]
  connect_bd_intf_net -intf_net ps8_0_axi_periph_M05_AXI [get_bd_intf_pins axi_gpio_gpr_raddr/S_AXI] [get_bd_intf_pins ps8_0_axi_periph/M05_AXI]
  connect_bd_intf_net -intf_net ps8_0_axi_periph_M06_AXI [get_bd_intf_pins axi_gpio_gpr_rdata/S_AXI] [get_bd_intf_pins ps8_0_axi_periph/M06_AXI]
  connect_bd_intf_net -intf_net zynq_ultra_ps_e_0_M_AXI_HPM0_LPD [get_bd_intf_pins ps8_0_axi_periph/S00_AXI] [get_bd_intf_pins zynq_ultra_ps_e_0/M_AXI_HPM0_LPD]

  # Create port connections

  if {${::val} != "all"} {
	  set tie_gnd_32 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 tie_gnd_32 ]
	  set_property -dict [ list CONFIG.CONST_VAL {0} \
				CONFIG.CONST_WIDTH {32} ] $tie_gnd_32

	  if {${::val} == "reg_file"} {
		  set tie_gnd_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 tie_gnd_3 ]
		  set_property -dict [ list CONFIG.CONST_VAL {0} \
				CONFIG.CONST_WIDTH {3} ] $tie_gnd_3
	  }
  }

  if {${::val} == "alu" || ${::val} == "all"} {
	  # Create instance: u_alu, and set properties
	  set block_name alu
	  set block_cell_name u_alu
	  create_bd_cell -type module -reference $block_name $block_cell_name
	  
	  connect_bd_net -net axi_gpio_alu_operand_gpio_io_o [get_bd_pins u_alu/A] [get_bd_pins axi_gpio_alu_operand/gpio_io_o]
	  connect_bd_net -net axi_gpio_alu_operand_gpio2_io_o [get_bd_pins u_alu/B] [get_bd_pins axi_gpio_alu_operand/gpio2_io_o]
	  connect_bd_net -net axi_gpio_alu_op_gpio_io_o [get_bd_pins u_alu/ALUop] [get_bd_pins axi_gpio_alu_op/gpio_io_o]
	  connect_bd_net -net axi_gpio_alu_res_gpio_io_i [get_bd_pins u_alu/Result] [get_bd_pins axi_gpio_alu_res/gpio_io_i]
	  
	  set concat_alu_tag [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 concat_alu_tag ]
	  set_property -dict [ list CONFIG.NUM_PORTS {3} ] $concat_alu_tag
	  connect_bd_net [get_bd_pins u_alu/Overflow] [get_bd_pins concat_alu_tag/In0]
	  connect_bd_net [get_bd_pins u_alu/CarryOut] [get_bd_pins concat_alu_tag/In1]
	  connect_bd_net [get_bd_pins u_alu/Zero] [get_bd_pins concat_alu_tag/In2]
	  connect_bd_net -net axi_gpio_alu_res_gpio2_io_i [get_bd_pins concat_alu_tag/dout] [get_bd_pins axi_gpio_alu_res/gpio2_io_i]
  } else {
	  connect_bd_net -net gnd_3 [get_bd_pins tie_gnd_3/dout] [get_bd_pins axi_gpio_alu_res/gpio2_io_i]
	  connect_bd_net -net gnd_32 [get_bd_pins tie_gnd_32/dout] [get_bd_pins axi_gpio_alu_res/gpio_io_i]			
  }

  if {${::val} == "reg_file" || ${::val} == "all"} {
	  # Create instance: u_reg_file, and set properties
	  set block_name reg_file
	  set block_cell_name u_reg_file
	  create_bd_cell -type module -reference $block_name $block_cell_name

	  connect_bd_net -net axi_gpio_gpr_wr_gpio_io_o [get_bd_pins u_reg_file/waddr] [get_bd_pins axi_gpio_gpr_wr/gpio_io_o]
	  connect_bd_net -net axi_gpio_gpr_wr_gpio2_io_o [get_bd_pins u_reg_file/wdata] [get_bd_pins axi_gpio_gpr_wr/gpio2_io_o]
	  connect_bd_net -net axi_gpio_gpr_wen_gpio_io_o [get_bd_pins u_reg_file/wen] [get_bd_pins axi_gpio_gpr_wen/gpio_io_o]
	  connect_bd_net -net axi_gpio_gpr_raddr_gpio_io_o [get_bd_pins u_reg_file/raddr1] [get_bd_pins axi_gpio_gpr_raddr/gpio_io_o]
	  connect_bd_net -net axi_gpio_gpr_raddr_gpio2_io_o [get_bd_pins u_reg_file/raddr2] [get_bd_pins axi_gpio_gpr_raddr/gpio2_io_o]

	  connect_bd_net -net axi_gpio_gpr_rdata_gpio_io_i [get_bd_pins u_reg_file/rdata1] [get_bd_pins axi_gpio_gpr_rdata/gpio_io_i]
	  connect_bd_net -net axi_gpio_gpr_rdata_gpio2_io_i [get_bd_pins u_reg_file/rdata2] [get_bd_pins axi_gpio_gpr_rdata/gpio2_io_i]
  } else {
	  connect_bd_net -net gnd_32 [get_bd_pins tie_gnd_32/dout] \
				[get_bd_pins axi_gpio_gpr_rdata/gpio_io_i] \
				[get_bd_pins axi_gpio_gpr_rdata/gpio2_io_i]
  }

  connect_bd_net -net rst_ps8_0_99M_interconnect_aresetn [get_bd_pins ps8_0_axi_periph/ARESETN] \
				[get_bd_pins rst_ps8_0_99M/interconnect_aresetn]

  connect_bd_net -net rst_ps8_0_99M_peripheral_aresetn [get_bd_pins axi_gpio_alu_operand/s_axi_aresetn] \
				[get_bd_pins axi_gpio_alu_op/s_axi_aresetn] \
				[get_bd_pins axi_gpio_alu_res/s_axi_aresetn] \
				[get_bd_pins axi_gpio_gpr_wr/s_axi_aresetn] \
				[get_bd_pins axi_gpio_gpr_wen/s_axi_aresetn] \
				[get_bd_pins axi_gpio_gpr_raddr/s_axi_aresetn] \
				[get_bd_pins axi_gpio_gpr_rdata/s_axi_aresetn] \
				[get_bd_pins ps8_0_axi_periph/M00_ARESETN] \
				[get_bd_pins ps8_0_axi_periph/M01_ARESETN] \
				[get_bd_pins ps8_0_axi_periph/M02_ARESETN] \
				[get_bd_pins ps8_0_axi_periph/M03_ARESETN] \
				[get_bd_pins ps8_0_axi_periph/M04_ARESETN] \
				[get_bd_pins ps8_0_axi_periph/M05_ARESETN] \
				[get_bd_pins ps8_0_axi_periph/M06_ARESETN] \
				[get_bd_pins ps8_0_axi_periph/S00_ARESETN] \
				[get_bd_pins rst_ps8_0_99M/peripheral_aresetn]

  connect_bd_net -net zynq_ultra_ps_e_0_pl_clk0 [get_bd_pins axi_gpio_alu_operand/s_axi_aclk] \
				[get_bd_pins axi_gpio_alu_op/s_axi_aclk] \
				[get_bd_pins axi_gpio_alu_res/s_axi_aclk] \
				[get_bd_pins axi_gpio_gpr_wr/s_axi_aclk] \
				[get_bd_pins axi_gpio_gpr_wen/s_axi_aclk] \
				[get_bd_pins axi_gpio_gpr_raddr/s_axi_aclk] \
				[get_bd_pins axi_gpio_gpr_rdata/s_axi_aclk] \
				[get_bd_pins ps8_0_axi_periph/ACLK] \
				[get_bd_pins ps8_0_axi_periph/M00_ACLK] \
				[get_bd_pins ps8_0_axi_periph/M01_ACLK] \
				[get_bd_pins ps8_0_axi_periph/M02_ACLK] \
				[get_bd_pins ps8_0_axi_periph/M03_ACLK] \
				[get_bd_pins ps8_0_axi_periph/M04_ACLK] \
				[get_bd_pins ps8_0_axi_periph/M05_ACLK] \
				[get_bd_pins ps8_0_axi_periph/M06_ACLK] \
				[get_bd_pins ps8_0_axi_periph/S00_ACLK] \
				[get_bd_pins rst_ps8_0_99M/slowest_sync_clk] \
				[get_bd_pins zynq_ultra_ps_e_0/maxihpm0_lpd_aclk] \
				[get_bd_pins zynq_ultra_ps_e_0/pl_clk0]
  connect_bd_net -net zynq_ultra_ps_e_0_pl_resetn0 [get_bd_pins rst_ps8_0_99M/ext_reset_in] [get_bd_pins zynq_ultra_ps_e_0/pl_resetn0]

  if {${::val} == "reg_file" || ${::val} == "all"} {
	  set reg_file_reset [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 reg_file_reset ]
	  set_property -dict [ list CONFIG.C_OPERATION {not} \
				CONFIG.C_SIZE {1} ] $reg_file_reset
				
	  connect_bd_net -net rst_ps8_0_99M_peripheral_aresetn [get_bd_pins axi_gpio_alu_operand/s_axi_aresetn] \
				[get_bd_pins reg_file_reset/Op1]
	  
	  connect_bd_net [get_bd_pins reg_file_reset/Res] [get_bd_pins u_reg_file/rst]
	  
	  connect_bd_net -net zynq_ultra_ps_e_0_pl_clk0 [get_bd_pins axi_gpio_alu_operand/s_axi_aclk] \
				[get_bd_pins u_reg_file/clk]
  }

  # Create address segments
  create_bd_addr_seg -range 0x00010000 -offset 0x80000000 [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axi_gpio_alu_operand/S_AXI/Reg] SEG_axi_gpio_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x80010000 [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axi_gpio_alu_op/S_AXI/Reg] SEG_axi_gpio_1_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x80020000 [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axi_gpio_alu_res/S_AXI/Reg] SEG_axi_gpio_2_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x80030000 [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axi_gpio_gpr_wr/S_AXI/Reg] SEG_axi_gpio_3_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x80040000 [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axi_gpio_gpr_wen/S_AXI/Reg] SEG_axi_gpio_4_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x80050000 [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axi_gpio_gpr_raddr/S_AXI/Reg] SEG_axi_gpio_5_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x80060000 [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axi_gpio_gpr_rdata/S_AXI/Reg] SEG_axi_gpio_6_Reg

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


