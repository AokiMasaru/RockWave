/*
 * *****************************************************************
 * File: top_memoryaccess_tb.v
 * Category: MemoryAccess
 * File Created: 2019/01/06 04:28
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2023/10/22 14:40
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:
 *   top_memoryaccessとramを組み合わせたテスト
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2023/10/22	Masaru Aoki	32bitメモリに1Byte単位でアクセスする
 * 2019/01/06	Masaru Aoki	First Version
 * *****************************************************************
 */

 `define STEP 5
 `timescale 1ns/1ns

module top_memoryaccess_tb;
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
    wire [XLEN-1:0] data_mem_out;   // output
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
    ram U_ram(
        .clk(clk),
        .rst_n(rst_n),
        .addr(data_mem_addr),
        .qin(data_mem_wdata),
        .qout(data_mem_out),
        .we(data_mem_we)
    );

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
    $dumpfile("top_memoryaccess.vcd");
    $dumpvars(0,top_memoryaccess_tb);

    rst_n=0;
    decoded_op_em=0;
    jump_state_em=0;
    rdsel_em=0;
    curr_pc_em=0;
    alu_out_em=0;
    rs2data_em=0;
    for(i=0;i<=32'hFFFF;i++) begin
        U_ram.U_ram.RAM[i]=0;
    end

    @(posedge clk)
    @(posedge clk)
    rst_n = 1;

    ////////////////////////////////////////
    // STORE系動作確認
    ////////////////////////////////////////
    $display("STORE");
    $display("sb :STORE byte 1st ");
    @( posedge phase_execute )
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_B;
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b1;
    alu_out_em = 32'h0000_0000;  // addr
    rs2data_em = 32'h0000_0055;  // data
    @( posedge phase_execute )
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b0;
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_W;
    @( posedge phase_memoryaccess )
    #(1)
    assert_eq(data_mem_wdata,32'h0000_0055);

    $display("sb :STORE byte 2nd ");
    @( posedge phase_execute )
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_B;
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b1;
    alu_out_em = 32'h0000_0001;  // addr
    rs2data_em = 32'h0000_0055;  // data
    @( posedge phase_execute )
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b0;
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_W;
    @( posedge phase_memoryaccess )
    #(1)
    assert_eq(data_mem_wdata,32'h0000_5500);

    $display("sb :STORE byte 3rd ");
    @( posedge phase_execute )
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_B;
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b1;
    alu_out_em = 32'h0000_0002;  // addr
    rs2data_em = 32'h0000_0055;  // data
    @( posedge phase_execute )
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b0;
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_W;
    @( posedge phase_memoryaccess )
    #(1)
    assert_eq(data_mem_wdata,32'h0055_0000);

    $display("sb :STORE byte 4th ");
    @( posedge phase_execute )
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_B;
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b1;
    alu_out_em = 32'h0000_0003;  // addr
    rs2data_em = 32'h0000_0055;  // data
    @( posedge phase_execute )
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b0;
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_W;
    @( posedge phase_memoryaccess )
    #(1)
    assert_eq(data_mem_wdata,32'h5500_0000);

    $display("sh :STORE Halfword");
    @( posedge phase_execute )
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_H;
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b1;
    alu_out_em = 32'h0000_0004;  // addr
    rs2data_em = 32'hDEAD_AAAA;  // data
    @( posedge phase_execute )
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b0;
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_W;
    @( posedge phase_memoryaccess )
    #(1)
    assert_eq(data_mem_wdata,32'hDEAD_AAAA);

    $display("sh :STORE Halfword 2nd");
    @( posedge phase_execute )
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_H;
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b1;
    alu_out_em = 32'h0000_0006;  // addr
    rs2data_em = 32'hDEAD_AAAA;  // data
    @( posedge phase_execute )
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b0;
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_W;
    @( posedge phase_memoryaccess )
    #(1)
    assert_eq(data_mem_wdata,32'hAAAA_0000);

    $display("sw :STORE Word");
    @( posedge phase_execute )
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_W;
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b1;
    alu_out_em = 32'h0000_0008;  // addr
    rs2data_em = 32'hDEAD_BEEF;  // data
    @( posedge phase_execute )
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b0;
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_W;
    @( posedge phase_memoryaccess )
    #(1)
    assert_eq(data_mem_wdata,32'hDEAD_BEEF);

    ////////////////////////////////////////
    // LOAD系動作確認
    //     DataMemoryの出力の一部だけ取り出し符号拡張する
    ////////////////////////////////////////
    $display("LOAD");
    /////
    $display("lb :Load Byte");
    @( posedge phase_execute )
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_W;
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b1;
    alu_out_em = 32'h0000_000C;  // addr
    rs2data_em = 32'hFFFF_FFFF;  // data
    @( posedge phase_execute )
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b0;
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_B;
    @( posedge phase_memoryaccess )
    #(1)
    assert_eq(mem_out_mw,32'hFFFF_FFFF);
    /////
    $display("lbu:Load Byte Unsinged");
    @( posedge phase_execute )
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_BU;
    @( posedge phase_memoryaccess )
    #(1)
    assert_eq(mem_out_mw,32'h0000_00FF);

    /////
    $display("lh :Load Halfword");
    @( posedge phase_execute )
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_W;
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b1;
    alu_out_em = 32'h0000_0010;  // addr
    rs2data_em = 32'hAAAA_AAAA;  // data
    @( posedge phase_execute )
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b0;
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_H;
    @( posedge phase_memoryaccess )
    #(1)
    assert_eq(mem_out_mw,32'hFFFF_AAAA);
    /////
    $display("lhu:Load Halfword Unsinged");
    @( posedge phase_execute )
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_HU;
    @( posedge phase_memoryaccess )
    #(1)
    assert_eq(mem_out_mw,32'h0000_AAAA);

    /////
    $display("lw :Load Word");
    @( posedge phase_execute )
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_W;
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b1;
    alu_out_em = 32'h0000_0014;  // addr
    rs2data_em = 32'h5555_5555;  // data
    @( posedge phase_execute )
    decoded_op_em[DATA_MEM_WE_BIT] = 1'b0;
    decoded_op_em[FUNCT3_BIT_M:FUNCT3_BIT_L] = FUNCT3_W;
    @( posedge phase_memoryaccess )
    #(1)
    assert_eq(mem_out_mw,32'h5555_5555);

    $display("All test is GREEN");
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
