/*
 * *****************************************************************
 * File: top_timer_tb.v
 * Category: Timer
 * File Created: 2023/10/09 13:56
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2023/10/09 15:30
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

`define STEP 10

module top_timer_tb;

    reg clk;              // Global Clock
    reg rst_n;            // Global Reset

    wire            int_timer;  // 割込み信号

    reg           sel;        // Select this Memory Block
    reg [15:0]    addr;       // Address
    reg [2:0]     we;         // Write Enable
    reg [31:0]    wdata;      // Write Data
    wire [31:0]   rdata;      // Read Data

    ///////////////////////////////////////////////////////////////////
    // インスタンス
    top_timer U_top_timer(.*);

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
    $dumpfile("top_timer_tb.vcd");
    $dumpvars(0,top_timer_tb);

    rst_n=0;
    sel = 0;
    addr = 0;
    we = 0;
    wdata = 0;


    @(posedge clk)
    @(posedge clk)
    rst_n = 1;

    //////////////////////////////////////////////////////////////////
    // レジスタ初期値確認
    addr = 16'h0000;
    $display("%h:msip",addr);
    assert_eq(rdata,32'h00000000);

    addr = 16'h4000;
    $display("%h:mtimecmp_l",addr);
    assert_eq(rdata,32'h00000000);

    addr = 16'h4004;
    $display("%h:mtimecmp_h",addr);
    assert_eq(rdata,32'h00000000);

    addr = 16'hBFF8;
    $display("%h:mtime_l",addr);
    assert_eq(rdata,32'h00000000);

    addr = 16'hBFFC;
    $display("%h:mtime_h",addr);
    assert_eq(rdata,32'h00000000);

    //////////////////////////////////////////////////////////////////
    // Write -> Read
    addr = 16'h0000;    sel = 1;
    wdata = 32'hAAAAAAAA;
    we = 3'b1_10;
    #(`STEP)
    we = 3'b0_10;
    #(`STEP)
    $display("Write %h:msip",addr);
    assert_eq(rdata,32'hAAAA_AAAA);

    addr = 16'h0000;    sel = 1;
    wdata = 32'hFFFFFFFF;
    we = 3'b1_10;
    #(`STEP)
    we = 3'b0_10;
    #(`STEP)
    $display("Write %h:msip",addr);
    assert_eq(rdata,32'hFFFF_FFFF);

    addr = 16'h0000;    sel = 1;
    wdata = 32'h00000000;
    we = 3'b1_10;
    #(`STEP)
    we = 3'b0_10;
    #(`STEP)
    $display("Write %h:msip",addr);
    assert_eq(rdata,32'h0000_0000);

    addr = 16'h0000;    sel = 1;
    wdata = 32'h55555555;
    we = 3'b1_10;
    #(`STEP)
    we = 3'b0_10;
    #(`STEP)
    $display("Write %h:msip",addr);
    assert_eq(rdata,32'h5555_5555);

    sel=0;
    #(`STEP)
    assert_eq(rdata,32'h00000000);


    // Register out mtimecmpは内部64bit
    // Addr 4000 / 4004
    addr = 16'h4000;    sel = 1;
    wdata = 32'hAAAA_AAAA;
    we = 3'b1_10;
    #(`STEP)
    we = 3'b0_10;
    #(`STEP)
    $display("Write %h:mtimecmp_l",addr);
    assert_eq(rdata,32'hAAAA_AAAA);

    addr = 16'h4004;    sel = 1;
    wdata = 32'hFFFFFFFF;
    we = 3'b1_10;
    #(`STEP)
    we = 3'b0_10;
    #(`STEP)
    $display("Write %h:mtimecmp_h",addr);
    assert_eq(rdata,32'hFFFF_FFFF);

    assert_eq(U_top_timer.mtimecmp,64'hAAAA_AAAA_FFFF_FFFF);

    //////////////////////////////////////////////////////////////////
    // Read
    // mtimeを変更
    force U_top_timer.U_fnc_timer.internal_counter = 64'h0123_4567_89AB_CDEF;
    @(posedge clk)
    @(posedge clk)

    addr = 16'hBFF8;
    @(posedge clk)
    $display("%h:mtime_l",addr);
    assert_eq(rdata,32'h89AB_CDEF);

    addr = 16'hBFFC;
    @(posedge clk)
    $display("%h:mtime_h",addr);
    assert_eq(rdata,32'h0123_4567);

    release U_top_timer.U_fnc_timer.internal_counter;


    $display("All tests pass!!");
    $finish;
end

task assert_eq;
    input [63:0] a;
    input [63:0] b;
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
