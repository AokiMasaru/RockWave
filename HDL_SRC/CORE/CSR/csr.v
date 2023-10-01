/*
 * *****************************************************************
 * File: csr.v
 * Category: CSR
 * File Created: 2023/09/14 04:56
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2023/09/27 04:38
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2023  Project RockWave
 * *****************************************************************
 * Description:
 *   Control and Status Registers (CSRs)
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2023/09/14	Masaru Aoki	First Version
 * *****************************************************************
 */
module reg_csr(
    input       clk,        // Global clock
    input       rst_n,      // Global Reset

    input  [11:0]     csr_addr,     // Address
    input  [XLEN-1:0] csr_wdata,    // Write Data
    input             csr_we,       // Write Enable

    output [XLEN-1:0] csr_rdata     // Read Data

);
    `include "core_general.vh"



    wire [ XLEN-1:0]     null_reg300_dataout;
    wire [ XLEN-1:0]     null_reg304_dataout;
    wire [ XLEN-1:0]     null_reg305_dataout;
    wire [ XLEN-1:0]     null_reg340_dataout;
    wire [ XLEN-1:0]     null_reg341_dataout;
    wire [ XLEN-1:0]     null_reg342_dataout;
    wire [ XLEN-1:0]     null_reg343_dataout;
    wire [ XLEN-1:0]     null_reg344_dataout;
    wire [ XLEN-1:0]     reg300;                // MSTATUS
    wire [ XLEN-1:0]     reg304;                // MIE
    wire [ XLEN-1:0]     reg305;                // MTVEC
    wire [ XLEN-1:0]     reg340;
    wire [ XLEN-1:0]     reg341;                // MEPC
    wire [ XLEN-1:0]     reg342;                // MCAUSE
    wire [ XLEN-1:0]     reg343;                // MTVAL
    wire [ XLEN-1:0]     reg344;                // MIP

    // Address Select
    wire adsel300 = (csr_addr[11:0] == 12'h300);
    wire adsel304 = (csr_addr[11:0] == 12'h304);
    wire adsel305 = (csr_addr[11:0] == 12'h305);
    wire adsel340 = (csr_addr[11:0] == 12'h340);
    wire adsel341 = (csr_addr[11:0] == 12'h341);
    wire adsel342 = (csr_addr[11:0] == 12'h342);
    wire adsel343 = (csr_addr[11:0] == 12'h343);
    wire adsel344 = (csr_addr[11:0] == 12'h344);

    // Write Enable for RW reg
    wire wenble300 = adsel300 & csr_we;
    wire wenble304 = adsel304 & csr_we;
    wire wenble305 = adsel305 & csr_we;
    wire wenble340 = adsel340 & csr_we;
    wire wenble341 = adsel341 & csr_we;
    wire wenble342 = adsel342 & csr_we;
    wire wenble343 = adsel343 & csr_we;
    wire wenble344 = adsel344 & csr_we;

    assign csr_rdata = 
        reg300 |
        reg304 |
        reg305 |
        reg340 |
        reg341 |
        reg342 |
        reg343 |
        reg344
        ;

    reg_rw #(XLEN) U_reg300(
        .clk(clk), .rst_n(rst_n),
        .wdata(csr_wdata), .we(wenble300), 
        .rdata(reg300), .re(adsel300),
        .dataout(null_reg300_dataout)
    );

    reg_rw #(XLEN) U_reg304(
        .clk(clk), .rst_n(rst_n),
        .wdata(csr_wdata), .we(wenble304), 
        .rdata(reg304), .re(adsel304),
        .dataout(null_reg304_dataout)
    );

    reg_rw #(XLEN) U_reg305(
        .clk(clk), .rst_n(rst_n),
        .wdata(csr_wdata), .we(wenble305), 
        .rdata(reg305), .re(adsel305),
        .dataout(null_reg305_dataout)
    );

    reg_rw #(XLEN) U_reg340(
        .clk(clk), .rst_n(rst_n),
        .wdata(csr_wdata), .we(wenble340), 
        .rdata(reg340), .re(adsel340),
        .dataout(null_reg340_dataout)
    );

    reg_rw #(XLEN) U_reg341(
        .clk(clk), .rst_n(rst_n),
        .wdata(csr_wdata), .we(wenble341), 
        .rdata(reg341), .re(adsel341),
        .dataout(null_reg341_dataout)
    );

    reg_rw #(XLEN) U_reg342(
        .clk(clk), .rst_n(rst_n),
        .wdata(csr_wdata), .we(wenble342), 
        .rdata(reg342), .re(adsel342),
        .dataout(null_reg342_dataout)
    );

    reg_rw #(XLEN) U_reg343(
        .clk(clk), .rst_n(rst_n),
        .wdata(csr_wdata), .we(wenble343), 
        .rdata(reg343), .re(adsel343),
        .dataout(null_reg343_dataout)
    );

    reg_rw #(XLEN) U_reg344(
        .clk(clk), .rst_n(rst_n),
        .wdata(csr_wdata), .we(wenble344), 
        .rdata(reg344), .re(adsel344),
        .dataout(null_reg344_dataout)
    );


endmodule
