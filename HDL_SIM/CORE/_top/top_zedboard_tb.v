/*
 * *****************************************************************
 * File: top_zedboard_tb.v
 * Category: top_core
 * File Created: 2019/01/21 12:11
 * Author: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
 * *****
 * Last Modified: 2023/11/12 14:13
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2018  Project RockWave
 * *****************************************************************
 * Description:
 *   
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/1/21	kidtak51	First Version
 * *****************************************************************
 */

`timescale 1ns/1ns

module top_zedboard_tb();

reg clk;
reg [12:0] gpio_pin_in;
wire [7:0] gpio_pin_out;
wire         hsync;
wire         vsync;
wire [3:0]   rdata;
wire [3:0]   gdata;
wire [3:0]   bdata;

wire [13:0] pc = U_top_zedboard.u_top_core.u_top_fetch.program_counter;

localparam XLEN = 32;

top_zedboard U_top_zedboard(
	.clk_in         (clk            ),
    .gpio_pin_in    (gpio_pin_in    ),
    .gpio_pin_out   (gpio_pin_out   ),
    .hsync          (hsync),
    .vsync          (vsync),
    .rdata          (rdata),
    .gdata          (gdata),
    .bdata          (bdata)
);
//gtk wave 波形表示用
wire [XLEN-1:0] pc = U_top_zedboard.u_top_core.u_top_fetch.program_counter;
wire [XLEN-1:0] x01_ra = U_top_zedboard.u_top_core.u_register_file.x1out;
wire [XLEN-1:0] x02_sp = U_top_zedboard.u_top_core.u_register_file.x2out;
wire [XLEN-1:0] x03_gp = U_top_zedboard.u_top_core.u_register_file.x3out;
wire [XLEN-1:0] x04_tp = U_top_zedboard.u_top_core.u_register_file.x4out;
wire [XLEN-1:0] x05_t0 = U_top_zedboard.u_top_core.u_register_file.x5out;
wire [XLEN-1:0] x06_t1 = U_top_zedboard.u_top_core.u_register_file.x6out;
wire [XLEN-1:0] x07_t2 = U_top_zedboard.u_top_core.u_register_file.x7out;
wire [XLEN-1:0] x08_s0_fp = U_top_zedboard.u_top_core.u_register_file.x8out;
wire [XLEN-1:0] x09_s1 = U_top_zedboard.u_top_core.u_register_file.x9out;
wire [XLEN-1:0] x10_a0 = U_top_zedboard.u_top_core.u_register_file.x10out;
wire [XLEN-1:0] x11_a1 = U_top_zedboard.u_top_core.u_register_file.x11out;
wire [XLEN-1:0] x12_a2 = U_top_zedboard.u_top_core.u_register_file.x12out;
wire [XLEN-1:0] x13_a3 = U_top_zedboard.u_top_core.u_register_file.x13out;
wire [XLEN-1:0] x14_a4 = U_top_zedboard.u_top_core.u_register_file.x14out;
wire [XLEN-1:0] x15_a5 = U_top_zedboard.u_top_core.u_register_file.x15out;
wire [XLEN-1:0] x16_a6 = U_top_zedboard.u_top_core.u_register_file.x16out;
wire [XLEN-1:0] x17_a7 = U_top_zedboard.u_top_core.u_register_file.x17out;
wire [XLEN-1:0] x18_s2 = U_top_zedboard.u_top_core.u_register_file.x18out;
wire [XLEN-1:0] x19_s3 = U_top_zedboard.u_top_core.u_register_file.x19out;
wire [XLEN-1:0] x20_s4 = U_top_zedboard.u_top_core.u_register_file.x20out;
wire [XLEN-1:0] x21_s5 = U_top_zedboard.u_top_core.u_register_file.x21out;
wire [XLEN-1:0] x22_s6 = U_top_zedboard.u_top_core.u_register_file.x22out;
wire [XLEN-1:0] x23_s7 = U_top_zedboard.u_top_core.u_register_file.x23out;
wire [XLEN-1:0] x24_s8 = U_top_zedboard.u_top_core.u_register_file.x24out;
wire [XLEN-1:0] x25_s9 = U_top_zedboard.u_top_core.u_register_file.x25out;
wire [XLEN-1:0] x26_s10 = U_top_zedboard.u_top_core.u_register_file.x26out;
wire [XLEN-1:0] x27_s11 = U_top_zedboard.u_top_core.u_register_file.x27out;
wire [XLEN-1:0] x28_t3 = U_top_zedboard.u_top_core.u_register_file.x28out;
wire [XLEN-1:0] x29_t4 = U_top_zedboard.u_top_core.u_register_file.x29out;
wire [XLEN-1:0] x30_t5 = U_top_zedboard.u_top_core.u_register_file.x30out;
wire [XLEN-1:0] x31_t6 = U_top_zedboard.u_top_core.u_register_file.x31out;

//gtk wave 波形表示用 CSR
wire [XLEN-1:0] mstatus     = U_top_zedboard.u_top_core.u_top_csr.mstatus;
wire [XLEN-1:0] mie         = U_top_zedboard.u_top_core.u_top_csr.mie;
wire [XLEN-1:0] mtvec       = U_top_zedboard.u_top_core.u_top_csr.mtvec;
wire [XLEN-1:0] mscratch    = U_top_zedboard.u_top_core.u_top_csr.null_reg340_dataout;
wire [XLEN-1:0] mepc        = U_top_zedboard.u_top_core.u_top_csr.mepc;
wire [XLEN-1:0] mcause      = U_top_zedboard.u_top_core.u_top_csr.mcause;
wire [XLEN-1:0] mtval       = U_top_zedboard.u_top_core.u_top_csr.mtval;
wire [XLEN-1:0] mip         = U_top_zedboard.u_top_core.u_top_csr.null_reg344_dataout;

wire [XLEN-1:0] bus_addr    = U_top_zedboard.U_localbus.U_data_memory.addr<<2;


//clock
initial
    clk = 0;
always begin
    #4 clk = ~clk;
end

initial begin
    //initial
    $dumpfile("top_zedboard_tb.vcd");
    $dumpvars(0,top_zedboard_tb);

    // init input
    gpio_pin_in = 13'h0000;

    ////Core simulation start
    #500;
    gpio_pin_in = 13'h0200;

    #50000000;
    $finish;
end

endmodule
