/*
 * *****************************************************************
 * File: core_general.vh
 * Category: CORE
 * File Created: 2018/12/18 04:23
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2023/11/13 05:03
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2018  Project RockWave
 * *****************************************************************
 * Description:
 *   全体で使用する定義
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/03/03	Masaru Aoki	メモリマップ用設定を作成
 * 2019/02/18 shonta      SLTIと分離するためdecoded_opにmust jumpを追加
 * 2019/01/24	Masaru Aoki	64bitの記述を追加
 * 2019/01/09	kidtak51	  各制御ブロックの出力段のFlipFlopを除去するための定義を追加した
 * 2019/1/4	  kidtak51	  parameter名一部修正
 * 2018/12/28	Masaru Aoki	FUNCT3 / DataMemWE / JumpEn 追加
 * 2018/12/18	Masaru Aoki	First Version
 * *****************************************************************
 */

//    `define RV64I

    // CPU Register Bit Size
  `ifdef RV64I
      localparam XLEN = 64;
  `else
      localparam XLEN = 32;
  `endif
    
    /////////////////////////////////////////////
    // Instruction Memory
    /////////////////////////////////////////////
    // InstMemory Data Width
    localparam DWIDTH = XLEN;
    // InstMemory Address Width
    localparam AWIDTH = 14;
    // InstMemory Words size
    localparam WORDS = (2**AWIDTH);
    // Reset Vector
    localparam RESET_VECTOR = 32'h8000_0000;

    /////////////////////////////////////////////
    // Memory Map
    /////////////////////////////////////////////]
    localparam BASE_MASK  = 32'hFF00_0000;
    localparam TIMER_BASE = 32'h0200_0000;
    localparam UART_BASE  = 32'h1000_0000;
    localparam VGA_BASE   = 32'h6000_0000;
    localparam GPIO_BASE  = 32'h7000_0000;
    localparam ROM_BASE   = 32'h8000_0000;
    localparam RAM_BASE   = 32'h9000_0000;
    localparam HDMI_BASE  = 32'hA000_0000;
    localparam FREERUNCNT_BASE = 32'hB000_0000;

    /////////////////////////////////////////////
    // Doecode
    /////////////////////////////////////////////
    localparam OPLEN = 26;

    // RS1/RS2
    localparam USE_ALU_IN1_BIT = 0;
      localparam USE_ALU_IN1_PC      = 0;
      localparam USE_ALU_IN1_RS1DATA = 1;
    localparam USE_ALU_IN2_BIT = 1;
      localparam USE_ALU_IN2_IMM     = 0;
      localparam USE_ALU_IN2_RS2DATA = 1;

    // RD
    localparam USE_RD_BIT_L = 2;
    localparam USE_RD_BIT_M = 4;
      localparam USE_RD_ALU    = 3'b000;
      localparam USE_RD_PC     = 3'b001;
      localparam USE_RD_MEMORY = 3'b010;
      localparam USE_RD_COMP   = 3'b011;
      localparam USE_RD_CSR    = 3'b100;
   
    // funct3
    localparam FUNCT3_BIT_L = 5;
    localparam FUNCT3_BIT_M = 7;
      // LOAD / STORE
      localparam FUNCT3_B = 3'b000;
      localparam FUNCT3_H = 3'b001;
      localparam FUNCT3_W = 3'b010;
      localparam FUNCT3_D = 3'b011;      // RV64
      localparam FUNCT3_BU = 3'b100;
      localparam FUNCT3_HU = 3'b101;
      localparam FUNCT3_WU = 3'b110;     // RV64
      // BRANCH
      localparam FUNCT3_BEQ  = 3'b000;
      localparam FUNCT3_BNE  = 3'b001;
      localparam FUNCT3_JUMP = 3'b010;  // Must Jump ただし、SLTIは除く 
      localparam FUNCT3_BLT  = 3'b100;
      localparam FUNCT3_BGE  = 3'b101;
      localparam FUNCT3_BLTU = 3'b110;
      localparam FUNCT3_BGEU = 3'b111;
      // OP
      localparam FUNCT3_SLT  = 3'b010;
      localparam FUNCT3_SLTU = 3'b011;

    // Data Memory Write Enable
    localparam DATA_MEM_WE_BIT = 8;

    // Jump Enable
    localparam JUMP_EN_BIT = 9;

    // must jump
    localparam MUST_JUMP_BIT = 10;

    // CSR addr
    localparam CSR_ADR_BIT_L = 11;
    localparam CSR_ADR_BIT_H = 22;
    localparam CSR_WE_BIT_L = 23;
    localparam CSR_WE_BIT_H = 24;
      localparam CSR_NONE = 2'b00;
      localparam CSR_CSRW = 2'b01;
      localparam CSR_CSRS = 2'b10;
      localparam CSR_CSRC = 2'b11;

    // op:MRET
    localparam OP_MRET_BIT = 25;


    /////////////////////////////////////////////
    // Common
    /////////////////////////////////////////////
    //以下をアンコメントすると、Decodeブロック, Executeブロック, Memoryブロックの出力段FFを除去する
    //`define OUT_FLIPFLOP_REMOVE

