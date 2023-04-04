// Taken from Dr. Stitt's delay example from his SystemVerilog tutorial

module delay_reg
    #(
      parameter int CYCLES = 1,
      parameter int WIDTH = 8)
    (
     input logic              clk,
     input logic              rst,
     input logic              en,
     input logic [WIDTH-1:0]  d,
     output logic [WIDTH-1:0] q);
   
    logic [WIDTH-1:0] regs [CYCLES+1];

    if (CYCLES == 0) begin : cycles_eq_0
        assign q = d;
    end
    else if (CYCLES > 0) begin : cycles_gt_0

        assign regs[0] = d;
        assign q = regs[CYCLES];
        
        genvar i;
        for (i = 0; i < CYCLES; i++) begin : reg_array
            register
                #(.WIDTH(WIDTH))
            reg_array
                (.clk(clk),
                 .rst(rst),
                 .en(en),
                 .d(regs[i]),
                 .q(regs[i+1]));
        end
    end

endmodule
