//Copyright (C)2014-2023 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//GOWIN Version: 1.9.8.10 
//Created Time: 2023-04-02 19:36:20

//set_multicycle_path -from [get_regs {PhaseDetectorAndFIFO/PhaseDetector/start_sample/dff_hit_0/delay_extend/q_s0}] -to [get_regs {PhaseDetectorAndFIFO/PhaseDetector/start_sample/sync_hit_0/q_s0}]  -setup -end 2
set_multicycle_path -from [get_regs {PhaseDetectorAndFIFO/PhaseDetector/start_sample/dff_hit_180/delay_extend/q_s1}] -to [get_regs {PhaseDetectorAndFIFO/PhaseDetector/start_sample/sync_hit_180/q_s0}]  -setup -end 2
set_multicycle_path -from [get_regs {PhaseDetectorAndFIFO/PhaseDetector/start_sample/dff_hit_180/delay_extend/q_s1}] -to [get_regs {PhaseDetectorAndFIFO/PhaseDetector/start_sample/sync_hit_180/q_s0}]  -hold -end 1
set_multicycle_path -from [get_regs {PhaseDetectorAndFIFO/PhaseDetector/start_sample/dff_hit_270/delay_extend/q_s1}] -to [get_regs {PhaseDetectorAndFIFO/PhaseDetector/start_sample/sync_hit_270/q_s0}]  -setup -end 2
set_multicycle_path -from [get_regs {PhaseDetectorAndFIFO/PhaseDetector/start_sample/dff_hit_270/delay_extend/q_s1}] -to [get_regs {PhaseDetectorAndFIFO/PhaseDetector/start_sample/sync_hit_270/q_s0}]  -hold -end 1
//set_multicycle_path -from [get_regs {PhaseDetectorAndFIFO/PhaseDetector/start_sample/dff_hit_90/delay_extend/q_s0}] -to [get_regs {PhaseDetectorAndFIFO/PhaseDetector/start_sample/sync_hit_90/q_s0}]  -setup -end 2
set_multicycle_path -from [get_regs {PhaseDetectorAndFIFO/PhaseDetector/stop_sample/dff_hit_0/delay_extend/q_s0}] -to [get_regs {PhaseDetectorAndFIFO/PhaseDetector/stop_sample/sync_hit_0/q_s0}]  -setup -end 2
set_multicycle_path -from [get_regs {PhaseDetectorAndFIFO/PhaseDetector/stop_sample/dff_hit_0/delay_extend/q_s0}] -to [get_regs {PhaseDetectorAndFIFO/PhaseDetector/stop_sample/sync_hit_0/q_s0}]  -hold -end 1
set_multicycle_path -from [get_regs {PhaseDetectorAndFIFO/PhaseDetector/stop_sample/dff_hit_180/delay_extend/q_s1}] -to [get_regs {PhaseDetectorAndFIFO/PhaseDetector/stop_sample/sync_hit_180/q_s0}]  -setup -end 2
set_multicycle_path -from [get_regs {PhaseDetectorAndFIFO/PhaseDetector/stop_sample/dff_hit_180/delay_extend/q_s1}] -to [get_regs {PhaseDetectorAndFIFO/PhaseDetector/stop_sample/sync_hit_180/q_s0}]  -hold -end 1
set_multicycle_path -from [get_regs {PhaseDetectorAndFIFO/PhaseDetector/stop_sample/dff_hit_270/delay_extend/q_s1}] -to [get_regs {PhaseDetectorAndFIFO/PhaseDetector/stop_sample/sync_hit_270/q_s0}]  -setup -end 2
set_multicycle_path -from [get_regs {PhaseDetectorAndFIFO/PhaseDetector/stop_sample/dff_hit_270/delay_extend/q_s1}] -to [get_regs {PhaseDetectorAndFIFO/PhaseDetector/stop_sample/sync_hit_270/q_s0}]  -hold -end 1
set_multicycle_path -from [get_regs {PhaseDetectorAndFIFO/PhaseDetector/stop_sample/dff_hit_90/delay_extend/q_s0}] -to [get_regs {PhaseDetectorAndFIFO/PhaseDetector/stop_sample/sync_hit_90/q_s0}]  -setup -end 2
set_multicycle_path -from [get_regs {PhaseDetectorAndFIFO/PhaseDetector/stop_sample/dff_hit_90/delay_extend/q_s0}] -to [get_regs {PhaseDetectorAndFIFO/PhaseDetector/stop_sample/sync_hit_90/q_s0}]  -hold -end 1
