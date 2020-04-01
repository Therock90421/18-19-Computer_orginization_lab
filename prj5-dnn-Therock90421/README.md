Project #5 (prj5) in Experiments of Computer Organization and Design (COD) in UCAS
=====
<changyisong@ict.ac.cn>
-----

## Benchmarks Running on MIPS core

| **Serial Number** | **Benchmark Name** | **Description** |
| :---------------: | :----------------: | :-------------: |
| 01 | sw-conv | Software implementation of 2-D convolution and pooling algorithms |
| 02 | hw-conv | Software to control the hardware convolution accelerator |

Source files of both benchmarks are located in the directory of *benchmark/src*. 
Please execute `make conv` to compile both benchmarks.  

## Hardware Design

### RTL Design

Please finish your RTL coding for ALU, register file and single-cycle MIPS CPU first 
by editing *alu.v*, *reg_file.v* and *mips_cpu.v* respectively in the directory of 
*hardware/sources/ip_catalog/mips_core* according to 
functional requirements as described in lecture slides of this project. 
If an additional module is necessary in your design, please edit a new source file 
designated with the name of this module in *hardware/sources/ip_catalog/mips_core*
and suppliment instantiation of this module in *mips_cpu.v*.    

1. Using `make HW_ACT=rtl_chk vivado_prj`  
to recursively check syntax and synthesizability of 
all your RTL source files from the top module *mips_cpu_top*. 
Please carefully modify and optimize your RTL code according to 
errors and warnings you would meet in this step.  

2. If there are no errors or warnings occurring in Step 1, 
please use `make HW_ACT=sch_gen HW_VAL=<check_target> vivado_prj`  
to re-launch RTL checking in Vivado GUI mode and 
generate RTL schematics of your specified module name 
by replacing *<check_target>* to a module name located in *hardware/sources/ip_catalog/mips_core*. 
For example, if you want to generate a schematic of reg_file.v, please use  
`make HW_ACT=sch_gen HW_VAL=reg_file vivado_prj`  
The generated schematics in PDF version named *<check_target>_sch.pdf* 
are located in the directory of *hardware/vivado_out/rtl_chk*. 
You can check the generated schematics via a PDF viewer.  

### Behavioral Simulation

1. Executing `make HW_ACT=bhv_sim HW_VAL=conv:01 vivado_prj`  
to run behavioral co-simulation for both your MIPS CPU design and 
software implementation of convolution and pooling algorithms.  
Please note that simuation of hardware accelerator is **not supported** in this project. 

2. After simulation, please use  
`make HW_ACT=wav_chk HW_VAL=bhv vivado_prj`  
to check the waveform of behavioral simulation in Vivado GUI mode. 
You can change (add or remove signals to be observed) 
the waveform configuration file (.wcfg) and save it under Vivado GUI 
when running this step. 
If you want to observe the modified waveform, please re-launch 
behavioral simulation (*HW_ACT=bhv_sim*) and waveform checking (*HW_ACT=wav_chk*). 
If you modify RTL source code to solve problems in logical design, /
please return to RTL checking (*HW_ACT=rtl_chk*) first and walk through the following steps.  

### Post-synthesis Timing Simulation

Post-synthesis timing simulation is **not supported** in this project. 

### Bitstream Generation

1. If you fix logical functions of your RTL code via 
recursive execution from RTL design to post-synthesis timing simulation, 
please launch  
`make HW_ACT=bit_gen HW_VAL=<hw_acc> vivado_prj`  
to generate system.bit in the top-level *hw_plat* directory via automatic 
synthesis, optimization, placement and routing.  
* *<hw_acc>* can be set as either *no_acc* or *acc* for bitstream generation 
w/o or w/ hardware accelerator respectively.  

2. Launching `make bit_bin`  
to generate the binary bitstream file (system.bit.bin) used for FPGA on-board 
evaluation later in the top-level *hw_plat* directory.   

## FPGA Evaluation

We provide an FPGA cloud infrastructure as well as a set of 
local FPGA boards for evaluation of this project, 
both of which use the same set of commands for 
hardware-software co-verification. 
Local FPGA boards can be leveraged only in class, while 
the FPGA cloud is open-accessed any time any where via network 
until the course of this term finishes. 

1. In order to launch evaluation, please use either  
`make USER=<user_name> HW_VAL="<benchmark_list>" cloud_run`  
to connect to the FPGA cloud, or  
`make BOARD_IP=<board_ip> HW_VAL="<benchmark_list>" local_run`  
to connect to a local FPGA board. 
The valid value in *<benchmark_list>* can be either *conv:01* or *conv:02*.  
