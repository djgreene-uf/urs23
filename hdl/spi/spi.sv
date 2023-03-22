`timescale 1ns / 1ps

`define     SHIFT_DIRECTION     0   // 0: MSB->LSB , 1: LSB -> MSB
`define     CLOCK_PHASE         0   
`define     CLOCK_POLARITY      0
`define     DATA_LENGTH         8

module spi (
    input logic RST_N,
    input logic SCLK,
    input logic [`DATA_LENGTH-1:0] DATA,
    output logic MCLK,
    output logic SS_N, 
    output logic MISO
);

/********************************************************************
*variables
********************************************************************/

    logic ss_r, prev_ss_r;
    logic [`DATA_LENGTH-1:0]    tx_cnt_r;
    logic [`DATA_LENGTH-1:0]    miso_shift_r;
    logic [`DATA_LENGTH-1:0]    delay;
    logic [`DATA_LENGTH-1:0]    clk_cnt;

/*******************************************************************
*transmit data 
*******************************************************************/

//if(`CLOCK_POLARITY ^ `CLOCK_PHASE)begin
//    always_ff @(negedge RST_N or posedge MCLK) begin
//        if(!RST_N) begin
//            ss_r <= 1'b1;
//            prev_ss_r <= 1'b1;
//            tx_cnt_r <= '0;
//            miso_shift_r <= '0;
//        end
//        else begin
//			if(tx_cnt_r >= `DATA_LENGTH - 1) begin
//                miso_shift_r <= DATA;
//                prev_ss_r <= ss_r;
//                ss_r <= 1'b0;

//                if (prev_ss_r != ss_r) begin
//                    ss_r <= 1'b1;
//                end
//                else tx_cnt_r <= 0;
//            end
//            else begin
//                tx_cnt_r <= tx_cnt_r + 1'b1;
//            end
//		end
//    end 

//    assign MISO = `SHIFT_DIRECTION ? miso_shift_r[tx_cnt_r] :                   //LSB ->MSB
//                                     miso_shift_r[`DATA_LENGTH-tx_cnt_r-1] ;    //MSB -> LSB

//    assign SS_N = ss_r; 
//end
//else begin
    always_ff @(negedge RST_N or negedge MCLK) begin
        if(!RST_N) begin
            tx_cnt_r <= '0;
            miso_shift_r <= '0;
        end
        else begin
			if(tx_cnt_r >= `DATA_LENGTH - 1) begin
                miso_shift_r <= DATA;
   

                if (prev_ss_r == ss_r) tx_cnt_r <= 0;
            end
            else begin
                tx_cnt_r <= tx_cnt_r + 1'b1;
            end
		end
    end 

    assign MISO = `SHIFT_DIRECTION ? miso_shift_r[tx_cnt_r] :                   //LSB ->MSB
                                     miso_shift_r[`DATA_LENGTH-tx_cnt_r-1] ;    //MSB -> LSB

    assign SS_N = ss_r;
//end

always_ff @(negedge RST_N or posedge SCLK) begin 
    if (!RST_N) begin
        MCLK <= 1'b0;
        ss_r <= 1'b1;
        prev_ss_r <= 1'b1;
        delay <= '0;
        clk_cnt <= '0;
    end
    else begin
        clk_cnt <= clk_cnt + 1'b1;

        if (clk_cnt == 0) begin
            delay <= delay + 1'b1;

            if (delay == 4) begin
                if (prev_ss_r) begin
                    ss_r <= 1'b0;
                end
                else begin
                    ss_r <= 1'b1;
                end
            end
            else if (delay >= 14) begin
                if (!ss_r) begin
                    if ((tx_cnt_r >= `DATA_LENGTH - 1) && (MCLK == 1'b1)) begin
                        MCLK <= 1'b0;
                        prev_ss_r <= 1'b0;
                        delay <= '0;
                    end 
                    else MCLK <= ~MCLK;
                end
                else begin
                    delay <= '0;
                    prev_ss_r <= 1'b1;
                end
            end
        
            clk_cnt <= '0;
        end
 
    end
end

endmodule