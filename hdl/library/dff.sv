module dff
    #(parameter int RESET_VAL = 0)
    (input logic clk,
     input logic rst,
     input logic en,
     input logic d,
     output logic q
     );

    always_ff @(posedge clk or posedge rst) begin
        if (rst == 1'b1) begin
            q <= RESET_VAL;
        end
        else if (en == 1'b1) begin
            q <= d;
        end
    end

endmodule
