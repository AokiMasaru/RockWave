/*
 * *****************************************************************
 * File: csr.v
 * Category: CSR
 * File Created: 2023/09/14 04:56
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2023/11/04 08:37
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2023  Project RockWave
 * *****************************************************************
 * Description:
 *   Control and Status Registers (CSRs) と
 *   割込み処理
 *      1. 条件を満たした状態で割り込みが発生する。
 *      2. MCAUSE に割り込みコードを設定し、最上位ビットを 1 にする。
 *      3. MEPC に割り込みが発生した時に実行中の PC を設定する。
 *      4. MTVAL に 0 を設定する。
 *      5. MSTATUS を現在の状態に合わせて更新する。
 *          MIE / HIE / SIE / UIE を MPIE / HPIE / SPIE / UPIEに退避
 *          MIE = 0 (割込み禁止)
 *      6. MTVEC の値を元に PC を更新する。
 *         soft:割り込みハンドラの処理を開始する。
 *         soft:使用するレジスタを退避する。
 *         soft:割り込みを処理する。
 *         soft:退避していたレジスタを回復する。
 *         soft:mret を実行して割り込みハンドラの処理を終了する。
 *      7. MSTATUS を現在の状態に合わせて更新する。
 *          MPIE / HPIE / SPIE / UPIE から MIE / HIE / SIE / UIE を復帰
 *      8. PC を MEPC の値を元に更新する。
 *         soft:通常の処理に戻る。
 
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2023/09/14	Masaru Aoki	First Version
 * *****************************************************************
 */
module top_csr(
    input       clk,        // Global clock
    input       rst_n,      // Global Reset

    input               phase_fetch, //
    input  [11:0]       csr_addr,     // Address
    input  [XLEN-1:0]   csr_wdata,    // Write Data
    input  [1:0]        csr_we,       // Write Enable

    output [XLEN-1:0]   csr_rdata,    // Read Data

    input               int_timer,  // Interupt Request from Timer
    output              int_cw,     // Interupt Request For WriteBack
    input               mret_ew,    // MRET from Execute

    output  [XLEN-1:0]  mtvec,      // Machine Trap-Vector Base-Address Register
    input   [XLEN-1:0]  next_pc_wc, // mepcに保存する次実行するProgramCounter
    output  [XLEN-1:0]  mepc        // Machine Exception Program Counter (mepc)
);
    `include "core_general.vh"

    localparam WPRI = 1'b0;         // Reserved Writes Preserve Values, Reads Ignore Values (WPRI);

    wire    int;            // 条件を満たした状態で割込が発生した

    wire [ XLEN-1:0]     reg300;                // Register: Machine Status Register (mstatus)
    wire [ XLEN-1:0]     mstatus;               // data_out: Machine Status Register (mstatus)
    wire [ XLEN-1:0]     reg304;                // Register: Machine interrupt-enable register (mie).
    wire [ XLEN-1:0]     mie;                   // data_out: Machine interrupt-enable register (mie).
    wire [ XLEN-1:0]     reg305;                // MTVEC
    wire [ XLEN-1:0]     reg340;                // mscratch	Scratch register for machine trap handlers
    wire [ XLEN-1:0]     null_reg340_dataout;
    wire [ XLEN-1:0]     reg341;                // MEPC
    wire [ XLEN-1:0]     reg342;                // Register:   Machine Cause register (mcause).
    wire [ XLEN-1:0]     mcause;                // write_data: Machine Cause register (mcause).
    wire [ XLEN-1:0]     null_reg342_dataout;
    wire [ XLEN-1:0]     reg343;                // Register:   Machine Trap Value (mtval) Register
    wire [ XLEN-1:0]     mtval;                 // write_data: Machine Trap Value (mtval) Register
    wire [ XLEN-1:0]     null_reg343_dataout;
    wire [ XLEN-1:0]     reg344;                // MIP
    wire [ XLEN-1:0]     null_reg344_dataout;

    // Address Select
    wire adsel300 = (csr_addr[11:0] == 12'h300);
    wire adsel304 = (csr_addr[11:0] == 12'h304);
    wire adsel305 = (csr_addr[11:0] == 12'h305);
    wire adsel340 = (csr_addr[11:0] == 12'h340);
    wire adsel341 = (csr_addr[11:0] == 12'h341);
    wire adsel342 = (csr_addr[11:0] == 12'h342);
    wire adsel343 = (csr_addr[11:0] == 12'h343);
    wire adsel344 = (csr_addr[11:0] == 12'h344);

    // Write Enable for RW reg
    wire we = csr_we != 2'b00 ;
    wire wenble304 = adsel304 & we;
    wire wenble305 = adsel305 & we;
    wire wenble340 = adsel340 & we;
    wire wenble343 = adsel343 & we;
    wire wenble344 = adsel344 & we;

    // ライトデータ
    wire [XLEN-1:0] wdata = fnc_csr_wdata(csr_we, csr_wdata,csr_rdata);
function [XLEN-1:0] fnc_csr_wdata(
    input [1:0] csr_we,
    input [XLEN-1:0] csr_wdata,
    input [XLEN-1:0] csr_rdata
);
begin
    case (csr_we)
        CSR_NONE : 
            fnc_csr_wdata = csr_rdata;
        CSR_CSRW : 
            fnc_csr_wdata = csr_wdata;
        CSR_CSRS : 
            fnc_csr_wdata = csr_rdata | csr_wdata;
        CSR_CSRC :
            fnc_csr_wdata = csr_rdata & ~csr_wdata;
        default : 
            fnc_csr_wdata = {XLEN{1'bx}}; 
    endcase
end  
endfunction

    assign csr_rdata = 
        reg300 |
        reg304 |
        reg305 |
        reg340 |
        reg341 |
        reg342 |
        reg343 |
        reg344
        ;

    // 1. 条件を満たした状態で割り込みが発生する。
    assign mtip = mie_mtie & int_timer;     // Machine interrupt-pending register 現状割込はタイマのみ
    assign int = mtip & mstatus_mie;
    wire int_cw = int;

    // 2. MCAUSE に割り込みコードを設定し、最上位ビットを 1 にする。
    assign  mcause = {1'b1, 31'h0007};   //Machine timer interrupt
    wire    wenble342 = phase_fetch & int;

    // 3. MEPC に割り込みが発生した時に実行中の PC を設定する。
    wire    wenble341 = (phase_fetch & int) | (adsel341 & we);

    //  4. MTVAL に 0 を設定する。
    assign    mtval = 32'h0000_0000;

    //  5. MSTATUS を現在の状態に合わせて更新する。
    //      MIE / HIE / SIE / UIE を MPIE / HPIE / SPIE / UPIEに退避
    //      MIE = 0 (割込み禁止)
    wire    int_wenble = phase_fetch & int;
    wire [XLEN-1:0]   int_mstatus;
    assign int_mstatus[31]    = mstatus[31];  // SD
    assign int_mstatus[30:23] = {8{WPRI}};    // 
    assign int_mstatus[22]    = mstatus[22];  // TSR
    assign int_mstatus[21]    = mstatus[21];  // TW
    assign int_mstatus[20]    = mstatus[20];  // TVM
    assign int_mstatus[19]    = mstatus[19];  // MXR
    assign int_mstatus[18]    = mstatus[18];  // SUM
    assign int_mstatus[17]    = mstatus[17];  // MPRV
    assign int_mstatus[16:15] = mstatus[16:15];// XS
    assign int_mstatus[14:13] = mstatus[14:13];// FS
    assign int_mstatus[12:11] = mstatus[12:11];// MPP
    assign int_mstatus[10: 9] = {2{WPRI}};    // WPRI
    assign int_mstatus[ 8]    = mstatus[ 8];  // SPP
    assign int_mstatus[ 7]    = mstatus[ 3];  // MIE -> MPIE
    assign int_mstatus[ 6]    = WPRI;         // WPRI
    assign int_mstatus[ 5]    = mstatus[1];   // SIE -> SPIE
    assign int_mstatus[ 4]    = mstatus[0];   // UIE -> UPIE
    assign int_mstatus[ 3]    = 1'b0;         // 0   -> MIE
    assign int_mstatus[ 2]    = WPRI;         // WPRI
    assign int_mstatus[ 1]    = mstatus[1];   // SIE
    assign int_mstatus[ 0]    = mstatus[0];   // UIE

    // 6. MTVEC の値を元に PC を更新する。
    //      WriteBackで行う
    // *  soft:mret を実行して割り込みハンドラの処理を終了する。
    // 7. MSTATUS を現在の状態に合わせて更新する。
    //      MPIE / HPIE / SPIE / UPIE から MIE / HIE / SIE / UIE を復帰
    wire    mret_wenble = phase_fetch & mret_ew;
    wire [XLEN-1:0]   mret_mstatus;
    assign mret_mstatus[31]    = mstatus[31];  // SD
    assign mret_mstatus[30:23] = {8{WPRI}};    // 
    assign mret_mstatus[22]    = mstatus[22];  // TSR
    assign mret_mstatus[21]    = mstatus[21];  // TW
    assign mret_mstatus[20]    = mstatus[20];  // TVM
    assign mret_mstatus[19]    = mstatus[19];  // MXR
    assign mret_mstatus[18]    = mstatus[18];  // SUM
    assign mret_mstatus[17]    = mstatus[17];  // MPRV
    assign mret_mstatus[16:15] = mstatus[16:15];// XS
    assign mret_mstatus[14:13] = mstatus[14:13];// FS
    assign mret_mstatus[12:11] = mstatus[12:11];// MPP
    assign mret_mstatus[10: 9] = {2{WPRI}};    // WPRI
    assign mret_mstatus[ 8]    = mstatus[ 8];  // SPP
    assign mret_mstatus[ 7]    = mstatus[ 7];  // MPIE
    assign mret_mstatus[ 6]    = WPRI;         // WPRI
    assign mret_mstatus[ 5]    = mstatus[ 5];  // SPIE
    assign mret_mstatus[ 4]    = mstatus[ 4];  // UPIE
    assign mret_mstatus[ 3]    = mstatus[ 7];  // MPIE -> MIE
    assign mret_mstatus[ 2]    = WPRI;         // WPRI
    assign mret_mstatus[ 1]    = mstatus[ 5];  // SPIE -> SIE
    assign mret_mstatus[ 0]    = mstatus[ 4];  // UPIE -> UIE
    // 8. PC を MEPC の値を元に更新する。
    //      WriteBackで行う
             

    // 0x300	MSTATUS	プロセッサの現在の状態を表す。
    wire wenble300 = int_wenble | mret_wenble | (adsel300 & we);
    wire [XLEN-1:0] wdata300 = (adsel300 & we) ? wdata : (mret_wenble ? mret_mstatus : (int_wenble ? int_mstatus : 32'h0000_0000));
    wire mstatus_mie = mstatus[3];
    reg_rw #(XLEN) U_reg300(
        .clk(clk), .rst_n(rst_n),
        .wdata(wdata300), .we(wenble300), 
        .rdata(reg300), .re(adsel300),
        .dataout(mstatus)
    );

    // 0x304	MIE	どの割り込みが可能かを表す。
    wire mie_mtie = mie[7];
    reg_rw #(XLEN) U_reg304(
        .clk(clk), .rst_n(rst_n),
        .wdata(wdata), .we(wenble304), 
        .rdata(reg304), .re(adsel304),
        .dataout(mie)
    );

    // 0x305	MTVEC	割り込み・例外が発生した場合にジャンプする PC を格納する。
    wire [XLEN-1:0] wdata_mtvec = {wdata[XLEN-1:1],1'b0};
    wire [XLEN-1:0] dataout_mtvec;
    wire [XLEN-1:0] mtvec = dataout_mtvec+(mcause<<2);
    reg_rw #(XLEN) U_reg305(
        .clk(clk), .rst_n(rst_n),
        .wdata(wdata_mtvec), .we(wenble305), 
        .rdata(reg305), .re(adsel305),
        .dataout(dataout_mtvec)
    );

    // 0x340    mscratch    Scratch register for machine trap handlers
    //      riscv-tests csrで使用する
    reg_rw #(XLEN) U_reg340(
        .clk(clk), .rst_n(rst_n),
        .wdata(wdata), .we(wenble340), 
        .rdata(reg340), .re(adsel340),
        .dataout(null_reg340_dataout)
    );

    // 0x341	MEPC	例外が発生した命令の場所を表す PC を格納する。
    //  mret 命令ではこの値を使って元の処理に復帰する。    
    wire [XLEN-1:0] wdata341 = int ? next_pc_wc : wdata;
    reg_rw #(XLEN) U_reg341(
        .clk(clk), .rst_n(rst_n),
        .wdata(wdata341), .we(wenble341), 
        .rdata(reg341), .re(adsel341),
        .dataout(mepc)
    );

    // 0x342	MCAUSE	例外・割り込みが発生した要因を格納する。
    //  割り込みの場合は最上位ビットが1になる。
    reg_rw #(XLEN) U_reg342(
        .clk(clk), .rst_n(rst_n),
        .wdata(mcause), .we(wenble342), 
        .rdata(reg342), .re(adsel342),
        .dataout(null_reg342_dataout)
    );

    // 0x343	MTVAL	発生する例外に応じた値を格納する。
    //  例えば不正命令なら命令を、ブレークポイントならその PC を格納する。
    reg_rw #(XLEN) U_reg343(
        .clk(clk), .rst_n(rst_n),
        .wdata(mtval), .we(wenble343), 
        .rdata(reg343), .re(adsel343),
        .dataout(null_reg343_dataout)
    );

    // 0x344	MIP	割り込みの待ち状態を表す。MIE と合わせて割り込みを起こすか判断する。
    reg_rw #(XLEN) U_reg344(
        .clk(clk), .rst_n(rst_n),
        .wdata(wdata), .we(wenble344), 
        .rdata(reg344), .re(adsel344),
        .dataout(null_reg344_dataout)
    );


endmodule
