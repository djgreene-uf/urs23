//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//GOWIN Version: GowinSynthesis V1.9.8.10
//Part Number: GW1N-LV1QN48C6/I5
//Device: GW1N-1
//Created Time: Fri Mar 31 19:49:48 2023

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

	fifo_hs_bram_2d_16w your_instance_name(
		.Data(Data_i), //input [15:0] Data
		.WrClk(WrClk_i), //input WrClk
		.RdClk(RdClk_i), //input RdClk
		.WrEn(WrEn_i), //input WrEn
		.RdEn(RdEn_i), //input RdEn
		.Q(Q_o), //output [15:0] Q
		.Empty(Empty_o), //output Empty
		.Full(Full_o) //output Full
	);

//--------Copy end-------------------
