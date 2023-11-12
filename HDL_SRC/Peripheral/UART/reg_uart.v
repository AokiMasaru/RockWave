/*
 * *****************************************************************
 * File: reg_uart.v
 * Category: UART
 * File Created: 2023/11/04 13:07
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2023/11/07 03:37
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

module reg_uart(
    input       clk,        // Global clock
    input       rst_n,      // Global Reset

    // Local BUS
    input               sel,        // Select this Memory Block
    input [AWIDTH-1:0]  addr,       // Address
    input [3:0]         we,         // Write Enable
    input [XLEN-1:0]    wdata,      // Write Data
    output [XLEN-1:0]   rdata,      // Read Data

    // for func block
    output              uart_en,
    output [7:0]        tx_reg,     // TX reg
    output              tx_strt,
    output [XLEN-1:0]   refclk_st,
    input               tx_busy
    );
    `include "core_general.vh"


    wire            reg00;         // uart_en
    wire [7:0]      reg04;         // txreg
    wire            reg08;         // tx_busy
    wire [XLEN-1:0] reg0C;         // refclk

    reg             tx_strt;        // wenble04 1dly
    // WriteEnable at Position
    assign we_1st = we[0];  // 1stByte:
    assign we_2nd = we[1];  // 2ndByte:
    assign we_3rd = we[2];  // 3rdByte:
    assign we_4th = we[3];  // 4thByte:

    // Address Select
    wire adsel00 = (addr == 14'h0000) & sel;
    wire adsel04 = (addr == 14'h0001) & sel;
    wire adsel08 = (addr == 14'h0002) & sel;
    wire adsel0C = (addr == 14'h0003) & sel;

    // Write Enable for RW reg
    wire wenble00 = adsel00 & we_1st;
    wire wenble04 = adsel04 & we_1st;

    // 送信データがレジスタに保持されてからスタートする(1dly)
    always @(posedge clk, negedge rst_n) begin
        if (rst_n == 1'b0) begin
            tx_strt <= 1'b0;
        end
        else if(~uart_en) begin
            tx_strt <= 1'b0;
        end
        else begin
            tx_strt <= wenble04;
        end
    end

    wire wenble0C = adsel0C & we_1st;
    wire wenble0D = adsel0C & we_2nd;
    wire wenble0E = adsel0C & we_3rd;
    wire wenble0F = adsel0C & we_4th;

    assign rdata = 
        { 8'h00, 8'h00, 8'h00, 7'h00, reg00} |
        { 8'h00, 8'h00, 8'h00, reg04} |
        { 8'h00, 8'h00, 8'h00, 7'h00, reg08} |
        reg0C
        ;

    reg_rw U_reg00(
        .clk(clk), .rst_n(rst_n),
        .wdata(wdata[0]), .we(wenble00), 
        .rdata(reg00), .re(adsel00),
        .dataout(uart_en)
    );

    reg_rw #(8) U_reg04(
        .clk(clk), .rst_n(rst_n),
        .wdata(wdata[7:0]), .we(wenble04), 
        .rdata(reg04), .re(adsel04),
        .dataout(tx_reg)
    );

    reg_ronly U_reg08(
        .clk(clk), .rst_n(rst_n),
        .datain(tx_busy), .re(adsel08),
        .rdata(reg08)
    );

    reg_rw #(8) U_reg0C(
        .clk(clk), .rst_n(rst_n),
        .wdata(wdata[7:0]), .we(wenble0C), 
        .rdata(reg0C[7:0]), .re(adsel0C),
        .dataout(refclk_st[7:0])
    );
    reg_rw #(8) U_reg0D(
        .clk(clk), .rst_n(rst_n),
        .wdata(wdata[15:8]), .we(wenble0D), 
        .rdata(reg0C[15:8]), .re(adsel0C),
        .dataout(refclk_st[15:8])
    );
    reg_rw #(8) U_reg0E(
        .clk(clk), .rst_n(rst_n),
        .wdata(wdata[23:16]), .we(wenble0E), 
        .rdata(reg0C[23:16]), .re(adsel0C),
        .dataout(refclk_st[23:16])
    );
    reg_rw #(8) U_reg0F(
        .clk(clk), .rst_n(rst_n),
        .wdata(wdata[31:24]), .we(wenble0F), 
        .rdata(reg0C[31:24]), .re(adsel0C),
        .dataout(refclk_st[31:24])
    );

endmodule
