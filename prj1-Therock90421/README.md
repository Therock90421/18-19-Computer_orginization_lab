Project #1 (prj1) in Experiments of Computer Organization and Design (COD) in UCAS
=====
<changyisong@ict.ac.cn>
-----

## Hardware Design

### RTL Design

Please finish your RTL coding for register file and ALU first 
by editing *reg_file.v* and *alu.v* respectively in the directory of 
*hardware/sources/ip_catalog* according to 
the functional requirement in lecture slides.  

### Vivado FPGA Project

If not specified, Vivado toolset is launched in batch mode in this project 
as default. 

Please note that all make commands are launched in the top-level 
directory of your local repository.

1. Using `make HW_ACT=rtl_chk HW_VAL=<check_target> vivado_prj`  
to check syntax and synthesizability of your RTL source code. 
*<check_target>* should be specified as either 
*reg_file* or *alu*. 
For example, you can check your RTL design of reg_file.v using  
`make HW_ACT=rtl_chk HW_VAL=reg_file vivado_prj`  
Please carefully modify and optimize your RTL code according to 
all errors and warnings you would meet in this step. 

2. If there are no errors occurring in Step 1, 
please use `make HW_ACT=sch_gen HW_VAL=<check_target> vivado_prj`  
to re-launch RTL checking in Vivado GUI mode and 
generate RTL schematics of your specified module name 
by replacing *<check_target>* to either *reg_file* or *alu*. 
For example, if you want to generate a schematic of reg_file.v, please use  
`make HW_ACT=sch_gen HW_VAL=reg_file vivado_prj`  
The generated schematics in PDF version are located 
in the directory of *hardware/vivado_out/rtl_chk*. 
You can check the generated schematics via a PDF viewer.  

3. Executing `make HW_ACT=bhv_sim HW_VAL="<sim_target> <sim_time>" vivado_prj`  
to run behavioral simulation for your specified target RTL module within a required duration. 
The valid string of *<sim_target>* should be either *reg_file* or *alu*. 
*<sim_time>* must be a positive decimal number and the simulation timescale is set to 
micro-second (us) as default (i.e., <sim_time>=0.2 means 200ns). 
Please note that *<sim_target>* and *<sim_time>* must be kept between quotes.  
For example, you can launch behavioral simulation for *reg_file* module within 2us via  
`make HW_ACT=bhv_sim HW_VAL="reg_file 2" vivado_prj`  

4. After simulation, please use  
`make HW_ACT=wav_chk HW_VAL=<sim_target> vivado_prj`  
to check the waveform of behavioral simulation in Vivado GUI mode. 
The valid string of *<sim_target>* should be either *reg_file* or *alu*. 
For example, you can observe simulation waveform of 
*reg_file* module via  
`make HW_ACT=wav_chk HW_VAL=reg_file vivado_prj`  
You can change (add or remove signals to be observed) 
the waveform configuration file (.wcfg) and save it under Vivado GUI 
when running this step. 
If you want to observe the modified waveform, please re-launch 
behavioral simulation (Step 3) and waveform checking (Step 4). 
If you modify RTL source code to solve problems in logical design, 
please return to RTL checking (Step 1) first and walk through the following steps.  

5. If you fix logical functions of your RTL code via 
recursive execution from Step 1 to Step 4, 
please launch  
`make HW_ACT=bit_gen HW_VAL=<bit_gen_target> vivado_prj`  
to generate system.bit in the top-level *hw_plat* directory via automatic 
synthesis, optimization, placement and routing.  
The default value of *<bit_gen_target>* that is unnecessary to explictly specify 
in MAKE command line is *all*, which means both *reg_file* and 
*alu* modules will be involved in the bitstream generation flow. 
Please note that RTL source code of both *reg_file* and *alu* module 
must be well-prepared before launching the default bitstream generation flow. 
You can specify the value of *<bit_gen_target>* as either 
*reg_file* or *alu* to generate a bitstream for single module evaluation.  

6. Launching `make bit_bin`  
to generate the binary bitstream file (system.bit.bin) used for FPGA on-board 
evaluation later in the top-level *hw_plat* directory.   

## FPGA Evaluation

We provide a FPGA cloud infrastructure as well as a set of 
local FPGA boards for evaluation of this project, 
both of which use the same set of commands for 
hardware-software co-verification. 
Local FPGA boards can be leveraged only in class, while 
the FPGA cloud is open-accessed any time any where via network 
until the course of this term finishes. 

1. In order to launch evaluation, please use either  
`make USER=<user_name> cloud_run`  
to connect to the FPGA cloud, or  
`make BOARD_IP=<board_ip> local_run`  
to connect to a local FPGA board.  

2. Commands for hardware-software co-verification are 
input in the shell terminal to interact with ARM-end executable software. 
In this project, we provide the following commands to control 
custom-designed adder and counter logic via ARM-end software. 

| **Command** | **Function** | **Result Observation** |
| :---------: | :----------: | :-------------: |
| reg_file_eval | Launching automatic evaluation flow for register file | Echoing "Test passed" or "Test failed" |
| alu_eval | Launching automatic evaluation flow for ALU | Echoing "Test passed" or "Test failed" |
| help | Displaying command formats | -- |
| quit | Exiting evaluation | -- |

