// Top level to test phase detector
//
// Outputs phase data parallel

module top_level_start_stop_parallel
    (
     input logic        sys_clk,
     input logic        rst,

     input logic        clk_in_0, // Start
     input logic        clk_in_1, // Stop

     output logic [7:0] phase_out,
     output logic       phase_out_valid,

     output logic       serial_clk,
     output logic       serial_out,
     output logic       serial_valid
     );

    localparam int parallel_size = 8;
    localparam int serial_size = parallel_size;
    localparam int phase_count_size = 5;
    localparam int clock_count_size = parallel_size - phase_count_size;

    logic          clk_sample;

    // Output register signals
    logic [parallel_size-1:0] parallel_reg;
    logic                     parallel_reg_valid;
    logic                     clk_shift_reg;

    logic [serial_size-1:0]   shift_reg;
    logic [serial_size-1:0]   shift_reg_valid;
    logic                     shift_reg_empty;


    // FIFO signals
    logic                     empty;
    logic [parallel_size-1:0] fifo_out;
    logic                     rd_en;
    logic                     fifo_out_valid_d;
    logic                     fifo_out_valid;

    // SPI logic
    always_comb begin
        rd_en = ~empty & serial_valid;
    end

    // Assigning outputs
    always_comb begin
        phase_out = parallel_reg;
        phase_out_valid = parallel_reg_valid;
    end

    Gowin_rPLL_240 pll
        (.clkin(sys_clk),
         .clkout(clk_sample),
         .clkoutd(clk_shift_reg));

    phase_detector_fifo_wrapper PhaseDetectorAndFIFO
        (.clk_sample(clk_sample),
         .rst(rst),
         .clk_in_0(clk_in_0),
         .clk_in_1(clk_in_1),
         .RdEn(rd_en),
         .RdClk(clk_shift_reg),
         .data_out(fifo_out),
         .Empty(empty),
         .Almost_Empty());

    always_ff @(posedge clk_shift_reg) begin
        if (rst == 1'b1) begin
            parallel_reg <= '0;
            fifo_out_valid <= 1'b0;
            fifo_out_valid_d <= 1'b0;
            parallel_reg_valid <= 1'b0;
        end
        else begin
            // This FIFO is not first word fall through so valid is delayed by one cycle
            fifo_out_valid_d <= rd_en;
            fifo_out_valid <= fifo_out_valid_d;
            parallel_reg_valid <= fifo_out_valid;

            if (fifo_out_valid) begin
                parallel_reg <= fifo_out;
            end
        end
    end

    spi_go SPI_MODULE
        (.RST_N(~rst),
         .GO(fifo_out_valid),
         .CLK(clk_shift_reg),
         .DATA(fifo_out),
         .MCLK(serial_clk),
         .SS_N(serial_valid),
         .MISO(serial_out));

endmodule
