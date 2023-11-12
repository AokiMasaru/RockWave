/*
 * *****************************************************************
 * File: top_uart_tb.v
 * Category: uart
 * File Created: 2023/11/05 13:54
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2023/11/06 05:32
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
 * 2023/11/05	Masaru Aoki	First Version
 * *****************************************************************
 */

// 100MHz
`define STEP 10
`timescale 1ns/1ns
module top_uart_tb;

    reg clk;              // Global Clock
    reg rst_n;            // Global Reset

    reg         rxd;            // UART 端子 (入力)
    wire        txd;            // UART 端子 (出力)

    reg           sel;        // Select this Memory Block
    reg [13:0]    addr;       // Address
    reg [3:0]     we;         // Write Enable
    reg [31:0]    wdata;      // Write Data
    wire [31:0]   rdata;      // Read Data

    ///////////////////////////////////////////////////////////////////
    // インスタンス
    top_uart U_top_uart(.*);

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
    $dumpfile("top_uart.vcd");
    $dumpvars(0,top_uart_tb);

    rst_n=0;
    rxd = 0;
    sel = 0;
    addr = 0;
    we = 0;
    wdata = 0;


    @(posedge clk)
    @(posedge clk)
    rst_n = 1;

    //////////////////////////////////////////////////////////////////
    // レジスタ初期値確認
    $display("reset reg check");
    addr = 14'h000;
    sel = 1;
    #(`STEP)
    assert_eq(rdata,32'h00000000);

    addr = 12'h001;
    sel = 1;
    #(`STEP)
    assert_eq(rdata,32'h00000000);

    addr = 12'h003;
    sel = 1;
    #(`STEP)
    assert_eq(rdata,32'h00000000);

    //////////////////////////////////////////////////////////////////
    // Write -> Read
    // Addr 000 byte Access
    $display("Write->Read 004");
    addr = 14'h001;    sel = 1;
    wdata = 32'hAAAAAAAA;
    we = 4'b0001;
    #(`STEP)
    we = 4'b0000;
    #(`STEP)
    assert_eq(rdata,32'h000000AA);

    addr = 14'h001;    sel = 1;
    wdata = 32'hFFFFFFFF;
    we = 4'b0001;
    #(`STEP)
    we = 4'b0000;
    #(`STEP)
    assert_eq(rdata,32'h000000FF);

    addr = 14'h001;    sel = 1;
    wdata = 32'h00000000;
    we = 4'b0001;
    #(`STEP)
    we = 4'b0000;
    #(`STEP)
    assert_eq(rdata,32'h00000000);

    addr = 14'h001;    sel = 1;
    wdata = 32'h55555555;
    we = 4'b0001;
    #(`STEP)
    we = 4'b0000;
    #(`STEP)
    assert_eq(rdata,32'h00000055);

    sel=0;
    #(`STEP)
    assert_eq(rdata,32'h00000000);

    // Addr 00C
    $display("Write->Read 00C");
    addr = 14'h003;    sel = 1;
    wdata = 32'hAAAA_AAAA;
    we = 4'b1111;
    #(`STEP)
    we = 4'b0000;
    #(`STEP)
    assert_eq(rdata,32'h0AAAA_AAAA);

    addr = 14'h003;    sel = 1;
    wdata = 32'hFFFF_FFFF;
    we = 4'b1111;
    #(`STEP)
    we = 4'b0000;
    #(`STEP)
    assert_eq(rdata,32'hFFFF_FFFF);

    addr = 14'h003;    sel = 1;
    wdata = 32'h0000_0000;
    we = 4'b1111;
    #(`STEP)
    we = 4'b0000;
    #(`STEP)
    assert_eq(rdata,32'h0000_0000);

    addr = 14'h003;    sel = 1;
    wdata = 32'h5555_5555;
    we = 4'b1111;
    #(`STEP)
    we = 4'b0000;
    #(`STEP)
    assert_eq(rdata,32'h5555_5555);

    sel=0;
    #(`STEP)
    assert_eq(rdata,32'h00000000);

    //////////////////////////////////////////////////////////////////
    // refclk

    // 115kbps = 1/115200 = 8680ns = 868cnt/16 = 54.25347
    addr = 14'h003;    sel = 1;
    wdata = 32'd55;
    we = 4'b1111;
    #(`STEP)
    we = 4'b0000;
    #(`STEP)

    // uart_en=1    
    addr = 14'h000;    sel = 1;
    wdata = 32'h0000_0001;
    we = 4'b0001;
    #(`STEP)
    we = 4'b0000;
    #(`STEP)

    // 送信スタート
    addr = 14'h001;    sel = 1;
    wdata = 32'h0000_0041;
    we = 4'b0001;
    #(`STEP)
    we = 4'b0000;
    #(`STEP)

    @(negedge U_top_uart.tx_busy)

    #(`STEP*100)

    // 送信スタート
    addr = 14'h001;    sel = 1;
    wdata = 32'h0000_0042;
    we = 4'b0001;
    #(`STEP)
    we = 4'b0000;
    #(`STEP)

    @(negedge U_top_uart.tx_busy)

    #(`STEP*100)

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

endmodule
