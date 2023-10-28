/*
 * *****************************************************************
 * File: top_gpio_tb.v
 * Category: GPIO
 * File Created: 2019/03/03 11:54
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2023/10/28 13:13
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:
 *   TestBench for fnc_gpio
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2023/10/22	Masaru Aoki	32bitメモリに1Byte単位でアクセスする
 * 2019/03/03	Masaru Aoki	First Version
 * *****************************************************************
 */

`define STEP 10

module top_gpio_tb;

    reg clk;              // Global Clock
    reg rst_n;            // Global Reset

    reg  [12:0] gpio_pin_in;   // GPIO 端子 (入力)
    wire [ 7:0] gpio_pin_out;  // GPIO 端子 (出力)

    reg           sel;        // Select this Memory Block
    reg [13:0]    addr;       // Address
    reg [3:0]     we;         // Write Enable
    reg [31:0]    wdata;      // Write Data
    wire [31:0]   rdata;      // Read Data

    ///////////////////////////////////////////////////////////////////
    // インスタンス
    top_gpio U_top_gpio(.*);

///////////////////////////////////////////////////////////////////
// Clock
initial
    clk = 0;
always begin
    #(`STEP/5) clk = ~clk;
end

///////////////////////////////////////////////////////////////////
// Test Bench
initial begin
    $dumpfile("top_gpio.vcd");
    $dumpvars(0,top_gpio_tb);

    rst_n=0;
    gpio_pin_in = 0;
    sel = 0;
    addr = 0;
    we = 0;
    wdata = 0;


    @(posedge clk)
    @(posedge clk)
    rst_n = 1;

    //////////////////////////////////////////////////////////////////
    // レジスタ初期値確認
    addr = 12'h000;
    sel = 1;
    #(`STEP)
    assert_eq(rdata,32'h00000000);

    addr = 12'h004;
    sel = 1;
    #(`STEP)
    assert_eq(rdata,32'h00000000);

    addr = 12'h010;
    sel = 1;
    #(`STEP)
    assert_eq(rdata,32'h00000000);

    addr = 12'h020;
    sel = 1;
    #(`STEP)
    assert_eq(rdata,32'h00000000);

    //////////////////////////////////////////////////////////////////
    // Write -> Read
    // Addr 000 byte Access
    addr = 14'h000;    sel = 1;
    wdata = 32'hAAAAAAAA;
    we = 4'b0001;
    #(`STEP)
    we = 4'b000;
    #(`STEP)
    assert_eq(rdata,32'h000000AA);

    addr = 14'h000;    sel = 1;
    wdata = 32'hFFFFFFFF;
    we = 4'b0001;
    #(`STEP)
    we = 4'b000;
    #(`STEP)
    assert_eq(rdata,32'h000000FF);

    addr = 14'h000;    sel = 1;
    wdata = 32'h00000000;
    we = 4'b0001;
    #(`STEP)
    we = 4'b0000;
    #(`STEP)
    assert_eq(rdata,32'h00000000);

    addr = 14'h000;    sel = 1;
    wdata = 32'h55555555;
    we = 4'b0001;
    #(`STEP)
    we = 4'b000;
    #(`STEP)
    assert_eq(rdata,32'h00000055);

    sel=0;
    #(`STEP)
    assert_eq(rdata,32'h00000000);

    // Addr 004
    addr = 14'h004;    sel = 1;
    wdata = 32'hAAAAAAAA;
    we = 4'b0001;
    #(`STEP)
    we = 4'b000;
    #(`STEP)
    assert_eq(rdata,32'h000000AA);

    addr = 14'h004;    sel = 1;
    wdata = 32'hFFFFFFFF;
    we = 4'b0001;
    #(`STEP)
    we = 4'b000;
    #(`STEP)
    assert_eq(rdata,32'h000000FF);

    addr = 14'h004;    sel = 1;
    wdata = 32'h00000000;
    we = 4'b0001;
    #(`STEP)
    we = 4'b0000;
    #(`STEP)
    assert_eq(rdata,32'h00000000);

    addr = 14'h004;    sel = 1;
    wdata = 32'h55555555;
    we = 4'b0001;
    #(`STEP)
    we = 4'b000;
    #(`STEP)
    assert_eq(rdata,32'h00000055);

    sel=0;
    #(`STEP)
    assert_eq(rdata,32'h00000000);

    // GPIO out
    // Addr 020 Byte Write
    addr = 14'h020;    sel = 1;
    wdata = 32'hAAAAAAAA;
    we = 4'b0001;
    #(`STEP)
    we = 4'b0000;
    #(`STEP)
    assert_eq(rdata,32'h000000AA);

    addr = 14'h020;    sel = 1;
    wdata = 32'hFFFFFFFF;
    we = 4'b0001;
    #(`STEP)
    we = 4'b0000;
    #(`STEP)
    assert_eq(rdata,32'h000000FF);

    addr = 14'h020;    sel = 1;
    wdata = 32'h00000000;
    we = 4'b0001;
    #(`STEP)
    we = 4'b0000;
    #(`STEP)
    assert_eq(rdata,32'h00000000);

    addr = 14'h020;    sel = 1;
    wdata = 32'h55555555;
    we = 4'b0001;
    #(`STEP)
    we = 4'b0000;
    #(`STEP)
    assert_eq(rdata,32'h00000055);

    sel=0;
    #(`STEP)
    assert_eq(rdata,32'h00000000);

    //////////////////////////////////////////////////////////////////
    // Read
    // Addr 010 
    rst_n = 0;          // refclkを初期化
    @(posedge clk)
    @(posedge clk)
    rst_n = 1;

    // Dfilter = 0
    addr = 14'h000;    sel = 1;
    wdata = 32'h00000000;
    we = 4'b0001;
    #(`STEP)
    we = 4'b0000;
    #(`STEP)
    assert_eq(rdata,32'h00000000);
    // refclk
    addr = 14'h004;    sel = 1;
    wdata = 32'h00000000;
    we = 4'b0001;
    #(`STEP)
    we = 4'b0000;
    #(`STEP)
    assert_eq(rdata,32'h00000000);

    gpio_pin_in = 16'hFFFF;
    sel = 0;
    #(`STEP)
    #(`STEP)
    addr = 14'h010;    sel = 1;
    #(`STEP)
    assert_eq(rdata,32'h00001FFF);

    gpio_pin_in = 16'h5555;
    sel = 0;
    #(`STEP)
    #(`STEP)
    addr = 14'h010;    sel = 1;
    #(`STEP)
    assert_eq(rdata,32'h00001555);

    gpio_pin_in = 16'hAAAA;
    sel = 0;
    #(`STEP)
    #(`STEP)
    addr = 14'h010;    sel = 1;
    #(`STEP)
    assert_eq(rdata,32'h00000AAA);

    gpio_pin_in = 16'h0000;
    sel = 0;
    #(`STEP)
    #(`STEP)
    addr = 14'h010;    sel = 1;
    #(`STEP)
    assert_eq(rdata,32'h00000000);


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
