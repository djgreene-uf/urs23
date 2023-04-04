module pulse_extender
    (input logic  clk,
     input logic  rst,
     input logic  d,
     output logic q
     );

    logic q_1, q_2;
    logic q_extend;

    dff delay_1
        (.clk(clk),
         .rst(rst),
         .en(1'b1),
         .d(d),
         .q(q_1));

    dff delay_2
        (.clk(clk),
         .rst(rst),
         .en(1'b1),
         .d(q_1),
         .q(q_2));

    assign q_extend = q_1 | q_2;

    dff delay_extend
        (.clk(clk),
         .rst(rst),
         .en(1'b1),
         .d(q_extend),
         .q(q));
    
endmodule
