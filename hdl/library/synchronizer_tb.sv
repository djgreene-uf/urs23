`timescale 1 ns / 10 ps

module synchronizer_tb;

    logic clk = 1'b0;
    logic data_in = 1'b0;
    logic data_out;

    initial begin : generate_clock
        while (1) #5 clk = ~clk;
    end

    synchronizer dut
        (.clk(clk),
         .data_in(data_in),
         .data_out(data_out));

    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0, synchronizer_tb);
        for (int i=0; i < 10; i++)
            @(posedge clk);
        data_in = 1'b1;
        for (int i=0; i < 10; i++)
            @(posedge clk);
        disable generate_clock;
        $display("Tests completed");
    end
    
endmodule
