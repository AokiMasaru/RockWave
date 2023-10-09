/*
 * *****************************************************************
 * File: reg_timer.v
 * Category: Timer
 * File Created: 2023/10/09 11:00
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2023/10/09 15:17
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
module reg_timer(
    input       clk,        // Global clock
    input       rst_n,      // Global Reset

    // Local BUS
    input               sel,        // Select this Memory Block
    input [15:0]        addr,       // Address
    input [2:0]         we,         // Write Enable
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
    assign we_1st = (we[2] == 1'b1); // 1stByte: All Write Access
    assign we_2nd = (we == 3'b1_10) || (we == 3'b1_01);// 2ndByte:Word / HarlWord Access
    assign we_3rd = (we == 3'b1_10); // 3rdByte: Word Access
    assign we_4th = (we == 3'b1_10); // 4thByte: Word Access

    // Address Select
    wire adsel0000 = ({addr[15:2],2'b00} == 16'h0000) & sel;
    wire adsel4000 = ({addr[15:2],2'b00} == 16'h4000) & sel;
    wire adsel4004 = ({addr[15:2],2'b00} == 16'h4004) & sel;
    wire adselBFF8 = ({addr[15:2],2'b00} == 16'hBFF8) & sel;
    wire adselBFFC = ({addr[15:2],2'b00} == 16'hBFFC) & sel;

    // Write Enable for RW reg
    wire wenble0000 = adsel0000 & we_1st;
    wire wenble4000 = adsel4000 & we_1st;
    wire wenble4004 = adsel4004 & we_1st;

    assign rdata = 
        reg0000 |
        reg4000 |
        reg4004 |
        regBFF8 |
        regBFFC
        ;

    reg_rw #(32) U_reg00(
        .clk(clk), .rst_n(rst_n),
        .wdata(wdata), .we(wenble0000), 
        .rdata(reg0000), .re(adsel0000),
        .dataout(msip)
    );

    reg_rw #(32) U_reg4000(
        .clk(clk), .rst_n(rst_n),
        .wdata(wdata  ), .we(wenble4000),
        .rdata(reg4000), .re(adsel4000),
        .dataout(mtimecmp[63:32])
    );

    reg_rw #(32) U_reg4004(
        .clk(clk), .rst_n(rst_n),
        .wdata(wdata  ), .we(wenble4004),
        .rdata(reg4004), .re(adsel4004),
        .dataout(mtimecmp[31: 0])
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
