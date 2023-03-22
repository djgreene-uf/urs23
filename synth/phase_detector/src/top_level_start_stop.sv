// Top level to test phase detector
//
// Shifts out a 32-bit word on serial clk with phase information of clk.

module top_level_start_stop
    (
     input logic sys_clk,
     input logic rst,

     input logic clk_in_0,
     input logic clk_in_1,

     output logic serial_clk,
     output logic serial_out,
     output logic serial_valid
     );

    localparam int serial_size = 8;
    localparam int phase_count_size = 5;
    localparam int clock_count_size = serial_size - phase_count_size;

    logic      clk_sample;

    // Shift register signals
    logic                   clk_shift_reg;
    logic [serial_size-1:0] shift_reg;
    logic [serial_size-1:0] shift_reg_valid;
    logic                   shift_reg_empty;

    // FIFO signals
    logic                   empty;
    logic [serial_size-1:0] fifo_out;
    logic                   rd_en;
    logic                   fifo_out_valid_d;
    logic                   fifo_out_valid;

    // FIFO Read Logic
    always_comb begin
        shift_reg_empty = ~shift_reg_valid[serial_size-1];
        rd_en = shift_reg_empty & ~empty;
    end
    
    // Assigning outputs
    always_comb begin
        serial_clk = clk_shift_reg & ~shift_reg_empty;
        serial_out = shift_reg[serial_size-1];
        serial_valid = ~shift_reg_empty;
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
            shift_reg <= '0;
            shift_reg_valid <= '0;
            fifo_out_valid <= 1'b0;
            fifo_out_valid_d <= 1'b0;
        end
        else begin
            // This FIFO is not first word fall through so valid is delayed by one cycle
            fifo_out_valid_d <= rd_en;
            fifo_out_valid <= fifo_out_valid_d;

            // Load shift reg if reading from FIFO
            if (fifo_out_valid) begin
                shift_reg <= fifo_out;
                shift_reg_valid <= '1;
            end
            // Otherwise shift out contents            
            else begin
                shift_reg <= {shift_reg[serial_size-2:0], 1'b0};
                shift_reg_valid <= {shift_reg_valid[serial_size-2:0], 1'b0};
            end
        end
    end

endmodule
