/*
 * *****************************************************************
 * File: fnc_uart.v
 * Category: UART
 * File Created: 2023/11/04 13:04
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2023/11/07 03:31
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2023  Project RockWave
 * *****************************************************************
 * Description:
 *   
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2023/11/04	Masaru Aoki	First Version
 * *****************************************************************
 */

module fnc_uart(
    input clk,              // Global Clock
    input rst_n,            // Global Reset

    input           uart_en,
    input  [7:0]    tx_reg,   // Tx 
    input           tx_strt,
    input  [31:0]   refclk_st,
    output          tx_busy,
    output          txd
);


    reg         busyflg ;
    reg [31:0]  refclk_cnt;
    reg [ 3:0]  baud_cnt;

    reg [10:0]  tx_buff;
    reg [ 3:0]  tx_cnt;

    wire        refclk;
    wire        bitshft;
    wire        tx_end;

    // Busyフラグ
    assign tx_busy = busyflg;
    always @(posedge clk, negedge rst_n) begin
        if (rst_n == 1'b0) begin
            busyflg <= 1'b0;
        end
        else if(~uart_en) begin
            busyflg <= 1'b0;
        end
        else if(tx_strt) begin
            busyflg <= 1'b1;
        end
        else if(tx_end) begin
            busyflg <= 1'b0;
        end
        else begin
            busyflg <= busyflg;
        end
    end

    // ボーレートジェネレータ
    assign refclk = (refclk_cnt == 32'hFFFF_FFFF);
    always @(posedge clk, negedge rst_n) begin
        if (rst_n == 1'b0) begin
            refclk_cnt <= 32'hFFFF_FFFF;
        end
        else if(~uart_en) begin
            refclk_cnt <= ~refclk_st;
        end
        else if(tx_strt) begin
            refclk_cnt <= ~refclk_st;
        end
        else if(refclk) begin
            refclk_cnt <= ~refclk_st;
        end
        else begin
            refclk_cnt <= refclk_cnt + 1;
        end
    end

    // シフトタイミング生成
    assign bitshft = (baud_cnt == 4'hF)&refclk;
    always @(posedge clk, negedge rst_n) begin
        if (rst_n == 1'b0) begin
            baud_cnt <= 4'h0;
        end
        else if(~uart_en) begin
            baud_cnt <= 4'h0;
        end
        else if(refclk) begin
            baud_cnt <= baud_cnt + 1;
        end
        else begin
            baud_cnt <= baud_cnt;
        end
    end

    // 送信バッファ
    //  スタートパルスでラッチ
    //  bitshftで右シフト
    //  スタート後最初のbitshftまでの時間がばらつくため、StartBitの前に
    //  1を入れておきスタートパルス幅を担保する
    always @(posedge clk, negedge rst_n) begin
        if (rst_n == 1'b0) begin
            tx_buff <= 11'h7FF;
        end
        else if(~uart_en) begin
            tx_buff <= 11'h7FF;
        end
        else if(tx_strt) begin
            tx_buff <= {1'b1, tx_reg, 2'b01};   // StopBit / Data(8bit) / StartBit / 1
        end
        else if(bitshft) begin
            tx_buff <= {1'b1, tx_buff[10:1]};   // LSBから送信
        end
        else begin
            tx_buff <= tx_buff;
        end
    end
    assign txd = tx_buff[0];

    // 送信カウンタ
    assign tx_end = (tx_cnt == 4'hB);
    always @(posedge clk, negedge rst_n) begin
        if (rst_n == 1'b0) begin
            tx_cnt <= 4'h0;
        end
        else if(~uart_en) begin
            tx_cnt <= 4'h0;
        end
        else if(tx_strt) begin
            tx_cnt <= 4'h0;
        end
        else if(tx_busy & bitshft) begin
            tx_cnt <= tx_cnt+1;
        end
        else begin
            tx_cnt <= tx_cnt;
        end
    end


endmodule
