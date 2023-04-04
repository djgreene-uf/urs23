# Makefile

TOPLEVEL_LANG = verilog
VERILOG_SOURCES = shifted_clock_sampling.sv ../library/sync.sv ../library/dff.sv
TOPLEVEL = shifted_clock_sampling
MODULE = shifted_clock_sampling_tb
SIM = verilator
EXTRA_ARGS += --trace --trace-structs
COCOTB_HDL_TIMEPRECISION = 1fs

include $(shell cocotb-config --makefiles)/Makefile.sim
