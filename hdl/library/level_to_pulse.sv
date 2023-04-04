module level_to_pulse
    (input logic  clk,
     input logic  rst,
     input logic  d,
     output logic q);

    logic dff_out;

    dff dff_level
        (.clk(clk),
         .rst(rst),
         .en(1'b1),
         .d(d),
         .q(dff_out));

    assign q = d & !dff_out;
    
endmodule
