Project #2 (prj2) in Experiments of Computer Organization and Design (COD) in UCAS
=====
<changyisong@ict.ac.cn>
-----

## MIPS CPU Benchmarks

In this project, we provide three benchmark suites for simulation and FPGA on-board evaluation 
of your own single-cycle MIPS CPU core design. 
You can launch simulation or evaluation with a specified benchmark by explicitly setting 
parameters of benchmark suite name and serial number in MAKE command line.  

### Basic Benchmark Suite

| **Serial Number** | **Benchmark Name** | **Description** |
| :---------------: | :----------------: | :-------------: |
| 00 | test | User's own instruction stream |
| 01 | memcpy | Simple memory copy function for 100 consecuitive 32-bit words |

*memcpy* benchmark in this suite is used during the 1st phase of this project in which 
implementation of 5 basic MIPS CPU instructions is required. 
On the other hand, *test* benchmark is used to support custom instruction stream for each 
phase of this project, which provides a simple test environment for early debugging of 
your instruction implementations within a short simulation duration of 2us. 
Please note that ** *test* benchmark is not used for FPGA on-board evaluation**.  

### Medium Benchmark Suite

| **Serial Number** | **Benchmark Name** | **Description** |
| :---------------: | :----------------: | :-------------: |
| 01 | sum | Calculate the summary of 1 to 100 |
| 02 | mov-c | Move data to an array |
| 03 | fib | Check fibonacci number of 2 to 40 |
| 04 | add | Check 64 additions with pre-calculated answers  |
| 05 | if-else | Check conditional jump using if-else statement |
| 06 | pascal | Calculate pascal numbers |
| 07 | quick-sort | Quick sort |
| 08 | select-sort | Selection sort |
| 09 | max | Decide the larger number |
| 10 | min3 | Decide the smallest number among the three |
| 11 | switch | Check jump instructions using switch-case statement |
| 12 | bubble-sort | Bubble sort |

Medium benchmark suite is used during the 2nd phase of this project which requires to implement 
10 more MIPS CPU instructions. 
The order of each benchmark in the above list is arranged according to the complexisity degree and scale 
of leveraged instructions. 
From this point of view, benchmark *sum* is the simplest one in medium benchmark suite.   

### Advanced Benchmark Suite

| **Serial Number** | **Benchmark Name** | **Description** |
| :---------------: | :----------------: | :-------------: |
| 01 | shuixianhua | Check the number of narcissistic numbers among 100 to 500 |
| 02 | sub-longlong | Check 64 subtractions on double word integers |
| 03 | bit | Simulate bit operations using shift and bit-logic operators |
| 04 | recursion | Test recursive calls |
| 05 | fact | Check factorials from 0 to 12 |
| 06 | add-longlong | Check additions on double word integers |
| 07 | shift | Test shift operations |
| 08 | wanshu | Check the perfect number from 1 to 30 |
| 09 | goldbach | Verify Goldbach's conjecture for 4 to 30 |
| 10 | leap-year | Check if it is a leap year from 1980 |
| 11 | prime | Test prime number using soft mod calculation |
| 12 | mul-longlong | Test multiplication on double word integers (soft mul) |
| 13 | load-store | Check laod and store, including unaligned memory access |
| 14 | to-lower-case | Convert ASCII character to lower case if possible |
| 15 | movsx | Check memory access on byte |
| 16 | matrix-mul | Calculate matrix multiplication (soft mul) |
| 17 | unalign | Unaligned memory access |

Advanced benchmark suite is used during the 3rd phase of this project which requires to implement 
29 more MIPS CPU instructions. 
The order of each benchmark in the above list is arranged according to the number instructions. 


## Hardware Design

Please note that all the following commands are launched 
in the top-level directory of your local repository.  

### RTL Design

Please finish your RTL coding for ALU, register file and single-cycle MIPS CPU first 
by editing *alu.v*, *reg_file.v* and *mips_cpu.v* respectively in the directory of 
*hardware/sources/ip_catalog/mips_core* according to 
functional requirements as described in lecture slides of this project. 

1. Using `make HW_ACT=rtl_chk vivado_prj`  
to recursively check syntax and synthesizability of 
all your RTL source files from the top module *mips_cpu_top*. 
Please carefully modify and optimize your RTL code according to 
errors and warnings you would meet in this step.  

### Behavioral Simulation

1. Executing `make HW_ACT=bhv_sim HW_VAL=<benchmark_suite_name>:<benchmark_serial_nubmer> vivado_prj`  
to run behavioral simulation for your MIPS CPU design using a specified benchmark. 
The valid string of *<benchmark_suite_name>* should be among *basic*, *medium* and *advanced*. 
*<benchmark_serial_number>* must be a valid value according to the list of each benchmark suite.
For example, you can launch behavioral simulation of *memcpy* in *basic* benchmark suite via  
`make HW_ACT=bhv_sim HW_VAL=basic:01 vivado_prj`  
**Please note that only one valid serial number of benchmark should be used in this command**.  

2. After simulation, please use  
`make HW_ACT=wav_chk HW_VAL=bhv vivado_prj`  
to check the waveform of behavioral simulation in Vivado GUI mode. 
You can change (add or remove signals to be observed) 
the waveform configuration file (.wcfg) and save it under Vivado GUI 
when running this step. 
If you want to observe the modified waveform, please re-launch 
behavioral simulation (*HW_ACT=bhv_sim*) and waveform checking (*HW_ACT=wav_chk*). 
If you modify RTL source code to solve problems in logical design, 
please return to RTL checking (*HW_ACT=rtl_chk*) first and walk through the following steps.  

### Bitstream Generation

1. If you fix logical functions of your RTL code via 
recursive execution from RTL design to behavioral simulation, 
please launch  
`make HW_ACT=bit_gen vivado_prj`  
to generate system.bit in the top-level *hw_plat* directory via automatic 
synthesis, optimization, placement and routing.  

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

1. In order to launch evaluation, please use 
`make USER=<user_name> HW_VAL=<bench_suite_name> cloud_run`  
in the top-level directory of your local repository 
to connect to the FPGA cloud.   
* *<bench_suite_name>* must be a valid string among *basic*, *medium* and *advanced*.  
-- For example, a student named Zhangsan could launch   
`make USER=zhangsan HW_VAL=advanced cloud_run`  
to start a full evaluation of the *advanced* benchmark suite 
on our FPGA cloud. 

