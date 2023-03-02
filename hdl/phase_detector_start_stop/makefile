# Makefile

TOPLEVEL_LANG = verilog
VERILOG_SOURCES = phase_detector_start_stop.sv ../library/sync.sv
TOPLEVEL = phase_detector_start_stop
MODULE = phase_detector_start_stop_tb
SIM = verilator
EXTRA_ARGS += --trace --trace-structs
COCOTB_HDL_TIMEPRECISION = 1fs

include $(shell cocotb-config --makefiles)/Makefile.sim
