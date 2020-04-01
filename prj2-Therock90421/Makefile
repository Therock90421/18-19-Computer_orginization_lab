# TODO: Change to your Vivado IDE version and installed location
VIVADO_VERSION ?= 2017.2
VIVADO_TOOL_BASE ?= /opt/Xilinx

# Vivado and SDK tool executable binary location
VIVADO_TOOL_PATH := $(VIVADO_TOOL_BASE)/Vivado/$(VIVADO_VERSION)/bin
SDK_TOOL_PATH := $(VIVADO_TOOL_BASE)/SDK/$(VIVADO_VERSION)/bin

# Leveraged Vivado tools
VIVADO_BIN := $(VIVADO_TOOL_PATH)/vivado
HSI_BIN := $(SDK_TOOL_PATH)/hsi
BOOT_GEN_BIN := $(SDK_TOOL_PATH)/bootgen

# Temporal directory to hold hardware design output files 
# (i.e., bitstream, hardware definition file (HDF))
HW_PLATFORM := $(shell pwd)/hw_plat
BITSTREAM := $(HW_PLATFORM)/system.bit
HW_DESIGN_HDF := $(HW_PLATFORM)/system.hdf

# HW_ACT list
#==========================================
# rtl_chk: 		Checking RTL syntax and synthesizability in this project
# sch_gen:		Generating gate-level schematic of a RTL module
# bhv_sim:		Launching behavioral simulation and 
# 				dumping the waveform file (.wdb)
# pst_sim:		Launching post-synthesis timing simulation and 
# 				dumping the waveform file (.wdb)
# wav_chk:		Opening waveform file of behavior or timing simulation
# bit_gen:		Generating the bitstream file (.bit) via automatically 
# 				launching synthesis and implementation
#==========================================
# Default Vivado GUI launching flags if not specified in command line
HW_ACT ?= none
HW_VAL ?= none

ifeq ($(findstring $(HW_ACT), "none bhv_sim pst_sim"), )
BENCH ?= basic:01
else
ifeq ($(HW_VAL),none)
BENCH ?= basic:01
else
BENCH ?= $(HW_VAL)
endif
endif

BENCH_SUITE := $(shell echo $(BENCH) | awk -F ":" '{print $$1}')
ifeq ($(findstring $(BENCH_SUITE), "basic medium advanced"), )
$(error Please carefully specify name of benchmark suite among basic, medium and advaced)
endif

BENCH_NUM := $(shell echo $(BENCH) | awk -F ":" '{print $$2}')
BENCH_NAME := $(shell cat $(shell pwd)/benchmark/$(BENCH_SUITE)/list | grep "\#$(BENCH_NUM)" | awk -F "," '{print $$2}')
SIM_TIME := $(shell cat $(shell pwd)/benchmark/$(BENCH_SUITE)/list | grep "\#$(BENCH_NUM)" | awk -F "," '{print $$3}')


ifeq (${BENCH_NUM}, )
BENCH_NUM := all
endif

ifeq ($(findstring $(HW_ACT), "bhv_sim pst_sim"), )
HW_VAL_USE := $(HW_VAL)
else
ifeq (${BENCH_NAME}, )
$(error Please carefully specify the serial number of benchmark)
endif
HW_VAL_USE := $(BENCH_SUITE) $(BENCH_NAME) $(SIM_TIME)
endif

# FPGA Evaluation
FPGA_RUN := $(shell pwd)/run/fpga_run.sh 

USER ?= none

BOARD_IP ?= none

RUN_LOG=cloud_run_$(BENCH_SUITE)_bench

.PHONY: FORCE

#==========================================
# Hardware Design
#==========================================
vivado_prj: FORCE
	@echo "Executing $(HW_ACT) for Vivado project..."
	@mkdir -p $(HW_PLATFORM)
	@-git checkout -- run/log
	$(MAKE) -C ./hardware VIVADO=$(VIVADO_BIN) HW_ACT=$(HW_ACT) HW_VAL="$(HW_VAL_USE)" O=$(HW_PLATFORM) $@
	@-git add --all && git commit -m "autocmt: $@ HW_ACT=$(HW_ACT) HW_VAL=\"$(HW_VAL)\""

bit_bin:
	@echo "Generating .bit.bin file for system.bit..."
	$(MAKE) -C ./hardware BOOT_GEN=$(BOOT_GEN_BIN) O=$(HW_PLATFORM) $@

#==========================================
# Cloud environment usage
#==========================================
cloud_run:
ifneq (${USER},none)
	@mkdir -p ./run/log
	@cd ./run && LOG_LEVEL=$(LOG_LEVEL) bash $(FPGA_RUN) $(VIVADO_BIN) n cloud $(USER) $(BENCH_SUITE) "$(BENCH_NUM)" \
				| tee ./log/$(RUN_LOG)_tmp.log
	@date >> ./run/log/$(RUN_LOG)_tmp.log
	@mv ./run/log/$(RUN_LOG).log ./run/log/$(RUN_LOG)_old.log
	@cat ./run/log/$(RUN_LOG)_tmp.log > ./run/log/$(RUN_LOG).log
	@echo "------------------------------" >> ./run/log/$(RUN_LOG).log
	@cat ./run/log/$(RUN_LOG)_old.log >> ./run/log/$(RUN_LOG).log
	@rm -f ./run/log/$(RUN_LOG)_*.log
	@-git add --all && git commit -m "autocmt: $@ USER=$(USER) HW_VAL=$(HW_VAL)"
else
	$(error Please correctly set your user name for cloud environment)
endif

#==========================================
# Local environment usage
#==========================================
local_run:
ifneq (${BOARD_IP},none)
	@mkdir -p ./run/log
	@cd ./run && LOG_LEVEL=$(LOG_LEVEL) bash $(FPGA_RUN) $(VIVADO_BIN) n local $(BOARD_IP) $(BENCH_SUITE) "$(BENCH_NUM)" \
				| tee ./log/local_run_$(BENCH_SUITE)_bench.log
	@date >> ./run/log/local_run_$(BENCH_SUITE)_bench.log
	@-git add --all && git commit -m "autocmt: $@ HW_VAL=$(HW_VAL)"
else
	$(error Please correctly set IP address of the FPGA board)
endif

