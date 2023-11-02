/*
 * *****************************************************************
 * File: fnc_timer.v
 * Category: Timer
 * File Created: 2023/10/09 12:22
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2023/10/28 13:29
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2023  Project RockWave
 * *****************************************************************
 * Description:
 *   Timerモジュール
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2023/10/09	Masaru Aoki	First Version
 * *****************************************************************
 */

module fnc_timer(
    input clk,              // Global Clock
    input rst_n,            // Global Reset

    input  [63:0]   mtimecmp,   // 64bit timer compare register
    output [63:0]   mtime,      // 64bit timer regsiter

    output          int_timer  // タイマ割込
);

    reg     [63:0]  internal_counter;

    ////////////////////////////////////////////////////////////////////////////
    // フリーランカウンタ
    always @(posedge clk, negedge rst_n) begin
        if (rst_n == 1'b0) begin
            internal_counter <= 64'h0000_0000_0000_0000;
        end
        else begin
            internal_counter <= internal_counter + 1'd1;
        end
    end
    assign mtime = internal_counter;

    assign int_timer = internal_counter > mtimecmp;
endmodule
