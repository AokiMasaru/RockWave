/*
 * *****************************************************************
 * File: rom.v
 * Category: Fetch
 * File Created: 2018/12/16 07:11
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2019/02/19 04:40
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2018  Project RockWave
 * *****************************************************************
 * Description:
 *   Instruction ROM
 *   Xilinxでは、BlockRAMを推察させる
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/02/19	Masaru Aoki	BlockRAMを推察させてからROM化する
 * 2018/12/16	Masaru Aoki	First Version
 * *****************************************************************
 */

module rom(
    input clk,                  // Global Clock
    input rst_n,                // Global Reset
    input [AWIDTH-1:0] addr,    // Address
    output [DWIDTH-1:0] qout       // Read  Data
);
    `include "core_general.vh"

    v_rams_20c U_ram(
        .clk(clk),
        .we(1'b0),
        .addr(addr),
        .din(32'h00000000),
        .dout(qout)
    );
endmodule

module  v_rams_20c  (clk, we,  addr,  din,  dout);
    input  clk;
    input  we;
    input  [11:0]    addr;
    input  [31:0]    din;
    output  [31:0]    dout;
    reg  [31:0]  ram  [0:4095];
    reg  [31:0]  dout;
    
   
    always  @(posedge  clk) begin
        if  (we)
            ram[addr]  <=  din;
            
        dout  <=  ram[addr];
    end
endmodule
