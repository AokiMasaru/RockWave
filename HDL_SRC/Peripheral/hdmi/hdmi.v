
 /*
 * *****************************************************************
 * File: hdmi.v
 * Category: 
 * File Created: 2019/10/07 21:53
 * Author: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
 * *****
 * Last Modified: 2019/10/08 21:25
 * Modified By: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:
 *   Digilentのrgb2dviを外部から制御するためのモジュール
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/10/07	kidtak51	First Version
 * *****************************************************************
 */
module hdmi#(
    //default value is 720p 
    parameter h_max = 'd1650,//
    parameter h_sync_min = 'd110,
    parameter h_sync_max = 'd40 + h_sync_min,
    parameter h_valid_min = 'd370,
    parameter v_max = 'd750,
    parameter v_sync_min = 'd5,
    parameter v_sync_max = 'd5 + v_sync_min,
    parameter v_valid_min = 'd30
)
(
    input clk_pix,//画像クロック 720pでは74.25MHz
    input clk_pix_x5,//5逓倍した画像クロック
    input rst_n,//リセット 負論理
    output reg[11:0] h_pos,//水平画像位置
    output reg[11:0] v_pos,//垂直画像位置
    input[23:0] data,//画像データ RGB各々8bit, h_posとv_posに合わせて入力する。
    output hdmi_clk_n,//hdmiクロック, IOに接続
    output hdmi_clk_p,//hdmiクロック, IOに接続
    output[2:0] hdmi_data_n,//hdmiデータ(rgbの3bit), IOに接続
    output[2:0] hdmi_data_p//hdmiデータ(rgbの3bit), IOに接続
    );

localparam h_valid_max = h_max;
localparam v_valid_max = v_max;

reg[31:0] h_cnt = 0;
reg[31:0] v_cnt = 0;
reg h_sync;
reg v_sync;
reg h_valid;
reg v_valid;
wire clk = clk_pix;


//水平走査と垂直走査用のカウンタ（画像領域外も含む）
always @(posedge clk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
        h_cnt <= 12'd0;
        v_cnt <= 12'd0;
    end
    else if (h_cnt < h_max) begin
        h_cnt <= h_cnt + 12'd1;
    end
    else begin
        h_cnt <= 12'd0;
        if (v_cnt < v_max) begin
            v_cnt <= v_cnt + 12'd1;
        end
        else begin
            v_cnt <= 12'd0;
        end
    end
end

//水平同期信号生成
always @(posedge clk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
        h_sync <= 1'b0;
    end
    else if (h_sync_min <= h_cnt && h_cnt < h_sync_max) begin
        h_sync <= 1'b1;
    end
    else begin
        h_sync <= 1'b0;
    end
end
//水平画像有効区間生成＆画像座標生成
always @(posedge clk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
        h_valid <= 1'b0;
        h_pos <= 12'd0;
    end
    else if(h_valid_min <= h_cnt && h_cnt < h_valid_max) begin
        h_valid <= 1'b1;
        h_pos <= h_cnt - h_valid_min + 1'b1;
    end
    else begin
        h_valid <= 1'b0;
        h_pos <= 12'd0;
    end
end
//水平同期信号生成
always @(posedge clk) begin
    if (rst_n == 1'b0) begin
        v_sync <= 1'b0;
    end
    else if(v_sync_min <= v_cnt && v_cnt < v_sync_max) begin
        v_sync <= 1'b1;
    end
    else begin
        v_sync <= 1'b0;
    end
end
//垂直画像有効区間生成＆画像座標生成
always @(posedge clk) begin
    if (rst_n == 1'b0) begin
        v_valid <= 1'b0;
        v_pos <= 12'd0;
    end
    else if(v_valid_min <= v_cnt && v_cnt < v_valid_max) begin
        v_valid <= 1'b1;
        v_pos <= v_cnt - v_valid_min;
    end
    else begin
        v_valid <= 1'b0;
        v_pos <= 12'd0;
    end
end

//digiのモジュールインスタンス
//ただし、digiのモジュールは自分で作ったところではないためテストベンチでは評価しない
`ifndef HDMI
`else
rgb2dvi u_rgb2dvi(
    .TMDS_Clk_p(hdmi_clk_p),
    .TMDS_Clk_n(hdmi_clk_n),
    .TMDS_Data_p(hdmi_data_p),
    .TMDS_Data_n(hdmi_data_n),
    .aRst(1'b0),
    .aRst_n(1'b1),
    .vid_pData(data),
    .vid_pVDE(h_valid && v_valid),
    .vid_pHSync(h_sync),
    .vid_pVSync(v_sync),
    .PixelClk(clk_pix),
    .SerialClk(clk_pix_x5)
);
`endif
endmodule
