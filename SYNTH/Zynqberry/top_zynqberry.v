/*
 * *****************************************************************
 * File: top_zynqberry.v
 * Category: Zynqberry
 * File Created: 2019/10/07 21:53
 * Author: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
 * *****
 * Last Modified: 2020/02/20 23:31
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
    output reg led,//LED (GPIO出力 外付けLED）
    input clk_from_gpio_cn,//clock(GPIO入力 外付け水晶による16MHz)
    input gpio21_pin40_push_sw,//low-level if press
    input gpio18_pin12_push_sw,//low-level if press
    input gpio15_pin10_push_sw,//low-level if press
    input gpio14_pin8_push_sw//low-level if press

);

`include "core_general.vh"

`ifdef __ICARUS__
initial begin
    //$readmemh(`INST_ROM_FILE_NAME, u_inst_memory.mem);
    $readmemh("../../../fw/synth.hex", u_inst_memory.U_ram.ram);
end
`endif


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

//clocking
`ifdef __ICARUS__
    assign clk_pix = clk_from_gpio_cn;
    assign clk_pix_x5 = clk_from_gpio_cn;
    assign clk = clk_from_gpio_cn;
`else
    clk_wiz_0 u_clk_wiz_0(
        .clk_out1(clk_pix),       //hdmi pix_clk
        .clk_out2(clk_pix_x5),    //hdmi pix_clk_x5
        .reset(1'b0),             //とりあえず非リセット状態で固定
        .locked(locked),          //未使用
        .clk_in1(clk_from_gpio_cn)//16MHz
    );
    assign clk = clk_pix;
`endif


//instruction memory
wire [AWIDTH-1:0] inst_addr;
wire [XLEN-1:0] inst_data;

//data memory
wire [XLEN-1:0] data_mem_out;
wire [XLEN-1:0] data_mem_addr;
wire [XLEN-1:0] data_mem_wdata;
wire [2:0] data_mem_we;

top_core u_top_core(
	.clk            (clk            ),
    .rst_n          (rst_n          ),
    .inst_addr      (inst_addr      ),
    .inst_data      (inst_data      ),
    .data_mem_out   (data_mem_out   ),
    .data_mem_addr  (data_mem_addr  ),
    .data_mem_wdata (data_mem_wdata ),
    .data_mem_we    (data_mem_we    )
);
wire[XLEN-1:0] addr = data_mem_addr;
wire[XLEN-1:0] qin = data_mem_wdata;
wire[2:0] we = data_mem_we;
// Local BUS としてのReadData出力
assign data_mem_out = ram_qout_sel | gpio_qout_sel | hdmi_qout_sel | freerun_cnt_qout_sel;

rom u_inst_memory
(
    .clk(clk),
    .rst_n(rst_n),
    .addr(inst_addr),
    .qout(inst_data)
);

////////////////////////////////////////////////////////////////
// RAM領域
//    Xilinx Block RAMは常時選択なためsel信号を追加
wire ram_sel = ((addr & BASE_MASK) == RAM_BASE);
wire [2:0] ram_we = ram_sel ? we : 3'b000;

wire [XLEN-1:0] ram_qout_sel;              // Selected RAM Read data out (領域選択されていないと0出力)
wire [XLEN-1:0] ram_qout;                  // 常時RAM read data
assign ram_qout_sel = ram_sel ? ram_qout : {XLEN{1'b0}};
ram U_data_memory(
    .clk    (clk),
    .rst_n  (rst_n),
    .addr   (addr[AWIDTH-1:0]),
    .qin    (qin),
    .we     (ram_we),
    .qout   (ram_qout)
);

////////////////////////////////////////////////////////////////
// GPIO領域
parameter INNUM = 13;      // 入力端子 本数
parameter OUTNUM = 8;      // 出力端子 本数
wire [OUTNUM-1:0] gpio_pin_out;
wire [INNUM-1:0] gpio_pin_in;
wire  gpio_sel  = ((addr & BASE_MASK) == GPIO_BASE);
wire [XLEN-1:0] gpio_qout_sel;             // Selected GPIO Read data out
top_gpio #(
    .INNUM(INNUM),
    .OUTNUM(OUTNUM)
)
U_top_gpio(
    .clk            (clk),
    .rst_n          (rst_n),
    .sel            (gpio_sel),
    .addr           (addr[AWIDTH-1:0]),
    .wdata          (qin),
    .we             (we),
    .rdata          (gpio_qout_sel),
    .gpio_pin_in    (gpio_pin_in),
    .gpio_pin_out   (gpio_pin_out)
);
wire gpio_in[3:0];

assign gpio_in[3] = ~gpio21_pin40_push_sw;//left
assign gpio_in[2] = ~gpio15_pin10_push_sw;//down
assign gpio_in[1] = ~gpio18_pin12_push_sw;//right
assign gpio_in[0] = ~gpio14_pin8_push_sw;//a

assign gpio_pin_in[INNUM-1:4] = 'd0;
assign gpio_pin_in[3] = gpio_in[3];
assign gpio_pin_in[2] = gpio_in[2];
assign gpio_pin_in[1] = gpio_in[1];
assign gpio_pin_in[0] = gpio_in[0];

////////////////////////////////////////////////////////////////
// hdmi出力
wire hdmi_sel = ((addr & BASE_MASK) == HDMI_BASE);
wire [2:0] hdmi_we = hdmi_sel ? we : 3'b000;

wire [XLEN-1:0] hdmi_qout_sel;              // Selected VRAM Read data out
wire [XLEN-1:0] hdmi_qout;                  // 常時 VRAM Read data out
assign hdmi_qout_sel = hdmi_sel ? hdmi_qout : {XLEN{1'b0}};
top_hdmicontroller u_top_hdmicontroller(
    .clk(clk_pix),                            //汎用ロジッククロック
    .clk_pix(clk_pix),                        //画像クロック 720pでは74.25MHz
    .clk_pix_x5(clk_pix_x5),                  //5逓倍した画像クロック
    .rst_n(rst_n),                            //リセット 負論理
    .hdmi_clk_n(hdmi_clk_n),                  //hdmiクロック, IOに接続
    .hdmi_clk_p(hdmi_clk_p),                  //hdmiクロック, IOに接続
    .hdmi_data_n(hdmi_data_n),                //hdmiデータ(rgbの3bit), IOに接続
    .hdmi_data_p(hdmi_data_p),                //hdmiデータ(rgbの3bit), IOに接続
    .sel(hdmi_sel),                           // Select this Memory Block
    .addr(addr),                              // Address
    .we(hdmi_we),                                  // Write Enable
    .qin(qin),                                // Write Data
    .qout(hdmi_qout)                          // Read Data
);

////////////////////////////////////////////////////////////////
// Freerun counter領域
wire freerun_cnt_sel = ((addr & BASE_MASK) == FREERUNCNT_BASE);
wire [XLEN-1:0] freerun_cnt_qout_sel;             // Selected GPIO Read data out
freerun_counter U_freerun_counter(
    .clk            (clk),
    .rst_n          (rst_n),
    .sel            (freerun_cnt_sel),
    .addr           (addr[AWIDTH-1:0]),
    .rdata          (freerun_cnt_qout_sel)
);




always @(*) begin
    if(gpio_pin_out[0])begin
        led = 1'b0;
    end
    else if(gpio_pin_out[1])begin
        led = 1'b1;
    end
    else if(gpio_pin_out[2])begin
        led = 1'b0;
    end
    else if(gpio_pin_out[3])begin
        led = 1'b1;
    end
    else begin
        led = led_brink;
    end
end

//テスト用、Lチカ
wire led_brink;
led_test u_led_test(
      .clk(clk_pix),
	  .rst_n(rst_n),
      .led_out(led_brink)
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

//for simulation
wire [XLEN-1:0] pc = u_top_core.u_top_fetch.program_counter;
wire [XLEN-1:0] x01_ra = u_top_core.u_register_file.x1out;
wire [XLEN-1:0] x02_sp = u_top_core.u_register_file.x2out;
wire [XLEN-1:0] x03_gp = u_top_core.u_register_file.x3out;
wire [XLEN-1:0] x04_tp = u_top_core.u_register_file.x4out;
wire [XLEN-1:0] x05_t0 = u_top_core.u_register_file.x5out;
wire [XLEN-1:0] x06_t1 = u_top_core.u_register_file.x6out;
wire [XLEN-1:0] x07_t2 = u_top_core.u_register_file.x7out;
wire [XLEN-1:0] x08_s0_fp = u_top_core.u_register_file.x8out;
wire [XLEN-1:0] x09_s1 = u_top_core.u_register_file.x9out;
wire [XLEN-1:0] x10_a0 = u_top_core.u_register_file.x10out;
wire [XLEN-1:0] x11_a1 = u_top_core.u_register_file.x11out;
wire [XLEN-1:0] x12_a2 = u_top_core.u_register_file.x12out;
wire [XLEN-1:0] x13_a3 = u_top_core.u_register_file.x13out;
wire [XLEN-1:0] x14_a4 = u_top_core.u_register_file.x14out;
wire [XLEN-1:0] x15_a5 = u_top_core.u_register_file.x15out;
wire [XLEN-1:0] x16_a6 = u_top_core.u_register_file.x16out;
wire [XLEN-1:0] x17_a7 = u_top_core.u_register_file.x17out;
wire [XLEN-1:0] x18_s2 = u_top_core.u_register_file.x18out;
wire [XLEN-1:0] x19_s3 = u_top_core.u_register_file.x19out;
wire [XLEN-1:0] x20_s4 = u_top_core.u_register_file.x20out;
wire [XLEN-1:0] x21_s5 = u_top_core.u_register_file.x21out;
wire [XLEN-1:0] x22_s6 = u_top_core.u_register_file.x22out;
wire [XLEN-1:0] x23_s7 = u_top_core.u_register_file.x23out;
wire [XLEN-1:0] x24_s8 = u_top_core.u_register_file.x24out;
wire [XLEN-1:0] x25_s9 = u_top_core.u_register_file.x25out;
wire [XLEN-1:0] x26_s10 = u_top_core.u_register_file.x26out;
wire [XLEN-1:0] x27_s11 = u_top_core.u_register_file.x27out;
wire [XLEN-1:0] x28_t3 = u_top_core.u_register_file.x28out;
wire [XLEN-1:0] x29_t4 = u_top_core.u_register_file.x29out;
wire [XLEN-1:0] x30_t5 = u_top_core.u_register_file.x30out;
wire [XLEN-1:0] x31_t6 = u_top_core.u_register_file.x31out;

`ifdef __ICARUS__
`else
vio_0 u_core_vio (
  .clk(clk),                // input wire clk
  .probe_in0 (pc     ),    // input wire [31 : 0] probe_in0
  .probe_in1 (x01_ra ),    // input wire [31 : 0] probe_in1
  .probe_in2 (x02_sp ),    // input wire [31 : 0] probe_in2
  .probe_in3 (x03_gp ),    // input wire [31 : 0] probe_in3
  .probe_in4 (x04_tp ),    // input wire [31 : 0] probe_in4
  .probe_in5 (x05_t0 ),    // input wire [31 : 0] probe_in5
  .probe_in6 (x06_t1 ),    // input wire [31 : 0] probe_in6
  .probe_in7 (x07_t2 ),    // input wire [31 : 0] probe_in7
  .probe_in8 (x08_s0_fp),    // input wire [31 : 0] probe_in8
  .probe_in9 (x09_s1 ),    // input wire [31 : 0] probe_in9
  .probe_in10(x10_a0 ),  // input wire [31 : 0] probe_in10
  .probe_in11(x11_a1 ),  // input wire [31 : 0] probe_in11
  .probe_in12(x12_a2 ),  // input wire [31 : 0] probe_in12
  .probe_in13(x13_a3 ),  // input wire [31 : 0] probe_in13
  .probe_in14(x14_a4 ),  // input wire [31 : 0] probe_in14
  .probe_in15(x15_a5 ),  // input wire [31 : 0] probe_in15
  .probe_in16(x16_a6 ),  // input wire [31 : 0] probe_in16
  .probe_in17(x17_a7 ),  // input wire [31 : 0] probe_in17
  .probe_in18(x18_s2 ),  // input wire [31 : 0] probe_in18
  .probe_in19(x19_s3 ),  // input wire [31 : 0] probe_in19
  .probe_in20(x20_s4 ),  // input wire [31 : 0] probe_in20
  .probe_in21(x21_s5 ),  // input wire [31 : 0] probe_in21
  .probe_in22(x22_s6 ),  // input wire [31 : 0] probe_in22
  .probe_in23(x23_s7 ),  // input wire [31 : 0] probe_in23
  .probe_in24(x24_s8 ),  // input wire [31 : 0] probe_in24
  .probe_in25(x25_s9 ),  // input wire [31 : 0] probe_in25
  .probe_in26(x26_s10),  // input wire [31 : 0] probe_in26
  .probe_in27(x27_s11),  // input wire [31 : 0] probe_in27
  .probe_in28(x28_t3 ),  // input wire [31 : 0] probe_in28
  .probe_in29(x29_t4 ),  // input wire [31 : 0] probe_in29
  .probe_in30(U_top_gpio.U_reg_gpio.addr ),  // input wire [31 : 0] probe_in30
  .probe_in31(U_top_gpio.U_reg_gpio.sel ),  // input wire [31 : 0] probe_in31
  .probe_in32(gpio_pin_in),
  .probe_in33(gpio_pin_out),
  .probe_in34(U_top_gpio.U_reg_gpio.reg10),
  .probe_in35(U_top_gpio.U_reg_gpio.adsel10)
);
`endif

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
