module shifted_clock_sampling
    (
     input logic        clk_0,
     input logic        clk_90,
     input logic        clk_180,
     input logic        clk_270,
     input logic        rst,

     input logic        d,

     output logic [1:0] phase,
     output logic       phase_valid
     );

    logic q_0, q_0_edge;
    logic q_90, q_90_edge;
    logic q_180, q_180_edge;
    logic q_270, q_270_edge;

    // --------------------------------------
    // Synchronizing inputs for metastability
    // --------------------------------------

    sync sync_sample_0
        (.clk(clk_0),
         .rst(rst),
         .d(d),
         .q(q_0));

    sync sync_sample_90
        (.clk(clk_90),
         .rst(rst),
         .d(d),
         .q(q_90));

    sync sync_sample_180
        (.clk(clk_180),
         .rst(rst),
         .d(d),
         .q(q_180));

    sync sync_sample_270
        (.clk(clk_270),
         .rst(rst),
         .d(d),
         .q(q_270));

    // ---------------------------------------
    // AND gates to determine if edge occurred
    // ---------------------------------------

    assign q_0_edge = ~q_0 & q_90;
    assign q_90_edge = ~q_90 & q_180;
    assign q_180_edge = ~q_180 & q_270;
    assign q_270_edge = ~q_270 & q_0;

    // -----------------------------------
    //
    // Latching edges on same clock domain
    //
    // Pulse is extended by one clock cycle in order to allow for
    // multicycle paths 
    // -----------------------------------

    logic latch_0, latch_90, latch_180, latch_270;
        
    pulse_extender dff_hit_0
        (.clk(clk_0),
         .rst(rst),
         .d(q_0_edge),
         .q(latch_0));

    pulse_extender dff_hit_90
        (.clk(clk_90),
         .rst(rst),
         .d(q_90_edge),
         .q(latch_90));

    pulse_extender dff_hit_180
        (.clk(clk_180),
         .rst(rst),
         .d(q_180_edge),
         .q(latch_180));

    pulse_extender dff_hit_270
        (.clk(clk_270),
         .rst(rst),
         .d(q_270_edge),
         .q(latch_270));
   
    // ------------------------
    // clk_0 domain
    // ------------------------

    logic latch_valid;
    logic encoder_valid;

    logic q_0_d;
    logic hit_en;

    logic latch_0_sync, latch_90_sync, latch_180_sync, latch_270_sync;

    // Generate a pulse two cycles (multicycle paths to ease timing)
    // after a pulse is detected on clk 0 to latch signals that cross
    // clock domains. Otherwise the clk_270 pulse would have to latch to
    // clk_0 resulting in 1/4 of normal setup time.
    
    delay
        #(.CYCLES(2))
    delay_q_0
        (.clk(clk_0),
         .rst(rst),
         .en(1'b1),
         .d(q_0),
         .q(q_0_d));

    level_to_pulse pulse_hit_en
        (.clk(clk_0),
         .rst(rst),
         .d(q_0_d),
         .q(hit_en));

    // Latch on hit_en in clk 0 domain

    dff sync_hit_0
        (.clk(clk_0),
         .rst(rst),
         .en(hit_en),
         .d(latch_0),
         .q(latch_0_sync));
    
    dff sync_hit_90
        (.clk(clk_0),
         .rst(rst),
         .en(hit_en),
         .d(latch_90),
         .q(latch_90_sync));

    dff sync_hit_180
        (.clk(clk_0),
         .rst(rst),
         .en(hit_en),
         .d(latch_180),
         .q(latch_180_sync));

    dff sync_hit_270
        (.clk(clk_0),
         .rst(rst),
         .en(hit_en),
         .d(latch_270),
         .q(latch_270_sync));

    // Phase valid one clock after hit en
    delay
        #(.CYCLES(1))
    delay_hit_en
        (.clk(clk_0),
         .rst(rst),
         .en(1'b1),
         .d(hit_en),
         .q(latch_valid));   
    
    // Encode output
    always_comb begin
        if (latch_270_sync == 1'b1) begin
            phase = 2'b11;
            encoder_valid = 1'b1;
        end
        else if (latch_180_sync == 1'b1) begin
            phase = 2'b10;
            encoder_valid = 1'b1;
        end
        else if (latch_90_sync == 1'b1) begin
            phase = 2'b01;
            encoder_valid = 1'b1;
        end
        else if (latch_0_sync == 1'b1) begin
            phase = 2'b00;
            encoder_valid = 1'b1;
        end
        else begin
            phase = 2'b00;
            encoder_valid = 1'b0;
        end
    end

    assign phase_valid = latch_valid & encoder_valid;

endmodule
