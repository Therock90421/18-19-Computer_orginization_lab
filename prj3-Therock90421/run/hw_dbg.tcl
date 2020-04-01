# parsing argument
if {$argc != 1} {
	puts "Error: The argument should be hw_server_ip_address"
} else {
	set xvc_server_ip [lindex $argv 0]
}

set xvc_port 2542

set probe_file ../../hw_plat/debug_nets.ltx

if {[file exist ${probe_file}] == 0} {
	puts "Error: No Debug Nets probing file"
	exit
}

# Open Vivado Hardware Manager
open_hw

# Connect hw_server via localhost:3121
connect_hw_server

# Open hardware target
open_hw_target -xvc_url ${xvc_server_ip}:${xvc_port}
current_hw_target [lindex [get_hw_targets] 0]

# Set ILA probes to hardware device
set cur_dev [get_hw_devices]
set_property PROBES.FILE ${probe_file} [lindex ${cur_dev} 0]

refresh_hw_device [lindex ${cur_dev} 0]

