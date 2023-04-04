# Makefile

TOPLEVEL_LANG = verilog
VERILOG_SOURCES = phase_detector_combined.sv \
				  ../library/sync.sv \
				  ../library/dff.sv \
				  ../library/dff_sync_rst.sv \
				  ../library/pulse_extender.sv \
				  ../library/level_to_pulse.sv \
			      ../library/delay.sv \
				  ../library/register.sv \
				  ../library/delay_reg.sv \
				  ../phase_detector_start_stop/phase_detector_start_stop.sv \
				  ../shifted_clock_sampling/shifted_clock_sampling.sv \

TOPLEVEL = phase_detector_combined
MODULE = phase_detector_combined_tb
SIM = verilator
EXTRA_ARGS += --trace --trace-structs
COCOTB_HDL_TIMEPRECISION = 1fs

include $(shell cocotb-config --makefiles)/Makefile.sim
