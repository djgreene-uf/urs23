module clk_div
    #(parameter int DIV_RATIO = 16)
    (
     input logic  clk,
     input logic  rst,
     output logic clk_out);

    localparam int count_size = $clog2(DIV_RATIO);
    logic [count_size-1:0] count;

    always_ff @(posedge clk or posedge rst) begin
        if (rst == 1'b1) begin
            clk_out <= 1'b0;
            count <= '0;
        end
        else begin
            count <= count + count_size'(1);
            if (count == DIV_RATIO-1) begin
                count <= '0;
            end
            if (count == count_size'(0)) begin
                clk_out <= 1'b1;
            end
            else begin
                clk_out <= 1'b0;
            end
        end
    end       

endmodule
