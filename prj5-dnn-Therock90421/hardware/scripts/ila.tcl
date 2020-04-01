#========================================================
# Vivado BD design auto run script for ILA in ZYPI
# Based on Vivado 2017.2
# Author: Ran Zhao (zhaoran@ict.ac.cn)
# Date: 28/2/2018
#========================================================

namespace eval ila_bd {
	set design_name ila
}
set ila_bd::design_name ${ila_conf}

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]
if { ${ila_bd::design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

}

if { ${ila_bd::design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne ${ila_bd::design_name} } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <${ila_bd::design_name}> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq ${ila_bd::design_name} } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <${ila_bd::design_name}> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${ila_bd::design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <${ila_bd::design_name}> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <${ila_bd::design_name}> in project, so creating one..."

   create_bd_design ${ila_bd::design_name}

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <${ila_bd::design_name}> as current_bd_design."
   current_bd_design ${ila_bd::design_name}

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"${ila_bd::design_name}\"."

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

  # Setup ILA PROBE port according to custom ILA configuration file
  set ila_cfg_file ${::script_dir}/dbg/${::ila_conf}.cfg

  set cfg_exist [ file exist ${ila_cfg_file} ]

  if {${cfg_exist} == 0} {
	  puts "Error: No such ILA configuration file ${ila_cfg_file}"
	  exit
  }

  # Create instance: ILA
  set mpsoc_ila [ create_bd_cell -type ip -vlnv xilinx.com:ip:system_ila:1.0 ${ila_bd::design_name} ]

  set_property -dict [ list CONFIG.C_MON_TYPE {NATIVE} \
						CONFIG.C_PROBE_WIDTH_PROPAGATION {MANUAL}\
						CONFIG.C_BRAM_CNT {0.5} ] $mpsoc_ila

  # Open configuration file in read-only mode
  set fd [ open ${ila_cfg_file} r ]

  # get the first line as the ILA sampling depth
  set ila_depth [ gets $fd ]
  if {${ila_depth} == ""} {
	  puts stdout "Error: Wrong format of ILA configuration file. \
					Please specify the value of sampling depth on the first line."
	  exit
  }
  set_property CONFIG.C_DATA_DEPTH ${ila_depth} ${mpsoc_ila}

  # get the second line as the number of probe signals in ILA
  set ila_probe_num [ gets $fd ]
  if {${ila_probe_num} == ""} {
	  puts stdout "Error: Wrong format of ILA configuration file. \
					Please specify the value of probing signals on the second line."
	  exit
  }
  set_property CONFIG.C_NUM_OF_PROBES ${ila_probe_num} ${mpsoc_ila}

  set i 0
  while {$i < ${ila_probe_num}} {
	  set probe_cfg [ gets $fd ]
	  if {${probe_cfg} == ""} {
		  puts stdout "Error: Not enough probing signals in current configuration file"
		  exit
	  }

	  set net_name [ lindex ${probe_cfg} 0]

	  if {[llength ${probe_cfg}] == 1} {
		  set bit_width 1
	  } elseif {[llength ${probe_cfg}] == 2} {
		  set bit_width [ lindex ${probe_cfg} 1 ]
	  } else {
		  puts stdout "Error: Wrong configuration format of probing signal. \
						Please use the format \"<net_name> <bit_width>\" \
						If <bit_width> is 1, please omit it and leave <net_name> alone on that line"
		  exit
	  }
	  
	  set_property CONFIG.C_PROBE${i}_WIDTH ${bit_width} ${mpsoc_ila}

	  # Create ports and net
	  create_bd_port -dir I -from [expr ${bit_width} - 1] -to 0 ${net_name}
	  connect_bd_net -net ${net_name} [get_bd_ports ${net_name}] [get_bd_pins ${ila_bd::design_name}/probe${i}]
	  
	  incr i 1
  }

  # Add clock ports
  create_bd_port -dir I -type clk ila_clk
  connect_bd_net -net ila_clk [get_bd_ports ila_clk] [get_bd_pins ${ila_bd::design_name}/clk]

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

