/*
 * *****************************************************************
 * File: rgb2dvi_for_test.v
 * Category: hdmi
 * File Created: 2019/10/24 06:55
 * Author: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
 * *****
 * Last Modified: 2023/09/26 05:00
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:
 *   rgb2divはDigilentが作ったモジュールのためテストしない。
 *   テスト時にのみDigilentのモジュールの代替として使用するモジュール。
 *   インスタンスした上位モジュールとの接続をテストする用途を想定。
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/10/24	kidtak51	First Version
 * *****************************************************************
 */

module rgb2dvi
(
    output TMDS_Clk_p,//画像クロック 720pでは74.25MHz
    output TMDS_Clk_n,//5逓倍した画像クロック
    output[2:0] TMDS_Data_p,//リセット 負論理
    output[2:0] TMDS_Data_n,//水平画像位置
    input aRst,//垂直画像位置
    input aRst_n,//画像データ RGB各々8bit, h_posとv_posに合わせて入力する。
    input[23:0] vid_pData,//hdmiクロック, IOに接続
    input vid_pVDE,
    input vid_pHSync,//hdmiクロック, IOに接続
    input vid_pVSync,//hdmiデータ(rgbの3bit), IOに接続
    input PixelClk,
    input SerialClk
);

//
assign TMDS_Clk_p = 1'b0;
assign TMDS_Clk_n = 1'b0;
assign TMDS_Data_p = 3'b000;
assign TMDS_Data_n = 3'b000;

endmodule
