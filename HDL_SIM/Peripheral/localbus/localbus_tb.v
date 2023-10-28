/*
 * *****************************************************************
 * File: localbus_tb.v
 * Category: localbus
 * File Created: 2023/10/23 04:29
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2023/10/24 04:18
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
 * 2023/10/23	Masaru Aoki	First Version
 * *****************************************************************
 */

`timescale 1ns/1ns

`define STEP 10

module localbus_tb;
    `include "core_general.vh"
    `include "vga_tb.v"
    `include "gpio_tb.v"
    `include "timer_tb.v"
    `include "ram_tb.v"

    parameter INNUM = 13;      // 入力端子 本数
    parameter OUTNUM = 8;      // 出力端子 本数

    reg               clk;                // Global clock
    reg               rst_n;              // Global Resest

    // Local BUS
    reg  [XLEN-1:0]   addr;               // Address (32bit)
    reg  [XLEN-1:0]   qin;                // Write Data
    reg  [3:0]        we;                 // Write Enable
    wire [XLEN-1:0]   qout;               // Read Data

    // PIN output / input
    reg  [ INNUM-1:0] gpio_pin_in;   // GPIO 端子 (入力)
    wire [OUTNUM-1:0] gpio_pin_out;  // GPIO 端子 (出力)

    wire    hsync;
    wire    vsync;
    wire [3:0]   rdata;
    wire [3:0]   gdata;
    wire [3:0]   bdata;

    reg  [XLEN-1:0]    data;      // Read Data

    ///////////////////////////////////////////////////////////////////
    // インスタンス
    localbus U_localbus(.*);

///////////////////////////////////////////////////////////////////
// Clock
initial
    clk = 0;
always begin
    #(`STEP/2) clk = ~clk;
end

///////////////////////////////////////////////////////////////////
// Test Bench
initial begin
    $dumpfile("localbus_tb.vcd");
    $dumpvars(0,localbus_tb);

    rst_n=0;
    addr = 32'h0000_0000;
    we = 4'b0000;
    qin = 32'h0000_0000;

    @(posedge clk)
    @(posedge clk)
    rst_n = 1;

    @(posedge clk)

    //////////////////////////////////////////////////////////////////
    // VGA
    //////////////////////////////////////////////////////////////////
    // vga_tb();

    //////////////////////////////////////////////////////////////////
    // GPIO
    //////////////////////////////////////////////////////////////////
    gpio_tb();

    //////////////////////////////////////////////////////////////////
    // Timer
    //////////////////////////////////////////////////////////////////
    timer_tb();

    //////////////////////////////////////////////////////////////////
    // Data RAM
    //////////////////////////////////////////////////////////////////
    ram_tb();


    #(`STEP*2)

    $display("All tests pass!!");
    $finish;
end

task assert_eq;
    input [15:0] a;
    input [15:0] b;
    begin
        if(a == b) begin
        end
        else begin
            $display("Assert NG (%h,%h)",a,b);
            #(`STEP*10)
            $stop;
        end
    end
endtask

// CPU Write Byte
task cpu_wr_b;
    input [31:0] address;
    input [31:0] data;
    begin
        addr = address;
        qin = data;
        we = 4'b0001 << address[1:0];
        @(posedge clk);
        we = 4'b0000;
        addr = 32'h0000_0000;
        @(posedge clk);
    end
endtask

// CPU Write Word
task cpu_wr_w;
    input [31:0] address;
    input [31:0] data;
    begin
        addr = address;
        qin = data;
        we = 4'b1111;
        @(posedge clk);
        we = 4'b0000;
        addr = 32'h0000_0000;
        @(posedge clk);
    end
endtask

task cpu_rd;
    input [31:0] address;
    output [31:0] data;
    begin
        addr = address;
        @(posedge clk);
        @(negedge clk);
        data = qout;
        addr = 32'h0000_0000;
        @(posedge clk);
    end
endtask


endmodule
