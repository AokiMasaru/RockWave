/*
 * *****************************************************************
 * File: top_timer.v
 * Category: Timer
 * File Created: 2023/10/09 10:49
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2023/10/09 12:56
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
 * 2023/10/09	Masaru Aoki	First Version
 * *****************************************************************
 */

module top_timer(
    input               clk,        // Global Clock
    input               rst_n,      // Global Reset

    output              int_timer,  // タイマ割込み

    // Local BUS
    input               sel,        // Select this Memory Block
    input [15:0]        addr,       // Address
    input [2:0]         we,         // Write Enable
    input [XLEN-1:0]    wdata,      // Write Data
    output [XLEN-1:0]   rdata       // Read Data
);
    `include "core_general.vh"

    // Connect Wire func & reg
    wire    [63:0]      mtime;
    wire    [63:0]      mtimecmp;

    // 割込み関連
    wire    [XLEN-1:0]  msip;
    
    // func Block
    fnc_timer U_fnc_timer(
        .clk(clk), .rst_n(rst_n),
        .mtime(mtime),
        .mtimecmp(mtimecmp),

        .int_timer(int_timer)
    );

    // reg Block
    reg_timer U_reg_timer(
        .clk(clk), .rst_n(rst_n),
        .sel(sel), .addr(addr),
        .we(we), .wdata(wdata),
        .rdata(rdata),
        .mtime(mtime), .mtimecmp(mtimecmp),
        .msip(msip)
    );

endmodule
