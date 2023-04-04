module dff_sync_rst
    (input logic clk,
     input logic rst,
     input logic en,
     input logic d,
     output logic q
     );

    always_ff @(posedge clk) begin
        if (rst == 1'b1) begin
            q <= 1'b0;
        end
        else if (en == 1'b1) begin
            q <= d;
        end
    end

endmodule
