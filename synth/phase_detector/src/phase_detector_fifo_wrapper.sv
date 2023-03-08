// Wrapper for phase detector and FIFO providing phase detector input
// interface and FIFO read interface

// FIFO is instantiated to 8 bits.

module phase_detector_fifo_wrapper
    (
     // Phase detector inputs
     input logic        clk_sample,
     input logic        rst, 
     input logic        clk_in_0,
     input logic        clk_in_1,

     // FIFO read interface
     input logic        RdEn,
     input logic        RdClk,
     
     output logic [7:0] data_out,
     output logic       Empty,
     output logic       Almost_Empty);

    // Phase detector signals
    logic [7:0] phase_tag;
    logic       phase_tag_valid;

    // FIFO signals
    logic       full;
    logic [7:0] fifo_out;
    logic       wr_en;

    assign wr_en = phase_tag_valid & ~full;

    phase_detector_start_stop
        #(.phase_count_size(5),
          .clk_0_count_size(3))
    PhaseDetector
        (.clk_sample(clk_sample),
         .rst(rst),
         .clk_in_0(clk_in_0),
         .clk_in_1(clk_in_1),
         .phase_tag(phase_tag),
         .phase_tag_valid(phase_tag_valid));

    fifo_bram_top phase_fifo
        (.Data(phase_tag),
         .WrClk(clk_sample),
         .RdClk(RdClk),
         .WrEn(wr_en),
         .RdEn(RdEn),
         .Almost_Empty(Almost_Empty),
         .Almost_Full(),
         .Q(data_out),
         .Empty(Empty),
         .Full(full));

endmodule
