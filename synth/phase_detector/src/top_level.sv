// Top level to test phase detector
//
// Shifts out a 32-bit word on serial clk with phase information of clk.

module top_level
    (
     input logic sys_clk,
     input logic rst,

     input logic clk_in_0,
     input logic clk_in_1,

     output logic serial_clk,
     output logic serial_out,
     output logic serial_valid
     );

    localparam phase_count_size = 28;
    localparam header_size = 32 - phase_count_size;
    localparam header_pad_0_size = header_size - 1;

    logic      clk_sample_120;

    logic [phase_count_size-1:0] phase_tag_0;
    logic [phase_count_size-1:0] phase_tag_1;
    logic                        phase_tag_0_valid;
    logic                        phase_tag_1_valid;

    logic                        shift_reg_clk;
    logic [31:0]                 shift_reg;
    logic [31:0]                 shift_reg_valid;
    logic                        shift_reg_ready;

    logic                        tag_0_new;
    logic                        tag_1_new;
    logic                        tag_0_read;
    logic                        tag_1_read;

    logic                        shift_out;

    assign shift_reg_ready = shift_reg_valid[31];
    assign serial_clk = shift_reg_clk & shift_reg_ready;
    assign serial_out = shift_reg[31];
    assign serial_valid = shift_reg_ready;

    Gowin_rPLL_Div pll
        (.clkin(sys_clk),
         .clkout(clk_sample_120),
         .clkoutd(shift_reg_clk));

    phase_detector 
        #(
          .phase_count_size(phase_count_size))
    PhaseDetector
        (.clk_sample(clk_sample_120),
         .rst(rst),
         .clk_in_0(clk_in_0),
         .clk_in_1(clk_in_1),
         .phase_tag_0(phase_tag_0),
         .phase_tag_1(phase_tag_1),
         .phase_tag_0_valid(phase_tag_0_valid),
         .phase_tag_1_valid(phase_tag_1_valid));

    always_ff @(posedge clk_sample_120) begin
        if (rst == 1'b1) begin
            tag_0_new <= 1'b0;
            tag_1_new <= 1'b0;
        end
        else begin
            if (phase_tag_0_valid == 1'b1 && tag_0_new == 1'b0) begin
                tag_0_new <= 1'b1;
            end
            if (tag_0_read == 1'b1) begin
                tag_0_new <= 1'b0;
            end

            if (phase_tag_1_valid == 1'b1 && tag_1_new == 1'b0) begin
                tag_1_new <= 1'b1;
            end
            if (tag_1_read == 1'b1) begin
                tag_1_new <= 1'b0;
            end 

        end
    end

    always_ff @(posedge shift_reg_clk) begin
        if (rst == 1'b1) begin
            shift_reg <= '0;
            shift_reg_valid <= '0;
            tag_0_read <= 1'b0;
            tag_1_read <= 1'b0;
        end
        else begin
            tag_0_read <= 1'b0;
            tag_1_read <= 1'b0;
            if (tag_1_new == 1'b1 && shift_reg_ready == 1'b0) begin
                shift_reg[31:0] <= {1'b1, 3'b000, phase_tag_1};
                shift_reg_valid[31:0] <= '1;
                tag_1_read <= 1'b1;
            end
            else if (tag_0_new == 1'b1 && shift_reg_ready == 1'b0) begin
                shift_reg[31:0] <= {1'b0, 3'b000, phase_tag_0};
                shift_reg_valid[31:0] <= '1;
                tag_0_read <= 1'b1;
            end
            else begin
                shift_reg[31:0] <= {shift_reg[30:0], 1'b0};
                shift_reg_valid[31:0] <= {shift_reg_valid[30:0], 1'b0};
            end
        end
    end

endmodule
