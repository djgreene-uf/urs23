// Combines start stop phase detector and extends by 2 bits using
// shifted clocks.

// Simply just encode two fractional bits for start/stop and allow
// software to do the subtraction

module phase_detector_combined
    #(
      parameter int phase_count_size = 6,
      parameter int clk_0_count_size = 6
      )
    (
     input logic                                                  clk_0,
     input logic                                                  clk_90,
     input logic                                                  clk_180,
     input logic                                                  clk_270,
     input logic                                                  rst,

     input logic                                                  clk_in_0,
     input logic                                                  clk_in_1,

     output logic [(phase_count_size + clk_0_count_size + 4)-1:0] phase_tag,
     output logic                                                 phase_tag_valid
     );

    localparam int count_size = phase_count_size + clk_0_count_size;

    // Phase counter
    logic [phase_count_size-1:0] phase_count_tag;
    logic [clk_0_count_size-1:0] phase_count_start;
    logic                        phase_count_valid;

    // Shift clock samplers
    logic [1:0]                  clk_start_phase, clk_stop_phase;
    logic                        clk_start_phase_valid, clk_stop_phase_valid;

    phase_detector_start_stop
        #(.phase_count_size(phase_count_size),
          .clk_0_count_size(clk_0_count_size))
    PhaseCounter
        (.clk_sample(clk_0),
         .rst(rst),
         .clk_in_0(clk_in_0),
         .clk_in_1(clk_in_1),
         .phase_tag(phase_count_tag),
         .start_count(phase_count_start),
         .phase_tag_valid(phase_count_valid));

    // Pipeline the phase counter to match valid times
    logic [phase_count_size-1:0] phase_count_tag_pipe;
    logic [clk_0_count_size-1:0] phase_count_start_pipe;
    logic                        phase_count_valid_pipe;
    
    delay_reg
        #(.CYCLES(1),
          .WIDTH(phase_count_size))
    PhaseTagPipeline
        (.clk(clk_0),
         .rst(rst),
         .en(1'b1),
         .d(phase_count_tag),
         .q(phase_count_tag_pipe));
    
    delay_reg
        #(.CYCLES(1),
          .WIDTH(clk_0_count_size))
    PhaseStartCountPipeline
        (.clk(clk_0),
         .rst(rst),
         .en(1'b1),
         .d(phase_count_start),
         .q(phase_count_start_pipe));

    delay
        #(.CYCLES(1))          
    PhaseTagValidPipeline
        (.clk(clk_0),
         .rst(rst),
         .en(1'b1),
         .d(phase_count_valid),
         .q(phase_count_valid_pipe));


    // Shifted clock sampling

    shifted_clock_sampling start_sample
        (.clk_0(clk_0),
         .clk_90(clk_90),
         .clk_180(clk_180),
         .clk_270(clk_270),
         .rst(rst),
         .d(clk_in_0),
         .phase(clk_start_phase),
         .phase_valid(clk_start_phase_valid));

    shifted_clock_sampling stop_sample
        (.clk_0(clk_0),
         .clk_90(clk_90),
         .clk_180(clk_180),
         .clk_270(clk_270),
         .rst(rst),
         .d(clk_in_1),
         .phase(clk_stop_phase),
         .phase_valid(clk_stop_phase_valid));

    // Latching everything
    logic [phase_count_size-1:0] phase_count_tag_d;
    logic [clk_0_count_size-1:0] phase_count_start_d;
    logic                        phase_count_valid_d;
    logic [1:0]                  clk_start_phase_d;
    logic [1:0]                  clk_stop_phase_d;

    // Latch phases
    always_ff @(posedge clk_0 or posedge rst) begin
        if (rst == 1'b1) begin
            clk_start_phase_d <= '0;
            clk_stop_phase_d <= '0;
            phase_count_tag_d <='0;
            phase_count_start_d <= '0;
            phase_count_valid_d <= 1'b0;
        end
        else begin
            phase_count_valid_d <= phase_count_valid_pipe;
            if (clk_start_phase_valid == 1'b1) begin
                clk_start_phase_d <= clk_start_phase;
            end
            if (clk_stop_phase_valid == 1'b1) begin
                clk_stop_phase_d <= clk_stop_phase;
            end
            if (phase_count_valid_pipe == 1'b1) begin
                phase_count_tag_d <= phase_count_tag_pipe;
                phase_count_start_d <= phase_count_start_pipe;                
            end
        end
    end

    always_comb begin
        // Assigning outputs
        phase_tag = {phase_count_start_d, phase_count_tag_d, clk_start_phase_d, clk_stop_phase_d};

        // Theoretically phase_count_valid and clk_stop_phase_valid should be the same
        phase_tag_valid = phase_count_valid_d;
    end

    // TODO: Fix timing on phase_tag_valid, making sure that both of the shifted samples are measured
    // Basically the subtraction is not using the correct stop_phase
    // DONE: Remove counter from phase detector to separate the subtract

endmodule
