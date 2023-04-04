// Top level to test phase detector
//
// Outputs phase data parallel

module top_level_shifted_clocks
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

    localparam int parallel_size = 16;
    localparam int serial_size = parallel_size;

    // Clocks
    logic          clk_0;
    logic          clk_90;
    logic          clk_180;
    logic          clk_270;

    // Output register signals
    logic [parallel_size-1:0] parallel_reg;
    logic                     parallel_reg_valid;
    logic                     clk_serial;

    logic [serial_size-1:0]   shift_reg;
    logic [serial_size-1:0]   shift_reg_valid;
    logic                     shift_reg_empty;


    // FIFO signals
    logic                     empty;
    logic [parallel_size-1:0] fifo_out;
    logic                     rd_en;
    logic                     fifo_out_valid_d;
    logic                     fifo_out_valid;

    // Clocks
    always_comb begin
        clk_180 = ~clk_0;
        clk_270 = ~clk_90;
    end

    // SPI logic
    always_comb begin
        rd_en = ~empty & serial_valid;
    end

    // Assigning outputs
    always_comb begin
        phase_out = parallel_reg[7:0];
        phase_out_valid = parallel_reg_valid;
    end

   gowin_rpll_240_phase_shift pll
        (.clkin(sys_clk),
         .clkout(clk_0),
         .clkoutd(clk_serial),
         .clkoutp(clk_90));

    phase_detector_fifo_wrapper PhaseDetectorAndFIFO
        (.clk_0(clk_0),
         .clk_90(clk_90),
         .clk_180(clk_180),
         .clk_270(clk_270),
         .rst(rst),
         .clk_in_start(clk_in_0),
         .clk_in_stop(clk_in_1),
         .RdEn(rd_en),
         .RdClk(clk_serial),
         .data_out(fifo_out),
         .Empty(empty));

    always_ff @(posedge clk_serial) begin
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

    spi_go
        #(.DATA_LENGTH(serial_size))
    SPI_MODULE
        (.RST_N(~rst),
         .GO(fifo_out_valid),
         .CLK(clk_serial),
         .DATA(fifo_out),
         .MCLK(serial_clk),
         .SS_N(serial_valid),
         .MISO(serial_out));

endmodule
