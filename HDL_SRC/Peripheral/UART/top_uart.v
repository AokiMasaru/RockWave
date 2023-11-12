/*
 * *****************************************************************
 * File: top_uart.v
 * Category: UART
 * File Created: 2023/11/04 12:57
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2023/11/05 16:07
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2023  Project RockWave
 * *****************************************************************
 * Description:
 *   UARTモジュール　まずは送信レジスタのみ
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2023/11/04	Masaru Aoki	First Version
 * *****************************************************************
 */

module top_uart(
    input               clk,        // Global Clock
    input               rst_n,      // Global Reset

     // Local BUS
    input               sel,        // Select this Memory Block
    input [AWIDTH-1:0]  addr,       // Address
    input [3:0]         we,         // Write Enable
    input [XLEN-1:0]    wdata,      // Write Data
    output [XLEN-1:0]   rdata,      // Read Data

    output              txd         // Transfer Data
);
    `include "core_general.vh"

    wire        uart_en;
    wire [7:0]  tx_reg;
    wire        tx_busy;
    wire        tx_strt;
    wire [31:0] refclk_st;

    `define STRT
    

    // func Block
    fnc_uart U_fnc_uart(
        .clk(clk), .rst_n(rst_n),

        .uart_en(uart_en),
        .refclk_st(refclk_st),
        .tx_reg(tx_reg),
        .tx_busy(tx_busy),
        .tx_strt(tx_strt),

        .txd(txd)
    );

    // reg Block
    reg_uart U_reg_uart(
        .clk(clk), .rst_n(rst_n),
        .sel(sel), .addr(addr),
        .we(we), .wdata(wdata),
        .rdata(rdata),
        .uart_en(uart_en),
        .refclk_st(refclk_st),
        .tx_reg(tx_reg),
        .tx_strt(tx_strt),
        .tx_busy(tx_busy)
    );

endmodule
