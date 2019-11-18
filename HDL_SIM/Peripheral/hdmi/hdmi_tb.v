/*
 * *****************************************************************
 * File: top_hdmicontroller_tb.v
 * Category: hdmi
 * File Created: 2019/10/24 06:56
 * Author: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
 * *****
 * Last Modified: 2019/11/12 22:18
 * Modified By: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:
 *   
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/10/24	kidtak51	First Version
 * *****************************************************************
 */

`timescale 1ns/1ns

`define STEP_X1 50
`define STEP_X5 10
`define test
//`define TESTBITWIDTH 32



module hdmi_tb;

    reg clk_pix; // 画像クロック
    reg clk_pix_x5;// 画像クロック x5
    reg rst_n;// リセット
    parameter TESTBITWIDTH = 32;

    wire[11:0] h_pos;
    wire[11:0] v_pos;
    reg[23:0] data;
    wire hdmi_clk_n;
    wire hdmi_clk_p;
    wire[2:0] hdmi_data_n;
    wire[2:0] hdmi_data_p;
    ///////////////////////////////////////////////////////////////////
    // インスタンス
    hdmi u_hdmi(.*);

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
        #(`STEP_X1/2) clk_pix_x5 = ~clk_pix_x5;
    end

//Get u_hdmi parameters 
wire[31:0] h_max = u_hdmi.h_max;
wire[31:0] h_valid_max = h_max;
wire[31:0] h_sync_min = u_hdmi.h_sync_min;
wire[31:0] h_sync_max = u_hdmi.h_sync_max;
wire[31:0] h_valid_min = u_hdmi.h_valid_min;
wire[31:0] v_max = u_hdmi.v_max;
wire[31:0] v_valid_max = v_max;
wire[31:0] v_sync_min = u_hdmi.v_sync_min;
wire[31:0] v_sync_max = u_hdmi.v_sync_max;
wire[31:0] v_valid_min = u_hdmi.v_valid_min;

//Get u_hdmi internal signals. 
wire[11:0] h_cnt = u_hdmi.h_cnt;
wire[11:0] v_cnt = u_hdmi.v_cnt;
wire h_sync = u_hdmi.h_sync;
wire v_sync = u_hdmi.v_sync;
wire h_valid = u_hdmi.h_valid;
wire v_valid = u_hdmi.v_valid;

///////////////////////////////////////////////////////////////////
// Test Bench

//h_validとv_validが想定のタイミングでHighになっていることを確認する
always @(h_valid) begin
    if (h_valid == 1'b1) begin
        assert_compare_m(h_valid_min, h_cnt, "<=", "h_valid check", `__LINE__);
        assert_compare_m(h_cnt, h_valid_max, "<", "h_valid check", `__LINE__);
    end
    else begin
        //h_validがLowからHighになる前の条件をチェック
        if (h_cnt < h_valid_max)
            assert_compare_m(h_valid_min, h_cnt, ">", "h_valid check",`__LINE__);
        //h_validがHighからLowに戻った後の条件をチェック
        if (h_cnt > h_valid_min)
            assert_compare_m(h_cnt, h_valid_max, ">=", "h_valid check",`__LINE__);
    end
end
always @(v_valid) begin
    if (v_valid == 1'b1) begin
        assert_compare_m(v_valid_min, v_cnt, "<=", "v_valid check",`__LINE__);
        assert_compare_m(v_cnt, v_valid_max, "<", "v_valid check",`__LINE__);
    end
    else begin
        //v_validがLowからHighになる前の条件をチェック
        if (v_cnt < v_valid_max)
            assert_compare_m(v_valid_min, v_cnt,">", "v_valid check",`__LINE__);
        //v_validがHighからLowに戻った後の条件をチェック
        if (v_cnt > v_valid_min)
            assert_compare_m(v_cnt, v_valid_max, ">=", "v_valid check",`__LINE__);    
    end
end

//接続チェック
assign hv = h_valid && v_valid;
always @(h_valid or v_valid) begin
    #1;
    if (hv)
        assert_compare_m(hv, u_hdmi.u_rgb2dvi.vid_pVDE, "==", "connection check", `__LINE__);
end
always @(h_sync) begin
        assert_compare_m(h_valid, u_hdmi.u_rgb2dvi.vid_pHSync, "==", "connection check", `__LINE__);
end
always @(v_sync) begin
        assert_compare_m(v_valid, u_hdmi.u_rgb2dvi.vid_pVSync, "==", "connection check", `__LINE__);
end

//h_syncとv_syncが想定のタイミングでHighになっていることを確認する
always @(h_sync) begin
    if (h_sync == 1'b1) begin
        assert_compare_m(h_sync_min, h_cnt, "<=", "h_sync check", `__LINE__);
        assert_compare_m(h_cnt, h_sync_max, "<", "h_sync check", `__LINE__);
    end
    else begin
        //h_syncがLowからHighになる前の条件をチェック
        if (h_cnt < h_sync_max)
            assert_compare_m(h_sync_min, h_cnt, ">", "h_sync check",`__LINE__);
        //h_syncがHighからLowに戻った後の条件をチェック
        if (h_cnt > h_sync_min)
            assert_compare_m(h_cnt, h_sync_max, ">=", "h_sync check",`__LINE__);
    end
end
always @(v_sync) begin
    if (v_sync == 1'b1) begin
        assert_compare_m(v_sync_min, v_cnt, "<=", "v_sync check",`__LINE__);
        assert_compare_m(v_cnt, v_sync_max, "<", "v_sync check",`__LINE__);
    end
    else begin
        //v_syncがLowからHighになる前の条件をチェック
        if (v_cnt < v_sync_max)
            assert_compare_m(v_sync_min, v_cnt, ">", "v_sync check",`__LINE__);
        //v_syncがHighからLowに戻った後の条件をチェック
        if (v_cnt > v_sync_min)
            assert_compare_m(v_cnt, v_sync_max, ">=", "v_sync check",`__LINE__);    
    end
end

//h_posとv_posが指定範囲で推移していることを確認する
always @(h_pos) begin
    assert_compare_m(h_pos, 0, ">=", "h_pos check",`__LINE__);
    assert_compare_m(h_pos, h_valid_max - h_valid_min + 1'b1, "<", "h_pos check",`__LINE__);
end
always @(v_pos) begin
    assert_compare_m(v_pos, 0, ">=", "v_pos check",`__LINE__);
    assert_compare_m(v_pos, v_valid_max - v_valid_min, "<", "v_pos check",`__LINE__);
end

initial begin
    $dumpfile("hdmi_tb.vcd");
    $dumpvars(0, hdmi_tb);
    rst_n = 1'b0;
    @(posedge clk_pix) #1
    rst_n = 1'b1;
    
    //////////////////////////////////////////////////////////
    //u_hdmi.u_rgb2dviに信号がつながっていることを確認
    force u_hdmi.u_rgb2dvi.TMDS_Clk_p = 1;#1;
    assert_compare_m(1, hdmi_clk_p, "==", "connection chk", `__LINE__);
    force u_hdmi.u_rgb2dvi.TMDS_Clk_p = 0;#1;
    assert_compare_m(0, hdmi_clk_p, "==", "connection chk", `__LINE__);

    force u_hdmi.u_rgb2dvi.TMDS_Clk_n = 1;#1;
    assert_compare_m(1, hdmi_clk_n, "==", "connection chk", `__LINE__);
    force u_hdmi.u_rgb2dvi.TMDS_Clk_n = 0;#1;
    assert_compare_m(0, hdmi_clk_n, "==", "connection chk", `__LINE__);

    force u_hdmi.u_rgb2dvi.TMDS_Data_p = 7;#1;
    assert_compare_m(7, hdmi_data_p, "==", "connection chk", `__LINE__);
    force u_hdmi.u_rgb2dvi.TMDS_Data_p = 0;#1;
    assert_compare_m(0, hdmi_data_p, "==", "connection chk", `__LINE__);

    force u_hdmi.u_rgb2dvi.TMDS_Data_n = 7;#1;
    assert_compare_m(7, hdmi_data_n, "==", "connection chk", `__LINE__);
    force u_hdmi.u_rgb2dvi.TMDS_Data_n = 0;#1;
    assert_compare_m(0, hdmi_data_n, "==", "connection chk", `__LINE__);

    //clk_pix接続チェック
    @(posedge clk_pix) #1
    assert_compare_m(clk_pix, u_hdmi.u_rgb2dvi.PixelClk, "==", "connection chk", `__LINE__);
    @(negedge clk_pix) #1
    assert_compare_m(clk_pix, u_hdmi.u_rgb2dvi.PixelClk, "==", "connection chk", `__LINE__);
    //clk_pix_x5接続チェック
    @(posedge clk_pix_x5) #1
    assert_compare_m(clk_pix_x5, u_hdmi.u_rgb2dvi.SerialClk, "==", "connection chk", `__LINE__);
    @(negedge clk_pix_x5) #1
    assert_compare_m(clk_pix_x5, u_hdmi.u_rgb2dvi.SerialClk, "==", "connection chk", `__LINE__);
    
    @(posedge clk_pix) #1
    
    //data接続チェック。1フレーム描写
    repeat (h_max*v_max) begin
        data = h_pos + v_pos*(h_valid_max - h_valid_min);#1;
        assert_compare_m(data, u_hdmi.u_rgb2dvi.vid_pData, "==", "connection chk", `__LINE__);
        @(posedge clk_pix) #1;

    end

    $display("All tests pass!!");
    $finish;
end

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
