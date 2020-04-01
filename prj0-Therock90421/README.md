Project #0 (prj0) in Experiments of Computer Organization and Design (COD) in UCAS
=====
<changyisong@ict.ac.cn>
-----

## Hardware Design

### RTL Design

Please finish your RTL coding for both adder and counter first 
by editing *adder.v* and *counter.v* respectively in the directory of 
*hardware/sources/ip_catalog* according to 
the functional requirement in lecture slides.  

### Vivado FPGA Project

If not specified, Vivado toolset is launched in batch mode in this project 
as default. 

1. Using `make HW_ACT=rtl_chk HW_VAL=<check_target> vivado_prj`  
to check syntax and synthesizability of your RTL source code. 
*<check_target>* should be specified as either 
*adder* or *counter*. 
For example, you can check your RTL design of adder.v using  
`make HW_ACT=rtl_chk HW_VAL=adder vivado_prj`  
Please carefully modify and optimize your RTL code according to 
all errors and warnings you would meet in this step. 

2. If there are no errors occurring in Step 1, 
please use `make HW_ACT=sch_gen HW_VAL=<check_target> vivado_prj`  
to re-launch RTL checking in Vivado GUI mode and 
generate RTL schematics of your specified module name 
by replacing *<check_target>* to either *adder* or *counter*. 
For example, if you want to generate a schematic of adder.v, please use  
`make HW_ACT=sch_gen HW_VAL=adder vivado_prj`  
The generated schematics in PDF version are located 
in the directory of *hardware/vivado_out/rtl_chk*. 
You can check the generated schematics via a PDF viewer.  

3. Executing `make HW_ACT=bhv_sim HW_VAL="<sim_target> <sim_time>" vivado_prj`  
to run behavioral simulation for your specified target RTL module within a required duration. 
The valid string of *<sim_target>* should be either *adder* or *counter*. 
*<sim_time>* must be a positive real number and the simulation timescale is set to 
micro-second (us) as default (i.e., <sim_time>=0.2 means 200ns). 
Please note that *<sim_target>* and *<sim_time>* must be kept between quotes. 
For example, you can launch behavioral simulation for *adder* module within 2us via  
`make HW_ACT=bhv_sim HW_VAL="adder 2" vivado_prj`  

4. After simulation, please use  
`make HW_ACT=wav_chk HW_VAL=<sim_target> vivado_prj`  
to check the waveform of behavioral simulation in Vivado GUI mode. 
The valid string of *<sim_target>* should be either *adder* or *counter*. 
For example, you can observe waveform of *adder* simulation via  
`make HW_ACT=wav_chk HW_VAL=adder vivado_prj`  
You can change (add or remove signals to be observed) 
the waveform configuration file (.wcfg) and save it under Vivado GUI 
when running this step. 
If you want to observe the modified waveform, please re-launch 
behavioral simulation (Step 4) and waveform checking (Step 5). 
If you modify your RTL code to fix logical problems, 
please return back to Step 2 first.  

6. If you fix logical functions of your RTL code via 
recursive execution from Step 2 to Step 5, 
please launch  
`make HW_ACT=bit_gen vivado_prj`  
to generate system.bit in the top-level *hw_plat* directory via automatic 
synthesis, optimization, placement and routing. 
A debug probe file named *debug_nets.ltx* 
would be generated in the top-level *hw_plat* directory as well.  

7. Launching `make bit_bin`  
to generate the binary bitstream file (system.bit.bin) used for FPGA on-board 
evaluation later in the top-level *hw_plat* directory.   

## FPGA Evaluation

We provide an FPGA cloud infrastructure 
for evaluation of this project, 
using a set of custom commands for 
hardware-software co-verification. 
The FPGA cloud is open-accessed 
any time any where via network 
until the course of this term finishes.  

1. In order to launch evaluation, please use either  
`make USER=<user_name> cloud_run`  
to connect to the FPGA cloud.

Using the FPGA cloud, hardware debugging environment would be automatically 
opened under Vivado GUI for observation of virtual I/O (VIO) interface. 

2. For evaluation using the FPGA cloud, please open the VIO control panel 
as introduced in lecture slides.  

3. Commands for hardware-software co-verification are 
input in the shell terminal to interact with the ARM-end executable software. 
In this project, we provide the following commands to control 
custom-designed adder and counter logic via ARM-end software. 

| **Command** | **Function** | **Result Observation** |
| :---------: | :----------: | :-------------: |
| `add <op1> <op2>` | Sending two input 8-bit decimal integers (0 to 255) to hardware adder | Displaying result via LED for local FPGA boards and via VIO for the FPGA cloud |
| state reset | Resetting hardware counter | No specified output after execution |
| state run | Starting hardware counter | No specified output after execution |
| state halt | Halting hardware counter | No specified output after execution |
| `interval <data>` | Setting the number of cycles (represented as an input decimal integer) after which the hardware counter increments | No specified output after execution |
| count | Returning the current value of hardware counter | Displaying a decimal integer as the counter value in the shell terminal |
| help | Displaying command formats | -- |
| quit | Exiting evaluation | -- |

