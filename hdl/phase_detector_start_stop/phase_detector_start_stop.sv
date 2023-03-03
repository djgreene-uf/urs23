// Simple phase detector using high frequency clock and start stop counter

// Begins counter when rising edge is detected on clk_in_0, counts
// number of cycles between rising edge of clk_in_0 and clk_in_1.

module phase_detector_start_stop
    #(
       parameter int phase_count_size = 12,
       parameter int clk_0_count_size = 4
      )    
    (
     // High frequency clock used to sample
     input logic                                              clk_sample,
     input logic                                              rst,

     // Input clocks
     input logic                                              clk_in_0,
     input logic                                              clk_in_1,

     output logic [(phase_count_size + clk_0_count_size)-1:0] phase_tag,
     output logic                                             phase_tag_valid
     );

    localparam int phase_tag_size = phase_count_size + clk_0_count_size;

    // Input clock signals synchronized for metastability issues
    logic          clk_0;
    logic          clk_1;

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

    // Delayed version of clocks to determine if transition occurred
    logic clk_0_d;
    logic clk_1_d;

    // Rising edge detected on each clock
    logic clk_0_edge;
    logic clk_1_edge;

    assign clk_0_edge = (clk_0 == 1'b1) & (clk_0_d == 1'b0);
    assign clk_1_edge = (clk_1 == 1'b1) & (clk_1_d == 1'b0);

    logic [phase_count_size-1:0] phase_count;
    logic [clk_0_count_size-1:0] clk_0_count;

    typedef enum logic {S_WAIT_EDGE0, S_GOT_EDGE0} state_t;
    state_t state_r;

    // Sample clk inputs
    always_ff @(posedge clk_sample) begin
        if (rst == 1'b1) begin
            clk_0_d <= 1'b0;
            clk_1_d <= 1'b0;
        end
        else begin
            clk_0_d <= clk_0;
            clk_1_d <= clk_1;          
        end
    end

    // Phase Detector FSM
    always_ff @(posedge clk_sample) begin
        if (rst == 1'b1) begin
            phase_count <= '0;
            phase_tag <= '0;
            phase_tag_valid <= 1'b0;
            state_r <= S_WAIT_EDGE0;
            clk_0_count <= '0;
        end
        else begin
            phase_tag_valid <= 1'b0;
            case (state_r)
                S_WAIT_EDGE0: begin
                    if (clk_0_edge == 1'b1) begin
                        clk_0_count <= clk_0_count + clk_0_count_size'(1);
                        if (clk_1_edge == 1'b1) begin
                            phase_tag_valid <= 1'b1;
                            phase_tag <= {clk_0_count, phase_count};
                        end
                        else begin
                            state_r <= S_GOT_EDGE0;
                            phase_count <= phase_count + phase_count_size'(1);
                        end
                    end
                end
                S_GOT_EDGE0: begin
                    if (clk_1_edge == 1'b1) begin
                        phase_count <= '0;
                        phase_tag <= {clk_0_count, phase_count};
                        phase_tag_valid <= 1'b1;
                        state_r <= S_WAIT_EDGE0;
                    end
                    else begin
                        phase_count <= phase_count + phase_count_size'(1);
                    end
                end
            endcase
        end
    end
    
endmodule
