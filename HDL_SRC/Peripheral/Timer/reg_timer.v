/*
 * *****************************************************************
 * File: reg_timer.v
 * Category: Timer
 * File Created: 2023/10/09 11:00
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2023/10/28 13:25
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
 * 2023/10/28	Masaru Aoki	32bitメモリに8bit単位でアクセスする
 * 2023/10/09	Masaru Aoki	First Version
 * *****************************************************************
 */
module reg_timer(
    input       clk,        // Global clock
    input       rst_n,      // Global Reset

    // Local BUS
    input               sel,        // Select this Memory Block
    input [15:0]        addr,       // Address
    input [3:0]         we,         // Write Enable
    input [XLEN-1:0]    wdata,      // Write Data
    output [XLEN-1:0]   rdata,     // Read Data

    // for func block
    output [63:0]       mtimecmp,   // 64bit timer compare register
    input  [63:0]       mtime,      // 64bit Timer register

    output [31:0]       msip
    );
    `include "core_general.vh"

    wire [XLEN-1:0]     reg0000;        // msip
    wire [XLEN-1:0]     reg4000;        // mtimecmp
    wire [XLEN-1:0]     reg4004;        // mtimecmp
    wire [XLEN-1:0]     regBFF8;        // mtime
    wire [XLEN-1:0]     regBFFC;        // mtime

    // WriteEnable at Position
    assign we_1st = we[0];  // 1stByte:
    assign we_2nd = we[1];  // 2ndByte:
    assign we_3rd = we[2];  // 3rdByte:
    assign we_4th = we[3];  // 4thByte:

    // Address Select
    wire adsel0000 = addr == 14'h0000 & sel;
    wire adsel4000 = addr == 14'h1000 & sel;
    wire adsel4004 = addr == 14'h1001 & sel;
    wire adselBFF8 = addr == 14'h2FFE & sel;
    wire adselBFFC = addr == 14'h2FFF & sel;

    // Write Enable for RW reg
    wire wenble0000 = adsel0000 & we_1st;
    wire wenble0001 = adsel0000 & we_2nd;
    wire wenble0002 = adsel0000 & we_3rd;
    wire wenble0003 = adsel0000 & we_4th;
    wire wenble4000 = adsel4000 & we_1st;
    wire wenble4001 = adsel4000 & we_2nd;
    wire wenble4002 = adsel4000 & we_3rd;
    wire wenble4003 = adsel4000 & we_4th;
    wire wenble4004 = adsel4004 & we_1st;
    wire wenble4005 = adsel4004 & we_2nd;
    wire wenble4006 = adsel4004 & we_3rd;
    wire wenble4007 = adsel4004 & we_4th;

    assign rdata = 
        reg0000 |
        reg4000 |
        reg4004 |
        regBFF8 |
        regBFFC
        ;

    reg_rw #(8) U_reg00(
        .clk(clk), .rst_n(rst_n),
        .wdata(wdata[7:0]), .we(wenble0000), 
        .rdata(reg0000[7:0]), .re(adsel0000),
        .dataout(msip[7:0])
    );
    reg_rw #(8) U_reg01(
        .clk(clk), .rst_n(rst_n),
        .wdata(wdata[15:8]), .we(wenble0001), 
        .rdata(reg0000[15:8]), .re(adsel0000),
        .dataout(msip[15:8])
    );
    reg_rw #(8) U_reg02(
        .clk(clk), .rst_n(rst_n),
        .wdata(wdata[23:16]), .we(wenble0002), 
        .rdata(reg0000[23:16]), .re(adsel0000),
        .dataout(msip[23:16])
    );
    reg_rw #(8) U_reg03(
        .clk(clk), .rst_n(rst_n),
        .wdata(wdata[31:24]), .we(wenble0003), 
        .rdata(reg0000[31:24]), .re(adsel0000),
        .dataout(msip[31:24])
    );

    reg_rw #(8) U_reg4000(
        .clk(clk), .rst_n(rst_n),
        .wdata(wdata[7:0]), .we(wenble4000),
        .rdata(reg4000[7:0]), .re(adsel4000),
        .dataout(mtimecmp[7:0 ])
    );

    reg_rw #(8) U_reg4001(
        .clk(clk), .rst_n(rst_n),
        .wdata(wdata[15:8]), .we(wenble4001),
        .rdata(reg4000[15:8]), .re(adsel4000),
        .dataout(mtimecmp[15:8])
    );

    reg_rw #(8) U_reg4002(
        .clk(clk), .rst_n(rst_n),
        .wdata(wdata[23:16]), .we(wenble4002),
        .rdata(reg4000[23:16]), .re(adsel4000),
        .dataout(mtimecmp[23:16])
    );

    reg_rw #(8) U_reg4003(
        .clk(clk), .rst_n(rst_n),
        .wdata(wdata[31:24]), .we(wenble4003),
        .rdata(reg4000[31:24]), .re(adsel4000),
        .dataout(mtimecmp[31:24])
    );

    reg_rw #(8) U_reg4004(
        .clk(clk), .rst_n(rst_n),
        .wdata(wdata[7:0]), .we(wenble4004),
        .rdata(reg4004[7:0]), .re(adsel4004),
        .dataout(mtimecmp[39:32])
    );

    reg_rw #(8) U_reg4005(
        .clk(clk), .rst_n(rst_n),
        .wdata(wdata[15:8]), .we(wenble4005),
        .rdata(reg4004[15:8]), .re(adsel4004),
        .dataout(mtimecmp[47:40])
    );

    reg_rw #(8) U_reg4006(
        .clk(clk), .rst_n(rst_n),
        .wdata(wdata[23:16]), .we(wenble4006),
        .rdata(reg4004[23:16]), .re(adsel4004),
        .dataout(mtimecmp[55:48])
    );

    reg_rw #(8) U_reg4007(
        .clk(clk), .rst_n(rst_n),
        .wdata(wdata[31:24]), .we(wenble4007),
        .rdata(reg4004[31:24]), .re(adsel4004),
        .dataout(mtimecmp[63:56])
    );

    reg_ronly #(32) U_regBFF8(
        .clk(clk), .rst_n(rst_n),
        .datain(mtime[31:0]),
        .rdata(regBFF8), .re(adselBFF8)
    );

    reg_ronly #(32) U_regBFFC(
        .clk(clk), .rst_n(rst_n),
        .datain(mtime[63:32]),
        .rdata(regBFFC), .re(adselBFFC)
    );

endmodule
