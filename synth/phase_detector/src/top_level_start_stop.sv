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

    localparam phase_count_size = 16;

    logic      clk_sample_120;

    logic [phase_count_size-1:0] phase_tag;
    logic                        phase_tag_valid;

    logic                        clk_shift_reg;
    logic [phase_count_size-1:0] shift_reg;
    logic [phase_count_size-1:0] shift_reg_valid;
    logic                        shift_reg_ready;

    logic                        tag_new;
    logic                        tag_read;

    assign shift_reg_ready = shift_reg_valid[phase_count_size-1];
    assign serial_clk = clk_shift_reg & shift_reg_ready;
    assign serial_out = shift_reg[phase_count_size-1];
    assign serial_valid = ~shift_reg_ready;

    Gowin_rPLL_Div pll
        (.clkin(sys_clk),
         .clkout(clk_sample_120),
         .clkoutd(clk_shift_reg));

    phase_detector_start_stop
        #(
          .phase_count_size(phase_count_size))
    PhaseDetector
        (.clk_sample(clk_sample_120),
         .rst(rst),
         .clk_in_0(clk_in_0),
         .clk_in_1(clk_in_1),
         .phase_tag(phase_tag),
         .phase_tag_valid(phase_tag_valid));

    always_ff @(posedge clk_sample_120) begin
        if (rst == 1'b1) begin
            tag_new <= 1'b0;
        end
        else begin
            if (phase_tag_valid == 1'b1 && tag_new == 1'b0) begin
                tag_new <= 1'b1;
            end

            if (tag_read == 1'b1) begin
                tag_new <= 1'b0;
            end
        end
    end

    always_ff @(posedge clk_shift_reg) begin
        if (rst == 1'b1) begin
            shift_reg <= '0;
            shift_reg_valid <= '0;
            tag_read <= 1'b0;
        end
        else begin
            tag_read <= 1'b0;
            if (tag_new == 1'b1 && shift_reg_ready == 1'b0) begin
                shift_reg <= phase_tag;
                shift_reg_valid <= '1;
                tag_read <= 1'b1;
            end
            else begin
                shift_reg <= {shift_reg[phase_count_size-2:0], 1'b0};
                shift_reg_valid <= {shift_reg_valid[phase_count_size-2:0], 1'b0};
            end
        end
    end

endmodule
