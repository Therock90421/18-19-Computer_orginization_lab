if {${::act} == "bhv_sim"} {
	set sim_mod behav
} else {
	set sim_mod time_synth
}

if {![file exists ${::sim_out_dir}/${sim_mod}.wcfg]} {
	exec cp ${::script_dir}/sim/${sim_mod}.wcfg ${::sim_out_dir}
}

open_wave_config ${::sim_out_dir}/${sim_mod}.wcfg

set wave_obj [get_waves *]

foreach wave ${wave_obj} {
	set wave_fmt "add_wave \{\{$wave\}\}"

	eval ${wave_fmt}
}

run ${::sim_time}us
