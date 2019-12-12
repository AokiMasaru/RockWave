/*
 * *****************************************************************
 * File: top_hdmicontroller_tb.v
 * Category: hdmi
 * File Created: 2019/10/24 06:56
 * Author: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
 * *****
 * Last Modified: 2019/12/12 21:40
 * Modified By: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:
 *   hdmi.vは別途テストしているため、
 *   本テストベンチでは、主にlocal busからhdmi_vramに値を格納し、
 *   hdmi_vramからu_hdmiにデータが流れることを確認する。
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/12/12	kidtak51	vramに使用しているblockramの容量削減
 * 2019/10/24	kidtak51	First Version
 * *****************************************************************
 */

`timescale 1ns/1ns

`define STEP_X1 50
`define STEP_X5 10
`define test

module top_hdmicontroller_tb;
    `include "core_general.vh"
    
    reg clk_pix;   // 画像クロック
    reg clk_pix_x5;// 画像クロック x5
    reg rst_n;     // リセット
    parameter TESTBITWIDTH = 32; //検証task用bit幅。assert_compare_mで使用。

    wire hdmi_clk_n;
    wire hdmi_clk_p;
    wire[2:0] hdmi_data_n;
    wire[2:0] hdmi_data_p;
    ///////////////////////////////////////////////////////////////////
    // インスタンス
    top_hdmicontroller u_top_hdmicontroller(.*);

    // input clk,                      //汎用ロジッククロック
    // input clk_pix,                  //画像クロック 720pでは74.25MHz
    // input clk_pix_x5,               //5逓倍した画像クロック
    // input rst_n,                    //リセット 負論理
    // output hdmi_clk_n,              //hdmiクロック, IOに接続
    // output hdmi_clk_p,              //hdmiクロック, IOに接続
    // output[2:0] hdmi_data_n,        //hdmiデータ(rgbの3bit), IOに接続
    // output[2:0] hdmi_data_p,        //hdmiデータ(rgbの3bit), IOに接続
    // input               sel,        // Select this Memory Block
    // input [XLEN-1:0]    addr,       // Address
    // input [2:0]         we,         // Write Enable
    // input [XLEN-1:0]    qin,        // Write Data
    // output [XLEN-1:0]   qout        // Read Data

    ///////////////////////////////////////////////////////////////////
    // Clock生成
    initial
        clk_pix = 0;
    always begin
        #(`STEP_X1/2) clk_pix = ~clk_pix;
    end
    // Clock
    initial
        clk_pix_x5 = 0;
    always begin
        #(`STEP_X5/2) clk_pix_x5 = ~clk_pix_x5;
    end

///////////////////////////////////////////////////////////////////
// Test Bench
reg[31:0] addr;
reg[2:0] we;
reg[31:0] wdata;
reg sel;
assign clk = clk_pix;
wire[31:0] qin;
assign qin = wdata;
wire[31:0] qout;
integer i;

//Get u_hdmi parameters 
wire[31:0] h_max       = u_top_hdmicontroller.u_hdmi.h_max;
wire[31:0] h_valid_max = h_max;
wire[31:0] h_sync_min  = u_top_hdmicontroller.u_hdmi.h_sync_min;
wire[31:0] h_sync_max  = u_top_hdmicontroller.u_hdmi.h_sync_max;
wire[31:0] h_valid_min = u_top_hdmicontroller.u_hdmi.h_valid_min;
wire[31:0] v_max       = u_top_hdmicontroller.u_hdmi.v_max;
wire[31:0] v_valid_max = v_max;
wire[31:0] v_sync_min  = u_top_hdmicontroller.u_hdmi.v_sync_min;
wire[31:0] v_sync_max  = u_top_hdmicontroller.u_hdmi.v_sync_max;
wire[31:0] v_valid_min = u_top_hdmicontroller.u_hdmi.v_valid_min;

wire[11:0] v_pos  = u_top_hdmicontroller.v_pos;
wire[11:0] h_pos_tmp = u_top_hdmicontroller.h_pos -1;
wire[11:0] h_pos = (h_valid_max - h_valid_min) < h_pos_tmp ? 0 : h_pos_tmp;
wire[31:0] ref_data = h_pos/4 + v_pos/4*(h_valid_max - h_valid_min)/4;
wire[7:0] ref_data_subset = ref_data[7:0];

initial begin
    $dumpfile("top_hdmicontroller_tb.vcd");
    $dumpvars(0, top_hdmicontroller_tb);
    rst_n = 1'b0;

    addr = 32'h0000_0000;
    we = 3'b000;
    wdata = 32'h0000_0000;

    @(posedge clk) #1
    rst_n = 1'b1;
    @(posedge clk) #1

    //u_hdmi.u_rgb2dviに信号がつながっていることを確認
    force u_top_hdmicontroller.u_hdmi.u_rgb2dvi.TMDS_Clk_p = 1;#1;
    assert_compare_m(1, hdmi_clk_p, "==", "connection chk", `__LINE__);
    force u_top_hdmicontroller.u_hdmi.u_rgb2dvi.TMDS_Clk_p = 0;#1;
    assert_compare_m(0, hdmi_clk_p, "==", "connection chk", `__LINE__);

    force u_top_hdmicontroller.u_hdmi.u_rgb2dvi.TMDS_Clk_n = 1;#1;
    assert_compare_m(1, hdmi_clk_n, "==", "connection chk", `__LINE__);
    force u_top_hdmicontroller.u_hdmi.u_rgb2dvi.TMDS_Clk_n = 0;#1;
    assert_compare_m(0, hdmi_clk_n, "==", "connection chk", `__LINE__);

    force u_top_hdmicontroller.u_hdmi.u_rgb2dvi.TMDS_Data_p = 7;#1;
    assert_compare_m(7, hdmi_data_p, "==", "connection chk", `__LINE__);
    force u_top_hdmicontroller.u_hdmi.u_rgb2dvi.TMDS_Data_p = 0;#1;
    assert_compare_m(0, hdmi_data_p, "==", "connection chk", `__LINE__);

    force u_top_hdmicontroller.u_hdmi.u_rgb2dvi.TMDS_Data_n = 7;#1;
    assert_compare_m(7, hdmi_data_n, "==", "connection chk", `__LINE__);
    force u_top_hdmicontroller.u_hdmi.u_rgb2dvi.TMDS_Data_n = 0;#1;
    assert_compare_m(0, hdmi_data_n, "==", "connection chk", `__LINE__);

    //clk_pix接続チェック
    @(posedge clk_pix) #1
    assert_compare_m(clk_pix, u_top_hdmicontroller.u_hdmi.clk_pix, "==", "connection chk", `__LINE__);
    @(negedge clk_pix) #1
    assert_compare_m(clk_pix, u_top_hdmicontroller.u_hdmi.clk_pix, "==", "connection chk", `__LINE__);
    //clk_pix_x5接続チェック
    @(posedge clk_pix_x5) #1
    assert_compare_m(clk_pix_x5, u_top_hdmicontroller.u_hdmi.clk_pix_x5, "==", "connection chk", `__LINE__);
    @(negedge clk_pix_x5) #1
    assert_compare_m(clk_pix_x5, u_top_hdmicontroller.u_hdmi.clk_pix_x5, "==", "connection chk", `__LINE__);
    
    @(posedge clk_pix) #1


    ////////////////////////////////////////////
    //VRAMに書き込んで読みだす確認
    
    //VRAMに検証用データを1画面分格納
    //blockramの容量を減らすために水平側と垂直側の解像度を1/4にする
    for (i = 0; i < h_max/4*v_max/4 ; i = i + 1) begin
        cpu_wr(32'h0020_0000 + i, i);
    end
    @(posedge clk_pix) #1;

    //検証用データを1画面分チェック
    //blockramの容量を減らすために水平側と垂直側の解像度を1/4にする。また4画素に1回の判定にする。
    for (i = 0; i < h_max/4*v_max/4 ; i = i + 1) begin
        if (u_top_hdmicontroller.u_hdmi.h_valid) begin
            assert_compare_m(u_top_hdmicontroller.pix_data[7:0], ref_data_subset[7:0], "==", i, `__LINE__);
        end
        @(posedge clk_pix);
        @(posedge clk_pix);
        @(posedge clk_pix);
        @(posedge clk_pix);
    end


    $display("All tests pass!!");
    $finish;
end


//byteアクセス
task cpu_wr;
    input [31:0] address;
    input [31:0] inData;
    begin
        sel = 1'b1;
        addr = address;
        wdata = inData;
        we = 3'b100;
        @(posedge clk);
    end
endtask

//値を比較する
task assert_compare_m;
    input [TESTBITWIDTH-1:0] expectValue;
    input [TESTBITWIDTH-1:0] resultValue;
    input [0:8*2] compareType;//==, !=, >, >=, < or <=
    input [0:8*50-1] message;
    input [15:0] line;
    begin
        case (compareType)
            "==":begin
                if(expectValue == resultValue) begin
                end
                else begin
                    $display("Assert. NOT 'value1 == value2' (value1:%h, value2:%h, Line:%05d, message:%s)", expectValue, resultValue, line, message);
                    #1
                    $finish;
                end
            end
            "!=":begin
                if(expectValue != resultValue) begin
                end
                else begin
                    $display("Assert. NOT 'value1 != value2' (value1:%h, value2:%h, Line:%05d, message:%s)", expectValue, resultValue, line, message);
                    #1
                    $finish;
                end
            end
            ">":begin
                if(expectValue > resultValue) begin
                end
                else begin
                    $display("Assert. NOT 'value1 > value2' (value1:%h, value2:%h, Line:%05d, message:%s)", expectValue, resultValue, line, message);
                    #1
                    $finish;
                end
            end
            ">=":begin
                if(expectValue >= resultValue) begin
                end
                else begin
                    $display("Assert. NOT 'value1 >= value2' (value1:%h, value2:%h, Line:%05d, message:%s)", expectValue, resultValue, line, message);
                    #1
                    $finish;
                end
            end
            "<":begin
                if(expectValue < resultValue) begin
                end
                else begin
                    $display("Assert. NOT 'value1 < value2' (value1:%h, value2:%h, Line:%05d, message:%s)", expectValue, resultValue, line, message);
                    #1
                    $finish;
                end
            end
            "<=":begin
                if(expectValue <= resultValue) begin
                end
                else begin
                    $display("Assert. NOT 'value1 <= value2' (value1:%h, value2:%h, Line:%05d, message:%s)", expectValue, resultValue, line, message);
                    #1
                    $finish;
                end
            end
            default: begin
                $display("Error. 3rd Argment is %s(Line:%05d). 3rd Argment is only ==, !=, >, >=, < or <=.", compareType, line);
                #1
                $finish;
            end
        endcase
    end
endtask


endmodule
