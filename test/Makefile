
# Makefile for synchronous FIFO simulation using Cocotb

# Simulator settings
SIM ?= icarus
FST ?= -fst
TOPLEVEL_LANG ?= verilog

# Source directory
SRC_DIR = $(PWD)/../src

# FIFO design source files
PROJECT_SOURCES = \
    FIFO_SYNCHRONOUS.v \
    tt_um_fifo.v

# RTL simulation
ifneq ($(GATES),yes)

SIM_BUILD = sim_build/rtl

VERILOG_SOURCES += $(addprefix $(SRC_DIR)/,$(PROJECT_SOURCES))
VERILOG_SOURCES += $(PWD)/tb.v

else

# Gate-level simulation
SIM_BUILD = sim_build/gl

COMPILE_ARGS += -DGL_TEST
COMPILE_ARGS += -DFUNCTIONAL
COMPILE_ARGS += -DUSE_POWER_PINS
COMPILE_ARGS += -DSIM
COMPILE_ARGS += -DUNIT_DELAY=\#1

VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v
VERILOG_SOURCES += $(PWD)/gate_level_netlist.v

endif

# Include directory for Verilog files
COMPILE_ARGS += -I$(SRC_DIR)

# Testbench configuration
TOPLEVEL = tb
COCOTB_TEST_MODULES = test

# Cocotb simulator rules
include $(shell cocotb-config --makefiles)/Makefile.sim

