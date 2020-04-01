# parsing argument
if {$argc != 3} {
	puts "Error: The argument should be hw_act val output_dir"
	exit
} else {
	set act [lindex $argv 0]
	set val [lindex $argv 1]
	set out_dir [lindex $argv 2]
}

set project_name prj_0
	
# setting parameters
set topmodule_src_fpga mpsoc_wrapper

set bd_design mpsoc
set device xczu2eg-sfva625-1-e
set board interwiser:none:part0:2.0

set src_dir sources/ip_catalog
set tb_dir sources/testbench

set prj_file ${project_name}/${project_name}.xpr

set script_dir [file dirname [info script]]

set rtl_chk_dir ${script_dir}/../vivado_out/rtl_chk
set synth_rpt_dir ${script_dir}/../vivado_out/synth_rpt
set impl_rpt_dir ${script_dir}/../vivado_out/impl_rpt
set dcp_dir ${script_dir}/../vivado_out/dcp
set sim_out_dir ${script_dir}/../vivado_out/sim

if {$act == "rtl_chk" || $act == "sch_gen" || $act == "bhv_sim" || $act == "bit_gen"} {
	# setting up the project
	create_project ${project_name} -force -dir "./${project_name}" -part ${device}
	set_property board_part ${board} [current_project] 

	# add source files
	add_files -norecurse -fileset sources_1 ${script_dir}/../${src_dir}/adder.v
	add_files -norecurse -fileset sources_1 ${script_dir}/../${src_dir}/counter.v

	if {$act == "rtl_chk" || $act == "sch_gen"} {
		if {$val != "adder" && $val != "counter"} {
			puts "Error: Your specified module name does not exist"
			exit
		}

		# setting top module of sources_1 (set to FPGA top when creating this project)
		set_property "top" ${val} [get_filesets sources_1]
	} elseif {$act == "bhv_sim"} {

		set sim_mod [lindex $val 0]
		set sim_time [lindex $val 1]
		
		if {![string is double $sim_time]} {
			error "Invalid input parameter: $sim_time. Please input a decimal value to indicate \
					the number of micro-seconds (us) for simulation"
			exit
		}
		
		if {${sim_mod} != "adder" && ${sim_mod} != "counter"} { 
			error "Invalid input parameter: $sim_mod. Please input either adder or counter for behavioral simulation"
			exit
		}

		# add testbed file to sim_1
		add_files -norecurse -fileset sim_1 ${script_dir}/../${tb_dir}/${sim_mod}_test.v
		update_compile_order -fileset [get_filesets sim_1]

		# set simulator
		set_property target_simulator "XSim" [current_project]

		set_property "top" ${sim_mod}_test [get_filesets sim_1]

		set_property runtime ${sim_time}us [get_filesets sim_1]
		set_property xsim.simulate.custom_tcl ${script_dir}/sim/xsim_run.tcl [get_filesets sim_1]

	} elseif {$act == "bit_gen"} {

		#set constraints file of pin location
		add_files -fileset constrs_1 -norecurse ${script_dir}/../constraints/prj0_phy_pin.xdc

		# create Block design
		foreach sub_bd ${bd_design} {
			source ${script_dir}/${sub_bd}.tcl
			
			set_property synth_checkpoint_mode None [get_files ./${project_name}/${project_name}.srcs/sources_1/bd/${sub_bd}/${sub_bd}.bd]
			generate_target all [get_files ./${project_name}/${project_name}.srcs/sources_1/bd/${sub_bd}/${sub_bd}.bd]
			
			make_wrapper -files [get_files ./${project_name}/${project_name}.srcs/sources_1/bd/${sub_bd}/${sub_bd}.bd] -top
			import_files -force -norecurse -fileset sources_1 ./${project_name}/${project_name}.srcs/sources_1/bd/${sub_bd}/hdl/${sub_bd}_wrapper.v
			
			validate_bd_design
			save_bd_design
			close_bd_design ${sub_bd}
		}
		update_compile_order -fileset [get_filesets sources_1]

		# setting top module of sources_1 (set to FPGA top when creating this project)
		set_property "top" ${topmodule_src_fpga} [get_filesets sources_1]

		# setting Synthesis options
		set_property strategy {Vivado Synthesis defaults} [get_runs synth_1]
		# keep module port names in the netlist
		set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY {none} [get_runs synth_1]

		# setting Implementation options
		set_property steps.phys_opt_design.is_enabled true [get_runs impl_1]
		# the following implementation options will increase runtime, but get the best timing results
		#set_property strategy Performance_Explore [get_runs impl_1]
	}

	set_property source_mgmt_mode None [current_project]

	# Vivado operations
	if {$act == "rtl_chk" || $act == "sch_gen"} {
		# calling elabrated design
		synth_design -rtl -rtl_skip_constraints -rtl_skip_ip -top ${val}

		if {$act == "sch_gen"} {
			write_schematic -format pdf -force ${rtl_chk_dir}/${val}_sch.pdf
		}

	} elseif {$act == "bhv_sim"} {
		launch_simulation -mode behavioral -simset [get_filesets sim_1] 
	} elseif {$act == "bit_gen"} {
		set rpt_prefix synth
	
		# Generate HDF
		write_hwdef -force -file ${out_dir}/system.hdf

		# synthesizing design
		synth_design -top ${topmodule_src_fpga} -part ${device}

		# setup output logs and reports
		write_checkpoint -force ${dcp_dir}/${rpt_prefix}.dcp

		report_utilization -hierarchical -file ${synth_rpt_dir}/${rpt_prefix}_util_hier.rpt
		report_utilization -file ${synth_rpt_dir}/${rpt_prefix}_util.rpt
		report_timing_summary -file ${synth_rpt_dir}/${rpt_prefix}_timing.rpt -delay_type max -max_paths 1000

		# Processing opt_design, placement, routing and bitstream generation
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
	close_project

	if {$act == "sch_gen"} {
		exit
	}

} elseif {$act == "wav_chk"} {

	if {$val != "adder" && $val != "counter"} {
		puts "Error: Please specify the name of waveform to be opened"
		exit
	}

	current_fileset

	open_wave_database ${sim_out_dir}/${val}.wdb
	open_wave_config ${sim_out_dir}/${val}.wcfg

} else {
	puts "Error: No specified actions for Vivado hardware project"
	exit
}

