/*
 * *****************************************************************
 * File: ram.v
 * Category: MemoryAccess
 * File Created: 2018/12/30 06:13
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2023/11/12 15:51
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2018  Project RockWave
 * *****************************************************************
 * Description:
 *   Data Memory
 *   XilinxではBlockRAMを推察させる
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2023/11/12	Masaru Aoki	Xilinxでは、CoreGeneratorで生成したBlockRAMを使用する
 * 2023/10/22	Masaru Aoki	32bitメモリに1Byte単位でアクセスする
 * 2019/02/22	Masaru Aoki	ByteWriteEnable付きのBlockRAMに変更
 * 2019/01/24	Masaru Aoki	RV64Iに対応
 * 2019/01/04	Masaru Aoki	Byte / HalfWord / Wordアクセスに対応
 * 2018/12/30	Masaru Aoki	First Version
 * *****************************************************************
 */


module ram(
    input clk,                  // Global Clock
    input rst_n,                // Global Reset
    input [AWIDTH-1:0] addr,    // Address
    input [DWIDTH-1:0] qin,     // Read  Data
    input [3:0] we,             // Memory Write Enable 1stから4thByteまでバイト毎のWriteEnable
    output [DWIDTH-1:0] qout    // Read  Data
);
    `include "core_general.vh"

    wire [3:0] weram;

`ifndef __ICARUS__
// Xilinx Vivadoでは、Core Generaterで生成したBlockRAMを読み込む
// 初期値 は、COEファイルで準備して CoreGeneraterで読み込むこと
    blk_mem_gen_1 U_ram (
        .clka(clk),                 // input wire clka
        .ena(1'b1),                 // input wire enaa
        .wea(we),                   // input wire [3 : 0] wea
        .addra(addr),               // input wire [11 : 0] addra
        .dina(qin),                 // input wire [31 : 0] dina
        .douta(qout)                // output wire [31 : 0] douta
    );
`else
    bytewrite_ram_1b U_ram(
        .clk(clk),
        .we(we),
        .addr(addr),
        .di(qin),
        .do(qout)
    );
`endif
endmodule

// Single-Port BRAM with Byte-wide Write Enable
//	Read-First mode
//	Single-process description
//	Compact description of the write with a generate-for 
//   statement
//	Column width and number of columns easily configurable
//
// bytewrite_ram_1b.v
//

module bytewrite_ram_1b (clk, we, addr, di, do);

`include "core_general.vh"

parameter SIZE = 2**AWIDTH; 
parameter ADDR_WIDTH = AWIDTH; 
parameter COL_WIDTH = 8; 
parameter NB_COL = 4;

input	clk;
input	[NB_COL-1:0]	we;
input	[ADDR_WIDTH-1:0]	addr;
input	[NB_COL*COL_WIDTH-1:0] di;
output reg [NB_COL*COL_WIDTH-1:0] do;

reg	[NB_COL*COL_WIDTH-1:0] RAM [SIZE-1:0];

always @(posedge clk)
begin
    do <= RAM[addr];
end

generate genvar i;
for (i = 0; i < NB_COL; i = i+1)
begin
always @(posedge clk)
begin
    if (we[i])
        RAM[addr][(i+1)*COL_WIDTH-1:i*COL_WIDTH] <= di[(i+1)*COL_WIDTH-1:i*COL_WIDTH];
    end 
end
endgenerate




endmodule
