# Makefile
# Hardened for Native Verilog Testbench Verification

# defaults
SIM ?= icarus
FST ?= -fst # Use more efficient FST format
TOPLEVEL_LANG ?= verilog
SRC_DIR = $(PWD)/../src

# 1. Map all your custom AES design files located in the src/ directory:
PROJECT_SOURCES = tt_um_aes_128_wrapper.v aes_top.v sbox.v key_expansion.v mixcolumns.v mixcolumns_one_column.v shiftrows.v subbytes.v

ifneq ($(GATES),yes)

# RTL simulation setup:
SIM_BUILD        = sim_build/rtl
# Pull in the original behavioral source files from the src/ folder
VERILOG_SOURCES += $(addprefix $(SRC_DIR)/,$(PROJECT_SOURCES))

else

# Gate level simulation setup:
SIM_BUILD        = sim_build/gl
COMPILE_ARGS    += -DGL_TEST
COMPILE_ARGS    += -DFUNCTIONAL
COMPILE_ARGS    += -DSIM
VERILOG_SOURCES += $(PDK_ROOT)/ihp-sg13g2/libs.ref/sg13g2_io/verilog/sg13g2_io.v
VERILOG_SOURCES += $(PDK_ROOT)/ihp-sg13g2/libs.ref/sg13g2_stdcell/verilog/sg13g2_stdcell.v

# The synthesized physical blueprint netlist copied over by OpenLane
VERILOG_SOURCES += $(PWD)/gate_level_netlist.v

endif

# Allow sharing configuration between design and testbench via `include`:
COMPILE_ARGS    += -I$(SRC_DIR)

# 2. Append your custom Verilog testbench file (Make sure tb_aes_top.v is uploaded to your test/ folder):
VERILOG_SOURCES += $(PWD)/tb_aes_top.v

# 3. Direct the simulator to target your testbench top module name:
TOPLEVEL = tb_aes_top

# 4. Clear out the template's dummy Python script runner entirely:
COCOTB_TEST_MODULES =

# Include standard compiler rules to manage the hardware simulator execution tree
include $(shell cocotb-config --makefiles)/Makefile.sim
