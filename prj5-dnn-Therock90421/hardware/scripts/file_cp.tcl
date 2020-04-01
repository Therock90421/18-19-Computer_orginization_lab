# parsing argument
if {$argc != 1} {
	puts "The argument should be hw_act"
} else {
	set act [lindex $argv 0]
}

set project_name prj_5

set script_dir [file dirname [info script]]

set impl_rpt_dir ${script_dir}/../vivado_out/impl_rpt
set sim_out_dir ${script_dir}/../vivado_out/sim

if {$act == "pst_sim"} {
	exec cp ./${project_name}/${project_name}.sim/sim_1/synth/timing/mips_cpu_test_time_synth.wdb \
		${sim_out_dir}/time_synth.wdb

} elseif {$act == "bit_gen"} {
	# load webtalk log
	exec cp ./${project_name}/usage_statistics_webtalk.xml ${impl_rpt_dir} 

} elseif {$act == "bhv_sim"} {
	exec cp ./${project_name}/${project_name}.sim/sim_1/behav/mips_cpu_test_behav.wdb \
		${sim_out_dir}/behav.wdb

} else {
	puts "Error: No specified actions for Vivado hardware project"
	exit
}
