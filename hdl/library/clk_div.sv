module clk_div
    #(parameter int DIV_RATIO = 16)
    (
     input logic  clk,
     input logic  rst,
     output logic clk_out);

    logic regs [DIV_RATIO];

    if (DIV_RATIO == 1) begin
        assign clk_out = clk;
    end
    else if (DIV_RATIO > 1) begin

        dff
            #(.RESET_VAL(1))
        dff_RST_1
            (.clk(clk),
             .rst(rst),
             .en(1'b1),
             .d(regs[DIV_RATIO-1]),
             .q(regs[0]));

        genvar i;
        for (i = 1; i < DIV_RATIO; i++) begin : gen_dff_array
            dff
                #(.RESET_VAL(0))
            dff_array
                (.clk(clk),
                 .rst(rst),
                 .en(1'b1),
                 .d(regs[i-1]),
                 .q(regs[i]));

        end

        assign clk_out = regs[0];

    end

endmodule
