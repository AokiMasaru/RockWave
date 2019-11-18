/*
 * *****************************************************************
 * File: top_hdmicontroller.v
 * Category: hdmi
 * File Created: 2019/10/31 21:02
 * Author: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
 * *****
 * Last Modified: 2019/11/18 23:43
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
 * 2019/10/31	kidtak51	First Version
 * *****************************************************************
 */
module top_hdmicontroller(
    //io
    input clk,                      //汎用ロジッククロック
    input clk_pix,                  //画像クロック 720pでは74.25MHz
    input clk_pix_x5,               //5逓倍した画像クロック
    input rst_n,                    //リセット 負論理
    output hdmi_clk_n,              //hdmiクロック, IOに接続
    output hdmi_clk_p,              //hdmiクロック, IOに接続
    output[2:0] hdmi_data_n,        //hdmiデータ(rgbの3bit), IOに接続
    output[2:0] hdmi_data_p,        //hdmiデータ(rgbの3bit), IOに接続
    // Local BUS
    input               sel,        // Select this Memory Block
    input [XLEN-1:0]    addr,       // Address
    input [2:0]         we,         // Write Enable
    input [XLEN-1:0]    qin,        // Write Data
    output [XLEN-1:0]   qout        // Read Data
);

`include "core_general.vh"

wire vram_sel = sel & ((addr & 32'h00F0_0000) == 32'h0020_0000);
wire [XLEN-1:0] qout_reg;

wire [7:0] pix_data;

//hdmi制御
wire [11:0] h_pos;
wire [11:0] v_pos;
hdmi u_hdmi(
    .clk_pix(clk_pix),                    //画像クロック 720pでは74.25MHz
    .clk_pix_x5(clk_pix_x5),              //5逓倍した画像クロック
    .rst_n(rst_n),                        //リセット 負論理
    .h_pos(h_pos),                        //水平画像位置
    .v_pos(v_pos),                        //垂直画像位置
    .data({pix_data, pix_data, pix_data}),//画像データ RGB各々8bit, h_posとv_posに合わせて入力する。R=G=Bとしグレースケールで使用
    .hdmi_clk_n(hdmi_clk_n),              //hdmiクロック, IOに接続
    .hdmi_clk_p(hdmi_clk_p),              //hdmiクロック, IOに接続
    .hdmi_data_n(hdmi_data_n),            //hdmiデータ(rgbの3bit), IOに接続
    .hdmi_data_p(hdmi_data_p)             //hdmiデータ(rgbの3bit), IOに接続
);

// VRAM
// True Dual Port RAMで生成し、PORTB側をROMとして使用
wire [7:0] douta;
wire [XLEN-1:0] qout = {{(XLEN-7){1'b0}}, douta};

wire[31:0] h_max       = u_hdmi.h_max;
wire[31:0] h_valid_max = h_max;
wire[31:0] h_valid_min = u_hdmi.h_valid_min;


wire[19:0] addrb = (h_pos + v_pos*(h_valid_max - h_valid_min));
hdmi_vram u_hdmi_vram (
    .clka         (clk),
    .ena          (vram_sel),
    .wea          (we[2]&(~we[1])&(~we[0])),
    .addra        (addr[19:0]),
    .dina         (qin[7:0]),
    .douta        (douta),
    .clkb         (clk_pix),
    .enb          (1'b1),
    .addrb        (addrb),
    .doutb        (pix_data)
);
endmodule
