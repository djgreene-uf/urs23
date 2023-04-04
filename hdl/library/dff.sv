module dff
    (input logic clk,
     input logic rst,
     input logic en,
     input logic d,
     output logic q
     );

    always_ff @(posedge clk or posedge rst) begin
        if (rst == 1'b1) begin
            q <= 1'b0;
        end
        else if (en == 1'b1) begin
            q <= d;
        end
    end

endmodule
