# parsing argument
if {$argc != 3} {
	puts "Error: The argument should be hw_act val output_dir"
	exit
} else {
	set act [lindex $argv 0]
	set val [lindex $argv 1]
	set out_dir [lindex $argv 2]
}

set project_name prj_5
	
# setting parameters
if {$act == "bhv_sim" || $act == "pst_sim" } {
	set bd_design bram_bd
} else {
	set bd_design mpsoc
}

set device xczu2eg-sfva625-1-e
set board interwiser:none:part0:2.0
set mips_dir sources/ip_catalog/mips_core
set dnn_acc_dir sources/ip_catalog/dnn_acc
set mips_top_dir sources/hdl
set dnn_acc_vh_dir sources/include
set tb_dir sources/testbench

set prj_file ${project_name}/${project_name}.xpr

set script_dir [file dirname [info script]]

set rtl_chk_dir ${script_dir}/../vivado_out/rtl_chk
set synth_rpt_dir ${script_dir}/../vivado_out/synth_rpt
set impl_rpt_dir ${script_dir}/../vivado_out/impl_rpt
set dcp_dir ${script_dir}/../vivado_out/dcp
set sim_out_dir ${script_dir}/../vivado_out/sim

set bench_dir ${script_dir}/../../benchmark

#========================================================
# Main flow
#========================================================
if {$act == "rtl_chk" || $act == "sch_gen" || $act == "bhv_sim" || $act == "pst_sim" || $act == "bit_gen"} {

	# setting up the project
	create_project ${project_name} -force -dir "./${project_name}" -part ${device}
	set_property board_part ${board} [current_project]
	
	# MIPS source files
	add_files -norecurse -fileset sources_1 ${script_dir}/../${mips_dir}/

	# MIPS top module and ideal memory
	add_files -norecurse -fileset sources_1 ${script_dir}/../${mips_top_dir}/mips_cpu_top.v

	# complete project setup
	if {$act == "rtl_chk" || $act == "sch_gen" } {
		if {$act == "sch_gen"} {
			set module_src [get_files *${val}.v]
			if {${module_src} == ""} {
				puts "Error: No such specified module for RTL schematics generation"
				exit
			}
			set top_module ${val}

		} else {
			set top_module mips_cpu_top
		}

	} else {
		if {$act == "bhv_sim" || $act == "pst_sim" } {
			add_files -fileset constrs_1 -norecurse ${script_dir}/../constraints/mips_cpu_simu.xdc

			#parse names of benchmark and suite it belongs to 
			set bench_suite [lindex $val 0]
			set bench_name [lindex $val 1]
			set sim_time [lindex $val 2]

			if {$act == "bhv_sim"} {
				set_property verilog_define { {MIPS_CPU_FULL_SIMU} {UART_SIM} } [get_filesets sources_1]
				set_property verilog_define { {MIPS_CPU_FULL_SIMU} {UART_SIM} } [get_filesets sim_1]
			} else {
				set_property verilog_define { {MIPS_CPU_FULL_SIMU} } [get_filesets sources_1]
				set_property verilog_define { {MIPS_CPU_FULL_SIMU} } [get_filesets sim_1]
			}

			# add instruction stream for simulation
			exec cp ${bench_dir}/${bench_suite}/sim/${bench_name}.coe ${sim_out_dir}/inst.coe
			puts $bench_name

			# Generate IPs of AXI bram controller and block ram for simulation 
			source ${script_dir}/mips_bram.tcl

			set_property synth_checkpoint_mode None [get_files ./${project_name}/${project_name}.srcs/sources_1/bd/${bd_design}/${bd_design}.bd]
			generate_target all [get_files ./${project_name}/${project_name}.srcs/sources_1/bd/${bd_design}/${bd_design}.bd]
		
			make_wrapper -files [get_files ./${project_name}/${project_name}.srcs/sources_1/bd/${bd_design}/${bd_design}.bd] -top
			import_files -force -norecurse -fileset sources_1 ./${project_name}/${project_name}.srcs/sources_1/bd/${bd_design}/hdl/${bd_design}_wrapper.v

			validate_bd_design
			save_bd_design
			close_bd_design ${bd_design}

			# set verilog simulator 
			set_property target_simulator "XSim" [current_project]

			# add testbed file and set top module to sim_1
			add_files -norecurse -fileset sim_1 ${script_dir}/../${tb_dir}/mips_cpu_test.v
			add_files -norecurse -fileset sim_1 ${script_dir}/../${tb_dir}/uart_recv_sim.v
			set_property "top" mips_cpu_test [get_filesets sim_1]
			update_compile_order -fileset [get_filesets sim_1]

		} else {
			
			# create Board Design (BD) with ZynqMP
			add_files -norecurse -fileset sources_1 ${script_dir}/../${mips_top_dir}/axi_lite_if.v

			set hw_acc [lindex $val 0]
			set ila_cfg_num [lindex $val 1] 

			# Add dnn_acc dcp file
			if {$hw_acc == "acc"} {
				add_files -norecurse -fileset sources_1 ${script_dir}/../${dnn_acc_dir}/dnn_acc_top.dcp
				set_property verilog_define { {USE_DDR} {USE_DNN_ACC} } [get_filesets sources_1]
			} else {
				set_property verilog_define { {USE_DDR} } [get_filesets sources_1]
			}
		
			# Generate block design of mpsoc for implementation 
			source ${script_dir}/mpsoc.tcl
		
			set_property synth_checkpoint_mode None [get_files ./${project_name}/${project_name}.srcs/sources_1/bd/${bd_design}/${bd_design}.bd]
			generate_target all [get_files ./${project_name}/${project_name}.srcs/sources_1/bd/${bd_design}/${bd_design}.bd]
		
			make_wrapper -files [get_files ./${project_name}/${project_name}.srcs/sources_1/bd/${bd_design}/${bd_design}.bd] -top
			import_files -force -norecurse -fileset sources_1 ./${project_name}/${project_name}.srcs/sources_1/bd/${bd_design}/hdl/${bd_design}_wrapper.v

			validate_bd_design
			save_bd_design
			close_bd_design mpsoc

			# setup ILA hardware debugger if HW_ACT is specified 
			if {${ila_cfg_num} != "0"} {
				set i 0
				while {$i < ${ila_cfg_num}} {
					set idx [expr $i + 2]
					set ila_conf [lindex $val $idx]
					source ${script_dir}/ila.tcl
					
					set_property synth_checkpoint_mode None [get_files ./${project_name}/${project_name}.srcs/sources_1/bd/${ila_conf}/${ila_conf}.bd]
					generate_target all [get_files ./${project_name}/${project_name}.srcs/sources_1/bd/${ila_conf}/${ila_conf}.bd]
				
					make_wrapper -files [get_files ./${project_name}/${project_name}.srcs/sources_1/bd/${ila_conf}/${ila_conf}.bd] -top
					import_files -force -norecurse -fileset sources_1 ./${project_name}/${project_name}.srcs/sources_1/bd/${ila_conf}/hdl/${ila_conf}_wrapper.v
				
					validate_bd_design
					save_bd_design
					close_bd_design ${ila_conf}

					incr i 1
				}
			}
		}
		
		# setting top module of sources_1
		add_files -norecurse -fileset sources_1 ${script_dir}/../${mips_top_dir}/mips_cpu_fpga.v
		set top_module mips_cpu_fpga
	}

	set_property "top" ${top_module} [get_filesets sources_1]
	update_compile_order -fileset [get_filesets sources_1]
	
	if {$act == "pst_sim" || $act == "bit_gen"} {
		# setting Synthesis options
		set_property strategy {Vivado Synthesis defaults} [get_runs synth_1]
		# keep module port names in the netlist
		set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY {none} [get_runs synth_1]

		# setting Implementation options
		set_property steps.phys_opt_design.is_enabled true [get_runs impl_1]
		# the following implementation options will increase runtime, but get the best timing results
		set_property strategy Performance_Explore [get_runs impl_1]

		# Generate HDF
		if {$act == "bit_gen"} {
			write_hwdef -force -file ${out_dir}/system.hdf
		}
	}

	set_property source_mgmt_mode None [current_project]
	# Vivado operations
	if {$act == "rtl_chk" || $act == "sch_gen"} {

		# calling elabrated design
		synth_design -rtl -rtl_skip_constraints -rtl_skip_ip -top ${top_module}

		if {$act == "sch_gen"} {
			write_schematic -format pdf -force ${rtl_chk_dir}/${top_module}_sch.pdf
		}

	} elseif {$act == "pst_sim" || $act == "bit_gen"} {
		if {$act == "pst_sim"} {
			set rpt_prefix pst_sim
		} else {
			set rpt_prefix synth
		}

		# synthesizing design
		synth_design -top mips_cpu_fpga -part ${device} -flatten_hierarchy none

		# setup output logs and reports
		write_checkpoint -force ${dcp_dir}/${rpt_prefix}.dcp

		report_utilization -hierarchical -file ${synth_rpt_dir}/${rpt_prefix}_util_hier.rpt
		report_utilization -file ${synth_rpt_dir}/${rpt_prefix}_util.rpt
		report_timing_summary -file ${synth_rpt_dir}/${rpt_prefix}_timing.rpt -delay_type max -max_paths 1000

		# Processing opt_design, placement, routing and bitstream generation
		if {$act == "bit_gen"} {

			# Design optimization
			opt_design
			
			# Save debug nets file
			write_debug_probes -force ${out_dir}/debug_nets.ltx

			# Placement
			place_design

			report_clock_utilization -file ${impl_rpt_dir}/clock_util.rpt

			# Physical design optimization
			phys_opt_design
		
			write_checkpoint -force ${dcp_dir}/place.dcp

			report_utilization -file ${impl_rpt_dir}/post_place_util.rpt
			report_timing_summary -file ${impl_rpt_dir}/post_place_timing.rpt -delay_type max -max_paths 1000

			# routing
			route_design

			write_checkpoint -force ${dcp_dir}/route.dcp
	
			report_utilization -file ${impl_rpt_dir}/post_route_util.rpt
			report_timing_summary -file ${impl_rpt_dir}/post_route_timing.rpt -delay_type max -max_paths 1000

			report_route_status -file ${impl_rpt_dir}/post_route_status.rpt

			# bitstream generation
			write_bitstream -force ${out_dir}/system.bit
		}
	}

	# launching simulation
	if {$act == "bhv_sim" || $act == "pst_sim"} { 

		# launch simulation
		set_property runtime ${sim_time}us [get_filesets sim_1]
		set_property xsim.simulate.custom_tcl ${script_dir}/sim/xsim_run.tcl [get_filesets sim_1]

		if {$act == "bhv_sim"} {
			launch_simulation -mode behavioral -simset [get_filesets sim_1] 
		} else {
			launch_simulation -mode post-synthesis -type timing -simset [get_filesets sim_1]
		}
	}
	close_project

	if {$act == "sch_gen"} {
		exit
	}

} elseif {$act == "wav_chk"} {

	if {$val != "pst" && $val != "bhv"} {
		puts "Error: Please specify the name of waveform to be opened"
		exit
	}

	current_fileset

	if {$val == "bhv"} {
		set file_name behav
	} else {
		set file_name time_synth
	}

	open_wave_database ${sim_out_dir}/${file_name}.wdb
	open_wave_config ${sim_out_dir}/${file_name}.wcfg

} else {
	puts "Error: No specified actions for Vivado hardware project"
	exit
}

