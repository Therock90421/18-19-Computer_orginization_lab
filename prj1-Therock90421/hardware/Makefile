HW_ROOT := $(shell pwd)

# Hardware install file
O ?= $(HW_ROOT)
HDF_INSTALL := $(O)/system.hdf
BIT_INSTALL := $(O)/system.bit

# Vivado Auto-run tcl scripts
VIVADO_PRJ_TCL := $(HW_ROOT)/scripts/mk.tcl
VIVADO_FILE_TCL := $(HW_ROOT)/scripts/file_cp.tcl

ifneq ($(findstring $(HW_ACT), "sch_gen dcp_chk wav_chk"), )
VIVADO_MODE := gui
else
VIVADO_MODE := batch
endif

ifneq ($(findstring $(HW_ACT), "bit_gen bhv_sim pst_sim"), )
VIVADO_FILE_CP := y
else
VIVADO_FILE_CP := n
endif

VIVADO_PRJ_FLAGS := -nojournal -nolog -mode $(VIVADO_MODE) -source $(VIVADO_PRJ_TCL) -tclargs $(HW_ACT) "$(HW_VAL)" $(O)

ifeq (${VIVADO_FILE_CP},y)
VIVADO_FILE_FLAGS := -nojournal -nolog -mode batch -source $(VIVADO_FILE_TCL) -tclargs $(HW_ACT) "$(HW_VAL)"
endif

# Locations of Vivado project and generated files
VIVADO_PRJ_LOC := $(HW_ROOT)/vivado_prj
RTL_CHK_LOC := $(HW_ROOT)/vivado_out/rtl_chk
SYNTH_RPT_LOC := $(HW_ROOT)/vivado_out/synth_rpt
IMPL_RPT_LOC := $(HW_ROOT)/vivado_out/impl_rpt
DCP_LOC := $(HW_ROOT)/vivado_out/dcp
SIM_LOC := $(HW_ROOT)/vivado_out/sim
VIVADO_LOG_LOC := $(HW_ROOT)/vivado_out/run_log

DIR_GEN_OBJ := $(VIVADO_PRJ_LOC) $(RTL_CHK_LOC) $(SYNTH_RPT_LOC) \
				$(IMPL_RPT_LOC) $(SIM_LOC) $(VIVADO_LOG_LOC) $(DCP_LOC)

# Generation of .bit.bin file
BIT_BOOT_GEN_FLAGS := -w on -process_bitstream bin -arch zynqmp

BIT_BIF_FILE := $(HW_ROOT)/scripts/bit_bin_gen.bif 
BIT_BIN_INSTALL := $(O)/system.bit.bin

BIT_BOOT_GEN_FLAGS += -image $(BIT_BIF_FILE) -o $(BIT_BIN_INSTALL)

.PHONY: FORCE

ifeq (${HW_ACT},none)
vivado_prj: FORCE
	$(error Please specify the action to be lanuched for Vivado hardware design)
else
vivado_prj: FORCE
	@mkdir -p $(DIR_GEN_OBJ)
ifeq (${VIVADO_MODE},batch)
	cd $(VIVADO_PRJ_LOC) && $(VIVADO) $(VIVADO_PRJ_FLAGS) 2>&1 | tee $(VIVADO_LOG_LOC)/$(HW_ACT).log
else
	cd $(VIVADO_PRJ_LOC) && $(VIVADO) $(VIVADO_PRJ_FLAGS)
endif
ifeq (${VIVADO_FILE_CP},y)
	cd $(VIVADO_PRJ_LOC) && $(VIVADO) $(VIVADO_FILE_FLAGS)
endif
endif

ifneq ($(wildcard $(BIT_INSTALL)), )
bit_bin: FORCE
	$(BOOT_GEN) $(BIT_BOOT_GEN_FLAGS)
else
bit_bin: FORCE
	$(error Please launch "make HW_ACT=bit_gen vivado_prj" first to \
		save bitstream file in the directory of <work_dir>/ready_for_download)
endif

vivado_prj_clean:
	@rm -rf $(VIVADO_PRJ_LOC)

hw_gen_clean:
	@rm -f $(HDF_INSTALL) $(BIT_INSTALL) $(BIT_BIN_INSTALL) 

