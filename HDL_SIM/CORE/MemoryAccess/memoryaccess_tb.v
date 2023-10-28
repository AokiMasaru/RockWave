/*
 * *****************************************************************
 * File: memoryaccess_tb.v
 * Category: MemoryAccess
 * File Created: 2019/01/03 05:13
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2023/10/22 13:25
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:
 *   MemoryAccess階層テストベンチ
 *   top_memoryaccess.vのみ
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2023/10/22	Masaru Aoki	32bitメモリに1Byte単位でアクセスする
 * 2019/01/03	Masaru Aoki	First Version
 * *****************************************************************
 */

 `define STEP 5
 `timescale 1ns/1ns

module memoryaccess_tb;
    `include "core_general.vh"

    reg clk;                       // Global Clock
    reg rst_n;                     // Global Reset

    // From StateMachine
    reg phase_fetch;
    reg phase_decode;
    reg phase_execute;
    reg phase_memoryaccess;        // Fetch Phase
    reg phase_writeback;           // WriteBack Phase
    // From DataMemory
    reg [XLEN-1:0] data_mem_out;   // output
    // From CSR
    reg  [XLEN-1:0] csr_rdata;    // Read Data
    // From Execute
    reg [OPLEN-1:0] decoded_op_em; // Decoded OPcode
    reg jump_state_em;             // PCの次のアドレスがJumpアドレス
    reg [4:0] rdsel_em;            // RD選択
    reg [XLEN-1:0] curr_pc_em;     // 現在 PC Address from Execute
    reg [XLEN-1:0] alu_out_em;     // ALU output
    reg [XLEN-1:0] rs2data_em;     // RS2 data
    // For DataMemory
    wire [AWIDTH-1:0] data_mem_addr;// Address
    wire [XLEN-1:0] data_mem_wdata;// Write Data
    wire [3:0] data_mem_we;        // Write Enable
    // For CSR
    wire [11:0]     csr_addr;     // Address
    wire [XLEN-1:0] csr_wdata;    // Write Data
    wire [1:0]      csr_we;       // Write Enable
    // For WriteBack
    wire [OPLEN-1:0] decoded_op_mw;// Decoded OPcode
    wire jump_state_mw;            // PCの次のアドレスがJumpアドレス
    wire [4:0] rdsel_mw;           // RD選択
    wire [XLEN-1:0] curr_pc_mw;    // 元 PC Address for Decode
    wire [XLEN-1:0] alu_out_mw;    // ALU wire
    wire [XLEN-1:0] mem_out_mw;        // Data Memory Output
    wire [XLEN-1:0] csr_out_mw;    // CSR output
    // For StateMachine
    wire stall_memoryaccess;        // Stall MemoryAccess Phase

    integer i;

    ///////////////////////////////////////////////////////////////////
    // DUT インスタンス
    top_memoryaccess U_top_memoryaccess(.*);

    initial 
        clk = 0;
    always begin
        #(`STEP) clk = ~clk;
    end

///////////////////////////////////////////////////////////////////
// State Machine
initial begin
    phase_fetch = 0;
    phase_decode = 0;
    phase_execute = 0;
    phase_memoryaccess = 0;
    phase_writeback = 0;
    @(posedge rst_n)
    phase_fetch <= 1;
end
always begin
    @(posedge clk)
    phase_fetch <= phase_writeback;
    phase_decode <= phase_fetch;
    phase_execute <= phase_decode;
    phase_memoryaccess  <= phase_execute;
    phase_writeback <= phase_memoryaccess;
end

///////////////////////////////////////////////////////////////////
// Test Bench
initial begin
    $dumpfile("memoryaccess.vcd");
    $dumpvars(0,memoryaccess_tb);

    rst_n=0;
    data_mem_out=0;
    decoded_op_em=0;
    jump_state_em=0;
    rdsel_em=0;
    curr_pc_em=0;
    alu_out_em=0;
    rs2data_em=0;

    @(posedge clk)
    @(posedge clk)
    rst_n = 1;

    ////////////////////////////////////////
    // STORE系動作確認
    ////////////////////////////////////////
    $display("STORE");
    $display("sb:STORE byte 1st");
    @( posedge phase_execute )
    alu_out_em=32'h0000_0000;
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_B;
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b1;
    @( posedge phase_memoryaccess )
    #(1)
    assert_eq(data_mem_we, 4'b0001);
    @( posedge phase_execute )
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_B;
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b0;
    @( posedge phase_memoryaccess )
    #(1)
    assert_eq(data_mem_we, 4'b0000);

    $display("sb:STORE byte 2nd");
    @( posedge phase_execute )
    alu_out_em=32'h0000_0001;
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_B;
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b1;
    @( posedge phase_memoryaccess )
    #(1)
    assert_eq(data_mem_we, 4'b0010);
    @( posedge phase_execute )
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_B;
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b0;
    @( posedge phase_memoryaccess )
    #(1)
    assert_eq(data_mem_we, 4'b0000);

    $display("sb:STORE byte 3rd");
    @( posedge phase_execute )
    alu_out_em=32'h0000_0002;
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_B;
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b1;
    @( posedge phase_memoryaccess )
    #(1)
    assert_eq(data_mem_we, 4'b0100);
    @( posedge phase_execute )
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_B;
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b0;
    @( posedge phase_memoryaccess )
    #(1)
    assert_eq(data_mem_we, 4'b0000);

    $display("sb:STORE byte 4th");
    @( posedge phase_execute )
    alu_out_em=32'h0000_0003;
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_B;
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b1;
    @( posedge phase_memoryaccess )
    #(1)
    assert_eq(data_mem_we, 4'b1000);
    @( posedge phase_execute )
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_B;
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b0;
    @( posedge phase_memoryaccess )
    #(1)
    assert_eq(data_mem_we, 4'b0000);

    $display("sh:STORE HalfWord 1st");
    @( posedge phase_execute )
    alu_out_em=32'h0000_0000;
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_H;
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b1;
    @( posedge phase_memoryaccess )
    #(1)
    assert_eq(data_mem_we, 4'b0011);
    @( posedge phase_execute )
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_H;
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b0;
    @( posedge phase_memoryaccess )
    #(1)
    assert_eq(data_mem_we, 4'b0000);

    $display("sh:STORE HalfWord 2nd");
    @( posedge phase_execute )
    alu_out_em=32'h0000_0002;
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_H;
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b1;
    @( posedge phase_memoryaccess )
    #(1)
    assert_eq(data_mem_we, 4'b1100);
    @( posedge phase_execute )
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_H;
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b0;
    @( posedge phase_memoryaccess )
    #(1)
    assert_eq(data_mem_we, 4'b0000);

    $display("sw:STORE Word");
    @( posedge phase_execute )
    alu_out_em=32'h0000_0000;
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_W;
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b1;
    @( posedge phase_memoryaccess )
    #(1)
    assert_eq(data_mem_we, 4'b1111);
    @( posedge phase_execute )
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_W;
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b0;
    @( posedge phase_memoryaccess )
    #(1)
    assert_eq(data_mem_we, 4'b0000);

    ////////////////////////////////////////
    // LOAD系動作確認
    //     DataMemoryの出力の一部だけ取り出し符号拡張する
    ////////////////////////////////////////
    $display("LOAD");
    /////
    $display("lb :Load Byte 1st");
    alu_out_em=32'h0000_0000;
    @( posedge phase_execute )
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_B;
    @(posedge clk)
    data_mem_out = -1;              // 0xFFFF_FFFF → 0xFFを符号拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, -1);

    @( posedge phase_execute )
    @(posedge clk)
    data_mem_out = 32'h0000_00FF; // → 0xFFを符号拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, -1);

    @( posedge phase_execute )
    @(posedge clk)
    data_mem_out = 32'h0000_0001; // → 0x01を符号拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, 32'h0000_0001);

    @( posedge phase_execute )
    @(posedge clk)
    data_mem_out = 32'h5555_5555; // → 0x55を符号拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, 32'h0000_0055);

    $display("lb :Load Byte 2nd");
    alu_out_em=32'h0000_0001;
    @( posedge phase_execute )
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_B;
    @(posedge clk)
    data_mem_out = -1;              // 0xFFFF_FFFF → 0xFFを符号拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, -1);

    @( posedge phase_execute )
    @(posedge clk)
    data_mem_out = 32'h0000_FF00; // → 0xFFを符号拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, -1);

    @( posedge phase_execute )
    @(posedge clk)
    data_mem_out = 32'h0000_0100; // → 0x01を符号拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, 32'h0000_0001);

    @( posedge phase_execute )
    @(posedge clk)
    data_mem_out = 32'h0000_5500; // → 0x55を符号拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, 32'h0000_0055);

    $display("lb :Load Byte 3rd");
    alu_out_em=32'h0000_0002;
    @( posedge phase_execute )
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_B;
    @(posedge clk)
    data_mem_out = -1;              // 0xFFFF_FFFF → 0xFFを符号拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, -1);

    @( posedge phase_execute )
    @(posedge clk)
    data_mem_out = 32'h00FF_0000; // → 0xFFを符号拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, -1);

    @( posedge phase_execute )
    @(posedge clk)
    data_mem_out = 32'h0001_0000; // → 0x01を符号拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, 32'h0000_0001);

    @( posedge phase_execute )
    @(posedge clk)
    data_mem_out = 32'h0055_0000; // → 0x55を符号拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, 32'h0000_0055);

    $display("lb :Load Byte 4th");
    alu_out_em=32'h0000_0003;
    @( posedge phase_execute )
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_B;
    @(posedge clk)
    data_mem_out = -1;              // 0xFFFF_FFFF → 0xFFを符号拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, -1);

    @( posedge phase_execute )
    @(posedge clk)
    data_mem_out = 32'hFF00_0000; // → 0xFFを符号拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, -1);

    @( posedge phase_execute )
    @(posedge clk)
    data_mem_out = 32'h0100_0000; // → 0x01を符号拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, 32'h0000_0001);

    @( posedge phase_execute )
    @(posedge clk)
    data_mem_out = 32'h5500_0000; // → 0x55を符号拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, 32'h0000_0055);

///////////////////////////////////////////////////////////////////////
    /////
    $display("lbu:Load Byte Unsigned 1st");
    alu_out_em=32'h0000_0000;
    @( posedge phase_execute )
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_BU;
    @(posedge clk)
    data_mem_out = -1;              // 0xFFFF_FFFF → 0xFFを0拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, 32'h0000_00FF);

    @( posedge phase_execute )
    @(posedge clk)
    data_mem_out = 32'h0000_0055; // → 0x55を0拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, 32'h0000_0055);

    @( posedge phase_execute )
    @(posedge clk)
    data_mem_out = 32'h0000_AAAA; // → 0xAAを0拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, 32'h0000_00AA);

    @( posedge phase_execute )
    @(posedge clk)
    data_mem_out = 32'h0000_0000; // → 0x00を0拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, 32'h0000_0000);

    $display("lbu:Load Byte Unsigned 2nd");
    alu_out_em=32'h0000_0001;
    @( posedge phase_execute )
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_BU;
    @(posedge clk)
    data_mem_out = -1;              // 0xFFFF_FFFF → 0xFFを0拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, 32'h0000_00FF);

    @( posedge phase_execute )
    @(posedge clk)
    data_mem_out = 32'h0000_5500; // → 0x55を0拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, 32'h0000_0055);

    @( posedge phase_execute )
    @(posedge clk)
    data_mem_out = 32'h0000_AA00; // → 0xAAを0拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, 32'h0000_00AA);

    @( posedge phase_execute )
    @(posedge clk)
    data_mem_out = 32'h0000_0000; // → 0x00を0拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, 32'h0000_0000);

    $display("lbu:Load Byte Unsigned 3rd");
    alu_out_em=32'h0000_0002;
    @( posedge phase_execute )
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_BU;
    @(posedge clk)
    data_mem_out = -1;              // 0xFFFF_FFFF → 0xFFを0拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, 32'h0000_00FF);

    @( posedge phase_execute )
    @(posedge clk)
    data_mem_out = 32'h0055_0000; // → 0x55を0拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, 32'h0000_0055);

    @( posedge phase_execute )
    @(posedge clk)
    data_mem_out = 32'h00AA_0000; // → 0xAAを0拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, 32'h0000_00AA);

    @( posedge phase_execute )
    @(posedge clk)
    data_mem_out = 32'h0000_0000; // → 0x00を0拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, 32'h0000_0000);

    $display("lbu:Load Byte Unsigned 4th");
    alu_out_em=32'h0000_0003;
    @( posedge phase_execute )
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_BU;
    @(posedge clk)
    data_mem_out = -1;              // 0xFFFF_FFFF → 0xFFを0拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, 32'h0000_00FF);

    @( posedge phase_execute )
    @(posedge clk)
    data_mem_out = 32'h5500_0000; // → 0x55を0拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, 32'h0000_0055);

    @( posedge phase_execute )
    @(posedge clk)
    data_mem_out = 32'hAA00_0000; // → 0xAAを0拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, 32'h0000_00AA);

    @( posedge phase_execute )
    @(posedge clk)
    data_mem_out = 32'h0000_0000; // → 0x00を0拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, 32'h0000_0000);

    /////
    $display("lh :Load Halfword");
    alu_out_em=32'h0000_0000;
    @( posedge phase_execute )
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_H;
    @(posedge clk)
    data_mem_out = -1;              // 0xFFFF_FFFF → 0xFFFFFを符号拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, 32'hFFFF_FFFF);

    @( posedge phase_execute )
    @(posedge clk)
    data_mem_out = 32'h0000_5555; // → 0x5555を符号拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, 32'h0000_5555);

    @( posedge phase_execute )
    @(posedge clk)
    data_mem_out = 32'h0000_AAAA; // → 0xAAAAを符号拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, 32'hFFFF_AAAA);

    @( posedge phase_execute )
    @(posedge clk)
    data_mem_out = 32'h0000_0000; // → 0x0000を符号拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, 32'h0000_0000);

    $display("lh :Load Halfword 2nd");
    alu_out_em=32'h0000_0002;
    @( posedge phase_execute )
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_H;
    @(posedge clk)
    data_mem_out = -1;              // 0xFFFF_FFFF → 0xFFFFFを符号拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, 32'hFFFF_FFFF);

    @( posedge phase_execute )
    @(posedge clk)
    data_mem_out = 32'h5555_0000; // → 0x5555を符号拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, 32'h0000_5555);

    @( posedge phase_execute )
    @(posedge clk)
    data_mem_out = 32'hAAAA_0000; // → 0xAAAAを符号拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, 32'hFFFF_AAAA);

    @( posedge phase_execute )
    @(posedge clk)
    data_mem_out = 32'h0000_0000; // → 0x0000を符号拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, 32'h0000_0000);
    /////
    $display("lhu:Load Halfword Unsigned 1st");
    alu_out_em=32'h0000_0000;
    @( posedge phase_execute )
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_HU;
    @(posedge clk)
    data_mem_out = -1;              // 0xFFFF_FFFF → 0xFFFFFを0拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, 32'h0000_FFFF);

    @( posedge phase_execute )
    @(posedge clk)
    data_mem_out = 32'h1111_5555; // → 0x5555を0拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, 32'h0000_5555);

    @( posedge phase_execute )
    @(posedge clk)
    data_mem_out = 32'h1111_AAAA; // → 0xAAAAを0拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, 32'h0000_AAAA);

    @( posedge phase_execute )
    @(posedge clk)
    data_mem_out = 32'hDEAD_0000; // → 0x0000を0拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, 32'h0000_0000);
    /////
    $display("lhu:Load Halfword Unsigned 2nd");
    alu_out_em=32'h0000_0002;
    @( posedge phase_execute )
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_HU;
    @(posedge clk)
    data_mem_out = -1;              // 0xFFFF_FFFF → 0xFFFFFを0拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, 32'h0000_FFFF);

    @( posedge phase_execute )
    @(posedge clk)
    data_mem_out = 32'h5555_BEAF; // → 0x5555を0拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, 32'h0000_5555);

    @( posedge phase_execute )
    @(posedge clk)
    data_mem_out = 32'hAAAA_BEAF; // → 0xAAAAを0拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, 32'h0000_AAAA);

    @( posedge phase_execute )
    @(posedge clk)
    data_mem_out = 32'h0000_BEAF; // → 0x0000を0拡張
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, 32'h0000_0000);
    /////
    $display("lw :Load Word");
    alu_out_em=32'h0000_0000;
    @( posedge phase_execute )
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_W;
    @(posedge clk)
    data_mem_out = -1;              // 0xFFFF_FFFF
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, 32'hFFFF_FFFF);

    @( posedge phase_execute )
    @(posedge clk)
    data_mem_out = 32'h5555_5555;
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, 32'h5555_5555);

    @( posedge phase_execute )
    @(posedge clk)
    data_mem_out = 32'hAAAA_AAAA;
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, 32'hAAAA_AAAA);

    @( posedge phase_execute )
    @(posedge clk)
    data_mem_out = 32'hFFFF_0000;
    @( posedge phase_writeback )
    assert_eq(mem_out_mw, 32'hFFFF_0000);

    ////////////////////////////////////////
    // ラッチ動作確認
    ////////////////////////////////////////

    // Current Program Counter
    $display("Current Program Counter");
    for(i=0;i<=32'hFFFF;i++) begin
        @(posedge phase_execute)
        curr_pc_em = i;
        @(negedge phase_memoryaccess)
        #(1)
        assert_eq(curr_pc_mw,i);
    end
    // ALU out
    $display("ALU out");
    for(i=0;i<=32'hFFFF;i++) begin
        @(posedge phase_execute)
        alu_out_em = i;
        @(negedge phase_memoryaccess)
        #(1)
        assert_eq(alu_out_mw,i);
    end
    // JumpState
    $display("Jump State");
    @(posedge phase_execute)
    jump_state_em = 0;
    @(negedge phase_memoryaccess)
    #(1)
    assert_eq(jump_state_mw,0);
    @(posedge phase_execute)
    jump_state_em = 1;
    @(negedge phase_memoryaccess)
    #(1)
    assert_eq(jump_state_mw,1);

    // Decoded Opcode
    $display("Decoded Opcode");
    for(i=0;i<=9'h1FF;i++) begin
        @(posedge phase_execute)
        decoded_op_em = i;
        @(negedge phase_memoryaccess)
        #(1)
        assert_eq(decoded_op_mw,i);
    end

    // RDsel
    $display("RDsel");
    for(i=0;i<=5'h1F;i++) begin
        @(posedge phase_execute)
        rdsel_em = i;
        @(negedge phase_memoryaccess)
        #(1)
        assert_eq(rdsel_mw,i);
    end

    #(100)
    $finish;
    end

task assert_eq;
    input [XLEN-1:0] a;
    input [XLEN-1:0] b;
    begin
        if(a == b) begin
        end
        else begin
            $display("Assert NG (%h,%h)",a,b);
            #(`STEP*10)
            $finish;
        end
    end
endtask

endmodule
