/*
 * *****************************************************************
 * File: top_fetch.v
 * Category: Fetch
 * File Created: 2018/12/17 04:52
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2023/10/28 13:23
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2018  Project RockWave
 * *****************************************************************
 * Description:
 *   FETCHフェースのTOP階層
 *      ・Program Counter
 *      ・Inst Memory Control
 *      ・後段へのラッチ
 *           Xilinxへ実装する際は InstMemory(ROM)をクロック同期メモリ
 *           とするため、InstCodeはラッチを通さない
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2023/10/18	Masaru Aoki	Jump時のProgramCounterのセレクトを
 *                          WriteBackステートで行う
 * 2018/12/17	Masaru Aoki	First Version
 * *****************************************************************
 */


module top_fetch(
    input clk,                       // Global Clock
    input rst_n,                     // Global Reset

    // From StateMachine
    input phase_fetch,               // Fetch Phase
    input phase_writeback,           // WriteBack Phase
    // From WriteBack
    input [XLEN-1:0] next_pc_wf,     // 次のアドレス
    // From InstMemory
    input [XLEN-1:0] inst_data,      // InstMemory Data

    // For InstMemory
    output [AWIDTH-1:0] inst_addr,   // InstMemory Address
    // For Decode
    output [XLEN-1:0] curr_pc_fd,    // Current PC Address for Decode
    output [XLEN-1:0] inst,          // Instruction
    // For StateMachine
    output stall_fetch               // Stall Fetch Phase
);

    `include "core_general.vh"
   
    reg [XLEN-1:0] program_counter; // Program Counter
    reg [XLEN-1:0] latch_fetch;     // Latch for Next Stage
    
    wire [XLEN-1:0] curr_pc;        //      PC Address

    /////////////////////////////////////////////
    // Program Counter
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            program_counter <= RESET_VECTOR;
        else if(phase_writeback)
            program_counter <= next_pc_wf;
        else
            program_counter <= program_counter;
    end

    assign curr_pc = program_counter;
    // InstMemory用アドレス / InstMemoryは1Word=4Byteなため下位2bitを捨てる
    assign inst_addr = program_counter[AWIDTH+1:2];
    // Decode用inst
    //   XilinxのBlockRAMが同期RAMで1clk遅延するためラッチを通さない
    assign inst = inst_data;

    // 現状ではFetchPhaseはストールの必要なし
    //   InstMemoryが1clkでデータの準備ができなくなったら使用する
    assign stall_fetch = 1'b0; 

    /////////////////////////////////////////////
    // 次ステージのためのラッチ
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            latch_fetch <= {(XLEN){1'b0}};
        else if(phase_fetch)
            latch_fetch <= curr_pc;
        else
            latch_fetch <= latch_fetch;
    end

    assign curr_pc_fd = latch_fetch;

endmodule


