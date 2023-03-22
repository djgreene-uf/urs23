//Copyright (C)2014-2023 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//GOWIN Version: 1.9.8.10 
//Created Time: 2023-03-19 17:32:48
create_clock -name sys_clk -period 41.667 -waveform {0 5} [get_ports {sys_clk}]
create_clock -name clk_sample -period 4.167 -waveform {0 2.08} [get_nets {clk_sample}]
report_route_congestion -max_grids 10
report_max_frequency -mod_ins {PhaseDetectorAndFIFO PhaseDetectorAndFIFO/PhaseDetector PhaseDetectorAndFIFO/PhaseDetector/sync_clk_0 PhaseDetectorAndFIFO/PhaseDetector/sync_clk_1 PhaseDetectorAndFIFO/phase_fifo PhaseDetectorAndFIFO/phase_fifo/fifo_inst pll}
