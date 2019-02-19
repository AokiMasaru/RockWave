/*
 * *****************************************************************
 * File: top_zedboard.v
 * Category: _top
 * File Created: 2019/02/17 06:38
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2019/02/19 04:40
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:
 *   TOP階層 for ZedBoard
 *      InstRomをXilinxのBRAMを使用する
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/02/17	Masaru Aoki	First Version
 * *****************************************************************
 */

 module top_zedboard(
     // system
     input      clk,        // Global Clock
     input      rst_n,      // Global Reset

     // GPIO
     output [7:0] led       // GPIO Output for LED
 );
    `include "core_general.vh"

    // instruction memory
    wire [AWIDTH-1:0]   inst_addr;
    wire [XLEN-1:0]     inst_data;

    // data memory
    wire [AWIDTH-1:0]   data_mem_addr;
    wire [XLEN-1:0]     data_mem_out;
    wire [XLEN-1:0]     data_mem_wdata;
    wire [2:0]          data_mem_we;

///////////////////////////////////////////////////////////////////////
// GPIOモジュールが実装されるまでの暫定
assign led = u_top_core.u_register_file.x10out[7:0];

///////////////////////////////////////////////////////////////////
// メモリロード
initial
    $readmemh("../../fw/night.hex",u_inst_memory.U_ram.ram,12'h000,12'hfff);

///////////////////////////////////////////////////////////////////////
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

rom u_inst_memory
(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .addr           (inst_addr      ),
    .qout           (inst_data      )
);

ram u_data_memory(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .addr           (data_mem_addr  ),
    .qin            (data_mem_wdata ),
    .we(data_mem_we),
    .qout(data_mem_out)
);

 endmodule
