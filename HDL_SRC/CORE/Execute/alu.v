/*
 * *****************************************************************
 * File: alu.v
 * Category: alu
 * File Created: 2018/12/19 23:48
 * Author: Takuya Shono ( ta.shono+1@gmail.com )
 * *****
 * Last Modified: 2023/10/11 05:00
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2018  Project RockWave
 * *****************************************************************
 * Description:
 *   
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2018/12/19	Takuya Shono	First Version
 * *****************************************************************
 */

module alu (
    input  [XLEN-1:0] aluin1, //alu入力信号1
    input  [XLEN-1:0] aluin2, //alu入力信号2
    input  [3:0] funct_alu, //alu演算器選択信号
    output [XLEN-1:0] aluout //alu演算結果信号
    );
    
    `include "core_general.vh"

    function [XLEN-1:0] calc( 
        input [XLEN-1:0] aluin1,
        input [XLEN-1:0] aluin2,
        input [3:0] funct_alu
        );

        begin
            case( funct_alu )
                   4'b0_000             : calc =           aluin1   +         aluin2;       // ADD//ADDI 加算
                            4'b1_000    : calc =           aluin1   -         aluin2;       // SUB 減算
                   4'b0_001,4'b1_001    : calc =           aluin1  <<         aluin2[4:0];  // SLL//SLLI 左論理シフト
                   4'b0_010,4'b1_010    : calc = ( $signed(aluin1)  < $signed(aluin2))? 1:0;// SLT / SLTI 
                   4'b0_011,4'b1_011    : calc = (         aluin1   <         aluin2 )? 1:0;// SLTU / SLTIU
                   4'b0_100,4'b1_100    : calc =           aluin1   ^         aluin2;       // XOR 排他的論理和
                   4'b0_101             : calc =           aluin1  >>         aluin2 [4:0]; // SRL//SRLI 右論理シフト
                            4'b1_101    : calc =   $signed(aluin1) >>>        aluin2 [4:0]; // SRA//SRAI 右算術シフト
                   4'b0_110,4'b1_110    : calc =           aluin1   |         aluin2;       // OR 論理和                   
                   4'b0_111,4'b1_111    : calc =           aluin1   &         aluin2;       // AND 論理積
                   default : calc = {XLEN{1'bx}};
            endcase
        end
    endfunction

    assign aluout = calc( aluin1, aluin2, funct_alu);

endmodule // alu
