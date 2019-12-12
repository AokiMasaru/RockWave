/*
 * *****************************************************************
 * File: top_zynqberry.v
 * Category: Zynqberry
 * File Created: 2019/10/07 21:53
 * Author: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
 * *****
 * Last Modified: 2019/12/13 24:01
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
 * 2019/12/12	kidtak51	hdmiにvramを実装
 * 2019/10/30   kidtak51	hdmi出力機能追加
 * 2019/10/07	kidtak51	First Version
 * *****************************************************************
 */

module top_zynqberry(
    inout [14:0] DDR_addr,//DDR
    inout [2:0] DDR_ba,//DDR
    inout DDR_cas_n,//DDR
    inout DDR_ck_n,//DDR
    inout DDR_ck_p,//DDR
    inout DDR_cke,//DDR
    inout DDR_cs_n,//DDR
    inout [1:0] DDR_dm,//DDR
    inout [15:0] DDR_dq,//DDR
    inout [1:0] DDR_dqs_n,//DDR
    inout [1:0] DDR_dqs_p,//DDR
    inout DDR_odt,//DDR
    inout DDR_ras_n,//DDR
    inout DDR_reset_n,//DDR
    inout DDR_we_n,//DDR
    inout FIXED_IO_ddr_vrn,//FIXED_IO
    inout FIXED_IO_ddr_vrp,//FIXED_IO
    inout [31:0] FIXED_IO_mio,//FIXED_IO
    inout FIXED_IO_ps_clk,//FIXED_IO
    inout FIXED_IO_ps_porb,//FIXED_IO
    inout FIXED_IO_ps_srstb,//FIXED_IO
    inout [23:0] GPIO_1_tri_io,//FIXED_IO
    output PWM_L,//FIXED_IO
    output PWM_R,//DFIXED_IO
    input Vp_Vn_v_n,//?
    input Vp_Vn_v_p,//?
    input csi_c_clk_n,//CSI
    input csi_c_clk_p,//CSI
    input csi_d_lp_n,//CSI
    input csi_d_lp_p,//CSI
    input [1:0] csi_d_n,//CSI
    input [1:0] csi_d_p,//CSI
    output hdmi_clk_n,//HDMI
    output hdmi_clk_p,//HDMI
    output[2:0] hdmi_data_n,//HDMI
    output[2:0] hdmi_data_p,//HDMI
    output led,//LED (GPIO出力 外付けLED）
    input clk_from_gpio_cn//clock(GPIO入力 外付け水晶による16MHz)
);

`include "core_general.vh"

wire clk_pix;//hdmi pix_clk
wire clk_pix_x5;
wire locked;

//instant reset wave generate
reg[7:0] cnt = 8'd0;
reg rst_n = 1'b0;
always @(posedge clk_pix) begin
	if ( cnt == 8'hFF ) begin
		cnt <= cnt;
		rst_n <= 1'b1;
	end
	else begin
		cnt <= cnt + 1'b1;
		rst_n <= 1'b0;
	end
end

clk_wiz_0 u_clk_wiz_0(
  .clk_out1(clk_pix),       //hdmi pix_clk
  .clk_out2(clk_pix_x5),    //hdmi pix_clk_x5
  .reset(1'b0),             //とりあえず非リセット状態で固定
  .locked(locked),          //未使用
  .clk_in1(clk_from_gpio_cn)//16MHz
 );


wire[11:0] h_pos;
wire[11:0] v_pos;
wire[7:0] data;

//hdmi出力
wire[31:0] addr;
wire[31:0] qout;
top_hdmicontroller u_top_hdmicontroller(
    .clk(clk_pix),                            //汎用ロジッククロック
    .clk_pix(clk_pix),                        //画像クロック 720pでは74.25MHz
    .clk_pix_x5(clk_pix_x5),                  //5逓倍した画像クロック
    .rst_n(rst_n),                            //リセット 負論理
    .hdmi_clk_n(hdmi_clk_n),                  //hdmiクロック, IOに接続
    .hdmi_clk_p(hdmi_clk_p),                  //hdmiクロック, IOに接続
    .hdmi_data_n(hdmi_data_n),                //hdmiデータ(rgbの3bit), IOに接続
    .hdmi_data_p(hdmi_data_p),                //hdmiデータ(rgbの3bit), IOに接続
    .sel((32'h0020_0000 + 57600 - 1) > addr), // Select this Memory Block
    .addr(addr),                              // Address
    .we(3'b100),                              // Write Enable
    .qin({{(XLEN-8){1'b0}}, data}),           // Write Data
    .qout(qout)                               // Read Data
);

//テスト用、CPUに代わってHDMIのVRAMにWriteするモジュール
hdmi_test u_hdmi_test(
    .clk(clk_pix),
    .addr(addr),
    .data(data)
);

//テスト用、Lチカ
led_test u_led_test(
      .clk(clk_pix),
	  .rst_n(rst_n),
      .led_out(led)
);


//未使用GPIOの状態設定
//外付けの回路とショートを避けるためにhigh-zに固定
assign GPIO_1_tri_io[0] = 1'bz;
assign GPIO_1_tri_io[1] = 1'bz;
assign GPIO_1_tri_io[2] = 1'bz;
assign GPIO_1_tri_io[3] = 1'bz;
assign GPIO_1_tri_io[4] = 1'bz;
assign GPIO_1_tri_io[5] = 1'bz;
assign GPIO_1_tri_io[6] = 1'bz;
assign GPIO_1_tri_io[7] = 1'bz;
assign GPIO_1_tri_io[8] = 1'bz;
assign GPIO_1_tri_io[9] = 1'bz;
assign GPIO_1_tri_io[10] = 1'bz;
assign GPIO_1_tri_io[11] = 1'bz;
assign GPIO_1_tri_io[12] = 1'bz;
assign GPIO_1_tri_io[13] = 1'bz;
assign GPIO_1_tri_io[14] = 1'bz;
assign GPIO_1_tri_io[15] = 1'bz;//
assign GPIO_1_tri_io[16] = 1'bz;
assign GPIO_1_tri_io[17] = 1'bz;
assign GPIO_1_tri_io[18] = 1'bz;
assign GPIO_1_tri_io[19] = 1'bz;
assign GPIO_1_tri_io[20] = 1'bz;
assign GPIO_1_tri_io[21] = 1'bz;
assign GPIO_1_tri_io[22] = 1'bz;
assign GPIO_1_tri_io[23] = 1'bz;//

endmodule

//テスト用LED点滅回路
module led_test(
	input clk,//クロック
	input rst_n,//リセット
	output reg led_out//LEDに接続
);
parameter brink_interval = 32'h01FFFFFF;
reg[31:0] led_counter;
always @(posedge clk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		led_counter <= 32'h00000000;
		led_out <= 1'b0;
	end
	else if (led_counter >= brink_interval) begin
		led_counter <= 32'h00000000;
		led_out <= ~led_out;
	end
	else begin
		led_counter <= led_counter + 1'b1;
	end
end
endmodule

//テスト用、CPUに代わってHDMIのVRAMにWriteするモジュール
//32'h0020_0000から1アドレスづつデータをデクリメントすることで
//水平軸方向に輝度を変化させるテストパターン
module hdmi_test(
	input clk,//画像クロック
	output reg[31:0] addr = 32'h0020_0000,//vramのアドレス
    output reg[7:0] data = 8'hFF           //画素位置に対応するグレースケールデータ(data = R=G=B)
);
reg[11:0] xPos = 12'd1;
reg[11:0] yPos = 12'd1;
always @(posedge clk) begin
    if(addr >= 32'h0020_0000 + 57600 - 1) begin
        addr <= addr;//32'h0020_0000;
        data <= 8'h7F;
    end
    else begin
        addr <= addr + 1'b1;
        data <= data - 1'b1;
    end
end
endmodule
