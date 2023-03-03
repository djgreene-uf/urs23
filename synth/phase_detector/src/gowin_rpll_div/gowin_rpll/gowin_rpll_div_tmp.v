//Copyright (C)2014-2022 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//GOWIN Version: V1.9.8.10
//Part Number: GW1N-LV1QN48C6/I5
//Device: GW1N-1
//Created Time: Mon Feb 27 00:56:50 2023

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    Gowin_rPLL_Div your_instance_name(
        .clkout(clkout_o), //output clkout
        .clkoutd(clkoutd_o), //output clkoutd
        .clkin(clkin_i) //input clkin
    );

//--------Copy end-------------------
