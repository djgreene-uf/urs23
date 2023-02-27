// Simple phase detector using high frequency clock

// The phase error is updated on every update of clk_in_1 and
// phase_err_valid is asserted for one cycle. Phase error is not
// corrected to the range -pi to pi.

module phase_detector
    #(
      parameter int phase_count_size = 28
      )    
    (
     // High frequency clock used to sample
     input logic                         clk_sample,
     input logic                         rst,

     // Input clocks
     input logic                         clk_in_0,
     input logic                         clk_in_1,

     output logic [phase_count_size-1:0] phase_tag_0,
     output logic [phase_count_size-1:0] phase_tag_1,
     output logic                        phase_tag_0_valid,
     output logic                        phase_tag_1_valid
     );

    logic [phase_count_size-1:0] phase_count;

    // Input clock signals synchronized for metastability issues
    logic                        clk_0;
    logic                        clk_1;

    // Delayed version of clocks to determine if transition occurred
    logic                        clk_0_d;
    logic                        clk_1_d;

    sync sync_clk_0
        (.clk(clk_sample),
         .rst(),
         .d(clk_in_0),
         .q(clk_0));

    sync sync_clk_1
        (.clk(clk_sample),
         .rst(),
         .d(clk_in_1),
         .q(clk_1));

    // Free-running counter
    always_ff @(posedge clk_sample) begin
        if (rst == 1'b1) begin
            phase_count <= '0;
        end
        else begin
            phase_count <= phase_count + phase_count_size'(1);
        end
    end

    // Phase detector
    always_ff @(posedge clk_sample) begin
        if (rst == 1'b1) begin
            phase_tag_0 <= '0;
            phase_tag_0_valid <= 1'b0;
            clk_0_d <= 1'b0;
        end
        else begin
            clk_0_d <= clk_0;
            if (clk_0 == 1'b1 && clk_0_d == 1'b0) begin
                phase_tag_0 <= phase_count;
                phase_tag_0_valid <= 1'b1;
            end
            else begin
                phase_tag_0_valid <= 1'b0;
            end
        end
    end

    always_ff @(posedge clk_sample) begin
        if (rst == 1'b1) begin
            phase_tag_1 <= '0;
            phase_tag_1_valid <= 1'b0;
            clk_1_d <= 1'b0;
        end
        else begin
            clk_1_d <= clk_1;
            if (clk_1 == 1'b1 && clk_1_d == 1'b0) begin
                phase_tag_1 <= phase_count;
                phase_tag_1_valid <= 1'b1;
            end
            else begin
                phase_tag_1_valid <= 1'b0;
            end
        end
    end


endmodule
