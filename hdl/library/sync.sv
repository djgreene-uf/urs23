// Two flip flops (for metastability)

module sync
    (
     input logic  clk,
     input logic  rst,
     input logic  d,
     output logic q
     );

    logic         delay;
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst == 1'b1) begin
            delay <= 1'b0;
            q <= 1'b0;
        end else begin        
            delay <= d;
            q <= delay;
        end        
    end
   
endmodule
