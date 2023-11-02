/*
 * *****************************************************************
 * File: writeback.v
 * Category: Writeback
 * File Created: 2019/01/23 12:25
 * Author: Takuya Shono ( ta.shono+1@gmail.com )
 * *****
 * Last Modified: 2023/11/03 07:34
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:
 *   
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2023/10/28	Masaru Aoki	ProgramCounterの操作をWriteBackで行う
 *                          今後、割込処理をWriteBackに導入するため
 * 2019/01/23	Takuya Shono	First Version
 * *****************************************************************
 */

module writeback(

    // From StateMachine
    input phase_writeback,             // writeback Phase
     // From Memory
    input jump_state_mw,               // PCの次のアドレスがJumpアドレス
    input [OPLEN-1:0] decoded_op_mw,   // Decoded OPcode
    input [4:0] rdsel_mw,              // RD選択
    input [XLEN-1:0] curr_pc_mw,       // Current PC Address
    input [XLEN-1:0] alu_out_mw,       // ALU output
    input [XLEN-1:0] mem_out_mw,       // Data Memory output
    input [XLEN-1:0] csr_out_mw,       // CSR output
 
    //For RegisterFile
    output [XLEN-1:0] rddata_wr,       //出力データ 
    output [4:0] rdsel_wr,             //RD選択
    //For Fetch
    output [XLEN-1:0] next_pc_wf,       // 次のPC Address
    //For CSR
    output [XLEN-1:0] next_pc_wc,       // 次のPC Address
    input             int_cw,           // 割込発生
    input  [XLEN-1:0] mtvec,            // 割込ベクタ
    input  [XLEN-1:0] mepc,             // 割込前PC
   // For StateMachine
    output stall_writeback             // Stall writeback Phase  

);

    `include "core_general.vh"

    wire jump_en;       //jump許可
    wire [USE_RD_BIT_M-USE_RD_BIT_L:0] use_rd;  //データ出力選択
    wire [XLEN-1:0] jump_state_selin; //セレクタ入力用に[XLEN]bit拡張する

    wire [XLEN-1:0] next_pc;

    assign rdsel_wr = rdsel_mw; 

    // 
    assign next_pc = curr_pc_mw + 4;
    // For CSR 割込がない場合の次の実行アドレス
    assign next_pc_wc = select_pc(alu_out_mw, next_pc, jump_state_wf);
    assign next_pc_wf = int_cw ? mtvec : (decoded_op_mw[OP_MRET_BIT] ? mepc : next_pc_wc);
    function [XLEN-1:0] select_pc;
        input [XLEN-1:0] alu_out_mw;
        input [XLEN-1:0] next_pc;
        input  jump_state_wf;
            case( jump_state_wf )
                0 : select_pc = next_pc;            // 通常
                1 : select_pc = alu_out_mw;         // Jump
                default: select_pc =  {XLEN{1'bx}};
            endcase
    endfunction

    //selecter1
    assign jump_en = decoded_op_mw[JUMP_EN_BIT];
    assign jump_state_wf = (jump_en == 1'b1)?  jump_state_mw : 1'b0 ;
    
    //selecter2
    assign use_rd  = decoded_op_mw [USE_RD_BIT_M:USE_RD_BIT_L]; 
    assign jump_state_selin = {{XLEN-1{1'b0}},jump_state_mw}; 

    function [XLEN-1:0] select;
        input [XLEN-1:0] mem_out_mw;        //データ入力1    
        input [XLEN-1:0] jump_state_selin;  //データ入力2    
        input [XLEN-1:0] next_pc;           //データ入力3    
        input [XLEN-1:0] alu_out_mw;        //データ入力4
        input [XLEN-1:0] csr_out_mw;        //データ入力5
        input [USE_RD_BIT_M-USE_RD_BIT_L:0] use_rd;                 //セレクタ
            case( use_rd )
                USE_RD_ALU    : select = alu_out_mw;
                USE_RD_PC     : select = next_pc;
                USE_RD_MEMORY : select = mem_out_mw;
                USE_RD_CSR    : select = csr_out_mw;
                USE_RD_COMP   : select = jump_state_selin;
                default: select =  {XLEN{1'bx}};
            endcase
    endfunction

    assign rddata_wr = select( mem_out_mw, jump_state_selin, next_pc, alu_out_mw, csr_out_mw,use_rd);

    assign stall_writeback = 1'b0;
    assign regdata_for_pc = alu_out_mw;

endmodule //top_writeback
