`timescale 1ns / 1ps

`define     SHIFT_DIRECTION     0   // 0: MSB->LSB , 1: LSB -> MSB
`define     CLOCK_PHASE         0   
`define     CLOCK_POLARITY      0

module spi_go
    #(parameter int DATA_LENGTH = 8)
    (
    input logic RST_N,
    input logic CLK,
    input logic GO,
    input logic [DATA_LENGTH-1:0] DATA,
    output logic MCLK,
    output logic SS_N, 
    output logic MISO
);

/********************************************************************
*variables
********************************************************************/

   typedef enum logic[1:0] {WAIT, TRANSMIT, DONE, XXX='x} state_t;
   state_t state_r;

    logic mclk_r, ss_r;
    logic [DATA_LENGTH-1:0]    tx_cnt_r;
    logic [DATA_LENGTH-1:0]    miso_shift_r;

/*******************************************************************
*transmit data 
*******************************************************************/

always_ff @(negedge RST_N or posedge CLK) begin
    if(!RST_N) begin
        state_r <= WAIT;
        tx_cnt_r <= '0;
        miso_shift_r <= '0;
        mclk_r <= 1'b0;
        ss_r <= 1'b1;
    end
    else begin

        case (state_r)
            WAIT : begin

                // DATA should be ready in the same cycle GO is asserted
                if (GO) begin
                    state_r <= TRANSMIT;
                    tx_cnt_r <= '0;
                    mclk_r <= 1'b0;
                    ss_r <= 1'b0;
                    miso_shift_r <= DATA;
                end
            end

            TRANSMIT : begin
                mclk_r <= ~mclk_r;

                if (mclk_r) begin
                    if (tx_cnt_r >= DATA_LENGTH - 1) state_r <= DONE;
                    else tx_cnt_r <= tx_cnt_r + 1'b1;  
                end
            end

            DONE : begin
                state_r <= WAIT;
                tx_cnt_r <= '0;
                mclk_r <= 1'b0;
                ss_r <= 1'b1;
            end

            default : state_r <= XXX;
        endcase

    end
end 

assign SS_N = ss_r;
assign MCLK = mclk_r;
assign MISO = miso_shift_r[(DATA_LENGTH-1)-tx_cnt_r]; //LSB ->MSB

endmodule
