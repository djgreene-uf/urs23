// Wrapper for phase detector and FIFO providing phase detector input
// interface and FIFO read interface

// FIFO is instantiated to 8 bits.

module phase_detector_fifo_wrapper
    (
     // Phase detector inputs
     input logic         clk_0,
     input logic         clk_90,
     input logic         clk_180,
     input logic         clk_270,
     input logic         rst, 
     input logic         clk_in_start,
     input logic         clk_in_stop,

     // FIFO read interface
     input logic         RdEn,
     input logic         RdClk,
     
     output logic [15:0] data_out,
     output logic        Empty);

    // Phase detector signals
    logic [15:0] phase_tag;
    logic        phase_tag_valid;

    // FIFO signals
    logic [15:0] fifo_in;
    logic [15:0] fifo_out;
    logic        wr_en;
    logic        full;

    assign fifo_in = phase_tag;
    assign data_out = fifo_out;
    assign wr_en = phase_tag_valid & ~full;

    phase_detector_combined
        #(.phase_count_size(6),
          .clk_0_count_size(6))
    PhaseDetector
        (.clk_0(clk_0),
         .clk_90(clk_90),
         .clk_180(clk_180),
         .clk_270(clk_270),
         .rst(rst),
         .clk_in_0(clk_in_start),
         .clk_in_1(clk_in_stop),
         .phase_tag(phase_tag),
         .phase_tag_valid(phase_tag_valid));

    fifo_hs_bram_2d_16w phase_fifo
        (.Data(fifo_in),
         .WrClk(clk_0),
         .RdClk(RdClk),
         .WrEn(wr_en),
         .RdEn(RdEn),
         .Q(fifo_out),
         .Empty(Empty),
         .Full(full));

endmodule
