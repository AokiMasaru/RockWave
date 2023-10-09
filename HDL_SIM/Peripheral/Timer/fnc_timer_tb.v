/*
 * *****************************************************************
 * File: fnc_timer_tb.v
 * Category: Timer
 * File Created: 2023/10/09 13:21
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2023/10/09 13:48
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

module fnc_timer_tb;

    reg clk;              // Global Clock
    reg rst_n;            // Global Reset

    reg  [63:0] mtimecmp;   // mtimecmp
    wire [63:0] mtime;      // mtime
    wire        int_timer;  // タイマ割込み

    ///////////////////////////////////////////////////////////////////
    // インスタンス
    fnc_timer U_fnc_timer(.*);

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
        $dumpfile("fnc_timer.vcd");
        $dumpvars(0,fnc_timer_tb);

        rst_n=0;
        mtimecmp = 64'h0000_0000_0000_0000; // Registerブロック初期値

        // Reset時割込みはなし
        #(`STEP*10)
        $display("not interupt in RESET");
        assert_eq(int_timer,0);

        @(posedge clk)
        @(posedge clk)
        rst_n = 1;

        //////////////////////////////////////////////////////////////////
        // フリーランカウンタ
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        // 10clk後
        assert_eq(mtime,64'd10);

        // 割込み確認
        mtimecmp = 64'd16;  // 16clk後以降(≒17clk)
        assert_eq(int_timer,0);

        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)// 15clk後
        assert_eq(int_timer,0);
        @(posedge clk)// 16clk後
        assert_eq(int_timer,0);
        @(posedge clk)// 17clk後
        assert_eq(int_timer,1);     // 割込み発生

        // mtimecmpを更新したら割り込み落ちる
        mtimecmp = 64'd100;  // 100clk後以降(≒101clk)
        assert_eq(int_timer,0);     // 割込みなし


        $display("All tests pass!!");
        $finish;
    end

    task assert_eq;
        input a;
        input b;
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
