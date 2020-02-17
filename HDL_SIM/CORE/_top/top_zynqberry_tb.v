/*
 * *****************************************************************
 * File: top_zynqberry_tb.v
 * Category: _top
 * File Created: 2020/01/06 21:23
 * Author: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
 * *****
 * Last Modified: 2020/02/11 07:29
 * Modified By: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
 * *****
 * Copyright 2018 - 2020  Project RockWave
 * *****************************************************************
 * Description:
 *   
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2020/01/06	kidtak51	First Version
 * *****************************************************************
 */

`timescale 1ns/1ns

`define test
module top_zynqberry_tb();

reg clk_from_gpio_cn;
wire [11:0] pc = u_top_zynqberry.u_top_core.u_top_fetch.program_counter;

top_zynqberry u_top_zynqberry(.*);

    wire [14:0] DDR_addr = 0;
    wire [2:0] DDR_ba         = 0;//DDR
    wire DDR_cas_n            = 0;//DDR
    wire DDR_ck_n             = 0;//DDR
    wire DDR_ck_p             = 0;//DDR
    wire DDR_cke              = 0;//DDR
    wire DDR_cs_n             = 0;//DDR
    wire [1:0] DDR_dm         = 0;//DDR
    wire [15:0] DDR_dq        = 0;//DDR
    wire [1:0] DDR_dqs_n      = 0;//DDR
    wire [1:0] DDR_dqs_p      = 0;//DDR
    wire DDR_odt              = 0;//DDR
    wire DDR_ras_n            = 0;//DDR
    wire DDR_reset_n          = 0;//DDR
    wire DDR_we_n             = 0;//DDR
    wire FIXED_IO_ddr_vrn     = 0;//FIXED_IO
    wire FIXED_IO_ddr_vrp     = 0;//FIXED_IO
    wire [31:0] FIXED_IO_mio  = 0;//FIXED_IO
    wire FIXED_IO_ps_clk      = 0;//FIXED_IO
    wire FIXED_IO_ps_porb     = 0;//FIXED_IO
    wire FIXED_IO_ps_srstb    = 0;//FIXED_IO
    wire [23:0] GPIO_1_tri_io = 0;//FIXED_IO
    wire Vp_Vn_v_n     = 0;//?
    wire Vp_Vn_v_p     = 0;//?
    wire csi_c_clk_n   = 0;//CSI
    wire csi_c_clk_p   = 0;//CSI
    wire csi_d_lp_n    = 0;//CSI
    wire csi_d_lp_p    = 0;//CSI
    wire [1:0] csi_d_n = 0;//CSI
    wire [1:0] csi_d_p = 0;//CSI

    wire PWM_L           ;//FIXED_IO
    wire PWM_R           ;//DFIXED_IO
    wire hdmi_clk_n      ;//HDMI
    wire hdmi_clk_p      ;//HDMI
    wire[2:0] hdmi_data_n;//HDMI
    wire[2:0] hdmi_data_p;//HDMI
    wire led             ;//LED (GPIO出力 外付けLED）
    wire gpio21_pin40_push_sw;//low-level if press
    wire gpio18_pin12_push_sw;//low-level if press
    wire gpio15_pin10_push_sw;//low-level if press
    wire gpio14_pin8_push_sw;//low-level if press


//clock
initial
    clk_from_gpio_cn = 0;
always begin
    #4 clk_from_gpio_cn = ~clk_from_gpio_cn;
end
wire aaa = 'hfe010113 == u_top_zynqberry.inst_data;
reg[31:0] gpi;
assign u_top_zynqberry.U_top_gpio.gpio_pin_in = gpi;
wire[7:0] gpo;
assign gpo = u_top_zynqberry.U_top_gpio.gpio_pin_out;

always@(posedge clk_from_gpio_cn)begin
    if(gpo == gpi) begin
        gpi = gpi + 1;
    end
end

initial begin
    //initial
    $dumpfile("top_zynqberry_tb.vcd");
    $dumpvars(0,top_zynqberry_tb);

    // init input
    
    gpi = 1;
    ////Core simulation start
    #500;
    //gpio_pin_in = 13'h0200;

    #500000;
    $finish;
end

endmodule
