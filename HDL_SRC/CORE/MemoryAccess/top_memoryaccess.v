/*
 * *****************************************************************
 * File: top_memoryaccess.v
 * Category: MemoryAccess
 * File Created: 2019/01/02 05:45
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2023/10/25 05:18
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:
 *   MemoryAccess 階層
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2023/10/22	Masaru Aoki	32bitメモリに1Byte単位でアクセスする
 * 2023/09/27	Masaru Aoki	CSR機能追加
 * 2019/01/24	Masaru Aoki	RV64I対応
 * 2019/01/02	Masaru Aoki	First Version
 * *****************************************************************
 */
module top_memoryaccess(
    input clk,                       // Global Clock
    input rst_n,                     // Global Reset

    // From StateMachine
    input phase_memoryaccess,        // Fetch Phase
    // From DataMemory
    input [XLEN-1:0] data_mem_out,   // Output
    // From CSR
    input  [XLEN-1:0] csr_rdata,    // Read Data
    // From Execute
    input [OPLEN-1:0] decoded_op_em, // Decoded OPcode
    input jump_state_em,             // PCの次のアドレスがJumpアドレス
    input [4:0] rdsel_em,            // RD選択
    input [XLEN-1:0] curr_pc_em,     // 現在 PC Address from Execute
    input [XLEN-1:0] alu_out_em,     // ALU output
    input [XLEN-1:0] rs2data_em,     // RS2data
    // For DataMemory
    output [XLEN-1:0] data_mem_addr,// Address
    output [XLEN-1:0] data_mem_wdata,// Write Data
    output [3:0]      data_mem_we,  // Write Enable
    // For CSR
    output [11:0]     csr_addr,     // Address
    output [XLEN-1:0] csr_wdata,    // Write Data
    output [1:0]      csr_we,       // Write Enable

    // For WriteBack
    output [OPLEN-1:0] decoded_op_mw,// Decoded OPcode
    output jump_state_mw,            // PCの次のアドレスがJumpアドレス
    output [4:0] rdsel_mw,           // RD選択
    output [XLEN-1:0] curr_pc_mw,    // 元 PC Address for Decode
    output [XLEN-1:0] alu_out_mw,    // ALU output
    output [XLEN-1:0] mem_out_mw,    // Data Memory output
    output [XLEN-1:0] csr_out_mw,    // CSR output
    // For StateMachine
    output stall_memoryaccess        // Stall MemoryAccess Phase
);

    `include "core_general.vh"

    localparam LATCH_LEN = (XLEN*3+5+1+OPLEN);
    reg [LATCH_LEN-1:0] latch_memoryaccess; // Latch for Next Stage

    /////////////////////////////////////////////
    // Rename Decode Opcode 
    wire [2:0] funct3 = decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L];
    wire we = decoded_op_em[DATA_MEM_WE_BIT];

    /////////////////////////////////////////////
    // Memory Access STORE系
    //     データメモリのアクセスは1Byte単位
    //      4byteにアライメント　ミスアライメントの例外は後日実装
    assign data_mem_addr = { 2'b00 , alu_out_em[XLEN-1:2]};
    assign data_mem_wdata = mem_wdata;

    /////////////////////////////////////////////
    // Memory Access LOAD系
    assign mem_out_mw = func_mem_out(funct3,mem_out);

    // バイト・ハーフ・ワードアクセス
    function [XLEN-1:0] func_mem_out(
        input [2:0] funct3,
        input [XLEN-1:0] mem_out
    );
    begin
        case(funct3)
            FUNCT3_B : func_mem_out = {{(XLEN-8){mem_out[7]}},mem_out[7:0]};
            FUNCT3_BU: func_mem_out = {{(XLEN-8){      1'b0}},mem_out[7:0]};
            FUNCT3_H : func_mem_out = {{(XLEN-16){mem_out[15]}},mem_out[15:0]};
            FUNCT3_HU: func_mem_out = {{(XLEN-16){       1'b0}},mem_out[15:0]};
            FUNCT3_W : func_mem_out = {{(XLEN-31){mem_out[31]}},mem_out[30:0]};
`ifdef RV64I
            FUNCT3_WU: func_mem_out = {{(XLEN-32){       1'b0}},mem_out[31:0]};
            FUNCT3_D : func_mem_out = {{(XLEN-63){mem_out[63]}},mem_out[62:0]};
`endif
            default:   func_mem_out = {(XLEN-1){1'bx}};
        endcase
    end
    endfunction

    ////////////////////////////////////////////////////
    // Byte Read Access
    wire [1:0] addr_sub = alu_out_em[1:0];
    wire [XLEN-1:0] mem_out = func_read_align(addr_sub, data_mem_out);
    // ワードメモリに対するメモリアクセスをバイト単位にする
    function [XLEN-1:0] func_read_align(
        input [1:0] addr,
        input [XLEN-1:0] mem_out
    );
    begin
        case(addr)
            2'b00 : func_read_align =                mem_out[31: 0];
            2'b01 : func_read_align = {{(8 ){ 1'b0}},mem_out[31: 8]};
            2'b10 : func_read_align = {{(16){ 1'b0}},mem_out[31:16]};
            2'b11 : func_read_align = {{(24){ 1'b0}},mem_out[31:24]};
            default:   func_read_align = {(XLEN-1){1'bx}};
        endcase
    end
    endfunction

    ////////////////////////////////////////////////////
    // Byte Write Access
    wire [XLEN-1:0] mem_wdata = func_write_align(addr_sub, rs2data_em);
    // ワードメモリに対するメモリアクセスをバイト単位にする
    function [XLEN-1:0] func_write_align(
        input [1:0] addr,
        input [XLEN-1:0] mem_in
    );
    begin
        case(addr)
            2'b00 : func_write_align =  mem_in[31: 0]             ;
            2'b01 : func_write_align = {mem_in[23: 0],{(8 ){ 1'b0}}};
            2'b10 : func_write_align = {mem_in[15: 0],{(16){ 1'b0}}};
            2'b11 : func_write_align = {mem_in[ 7: 0],{(24){ 1'b0}}};
            default:   func_write_align = {(XLEN-1){1'bx}};
        endcase
    end
    endfunction

    ////////////////////////////////////////////////////
    // Write Enable作成
    assign data_mem_we = (we & phase_memoryaccess) ? func_weram({funct3[1:0],addr_sub}) : 4'b0000;

    function [3:0] func_weram(
        input [3:0] accesstype
    );
    begin
        case(accesstype)
            // Byte Access
            4'b00_00 : func_weram = 4'b0001;
            4'b00_01 : func_weram = 4'b0010;
            4'b00_10 : func_weram = 4'b0100;
            4'b00_11 : func_weram = 4'b1000;
            // Harf Access
            4'b01_00 : func_weram = 4'b0011;
            // 4'b01_01 : func_weram = 4'b0110;       // misAlignment
            4'b01_10 : func_weram = 4'b1100;
            // 4'b01_11 : func_weram = 4'b1000;       // misAlignment
            // Word Access
            4'b10_00 : func_weram = 4'b1111;
            //4'b10_01 : func_weram = 4'1111;       // misAlignment
            //4'b10_10 : func_weram = 4'b1111;       // misAlignment
            //4'b10_11 : func_weram = 4'b1111;       // misAlignment
            // Dword Access
            // 4'b11_00
            default:   func_weram = {(XLEN-1){1'bx}};
        endcase
    end
    endfunction

    /////////////////////////////////////////////
    // CSR系
    assign csr_addr = decoded_op_em[CSR_ADR_BIT_H:CSR_ADR_BIT_L];
    assign csr_wdata = alu_out_em;
    assign csr_we =  phase_memoryaccess ? decoded_op_em[CSR_WE_BIT_H:CSR_WE_BIT_L] : 2'b00 ;


    /////////////////////////////////////////////
    // 次ステージのためのラッチ
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            latch_memoryaccess <= {LATCH_LEN{1'b0}};
        else if(phase_memoryaccess)
            latch_memoryaccess <= {curr_pc_em,alu_out_em,jump_state_em,decoded_op_em,rdsel_em,csr_rdata};
        else
            latch_memoryaccess <= latch_memoryaccess;
    end

    assign {curr_pc_mw,alu_out_mw,jump_state_mw,decoded_op_mw,rdsel_mw,csr_out_mw} = latch_memoryaccess;

    /////////////////////////////////////////////
    // For statemachine
    //     現状メモリアクセスは1clkで終了する
    assign stall_memoryaccess = 1'b0;

endmodule // top_memoryaccess
