Format Description of Custom ILA Configuration File
=====
<changyisong@ict.ac.cn>
-----

## File Name (<file_name>.cfg)
No blank is permitted in <file_name> string. 
All .cfg files are located in this directory.  

## Basic Format
<ila_sampling_depth>  
<probing_signal_num>  
<probe_signal_0_name> <probe_signal_0_bit_width>  
<probe_signal_1_name> <probe_signal_1_bit_width>  
<probe_signal_2_name> <probe_signal_2_bit_width>  
...  

### <ila_sampling_depth> (integer)
Valid values of this parameter include 1024, 2048, 4096 and 8192.  

### <probing_signal_num> (integer)
Determining the number of following lines to describe each logic signal you want to probe 
during hardware debugging. The value should be 256 at most.

### <probe_signal_name> (string)
No blank is permitted in this string.

### <probe_signal_bit_width> (integer)
If the bit-width is one, you can omit this field and just leave the signal name alone 
on that line.

