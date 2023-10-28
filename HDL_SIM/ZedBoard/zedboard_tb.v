 /*
 * *****************************************************************
 * File: zedboard_tb.v
 * Category: riscv-tests
 * File Created: 2023/10/25 04:22
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2023/10/25 04:22
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2023  Project RockWave
 * *****************************************************************
 * Description:
 *	ZedBoardでriscv-testsを実行する
 *	メモリ関連のみ
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2023/10/25	Masaru Aoki	First Version
 * *****************************************************************
 */

module zedboard_tb(
);

`include "core_general.vh"

// DUT in/out
    reg clk;

    reg [12:0]   gpio_pin_in;
    wire [7:0]   gpio_pin_out;

    wire         hsync;
    wire         vsync;
    wire [3:0]   rdata;
    wire [3:0]   gdata;
    wire [3:0]   bdata;

integer i;//forループ用
top_zedboard U_top_zedboard (.*);

//gtk wave 波形表示用
wire [XLEN-1:0] pc = U_top_zedboard.u_top_core.u_top_fetch.program_counter;
wire [XLEN-1:0] x01_ra = U_top_zedboard.u_top_core.u_register_file.x1out;
wire [XLEN-1:0] x02_sp = U_top_zedboard.u_top_core.u_register_file.x2out;
wire [XLEN-1:0] x03_gp = U_top_zedboard.u_top_core.u_register_file.x3out;
wire [XLEN-1:0] x04_tp = U_top_zedboard.u_top_core.u_register_file.x4out;
wire [XLEN-1:0] x05_t0 = U_top_zedboard.u_top_core.u_register_file.x5out;
wire [XLEN-1:0] x06_t1 = U_top_zedboard.u_top_core.u_register_file.x6out;
wire [XLEN-1:0] x07_t2 = U_top_zedboard.u_top_core.u_register_file.x7out;
wire [XLEN-1:0] x08_s0_fp = U_top_zedboard.u_top_core.u_register_file.x8out;
wire [XLEN-1:0] x09_s1 = U_top_zedboard.u_top_core.u_register_file.x9out;
wire [XLEN-1:0] x10_a0 = U_top_zedboard.u_top_core.u_register_file.x10out;
wire [XLEN-1:0] x11_a1 = U_top_zedboard.u_top_core.u_register_file.x11out;
wire [XLEN-1:0] x12_a2 = U_top_zedboard.u_top_core.u_register_file.x12out;
wire [XLEN-1:0] x13_a3 = U_top_zedboard.u_top_core.u_register_file.x13out;
wire [XLEN-1:0] x14_a4 = U_top_zedboard.u_top_core.u_register_file.x14out;
wire [XLEN-1:0] x15_a5 = U_top_zedboard.u_top_core.u_register_file.x15out;
wire [XLEN-1:0] x16_a6 = U_top_zedboard.u_top_core.u_register_file.x16out;
wire [XLEN-1:0] x17_a7 = U_top_zedboard.u_top_core.u_register_file.x17out;
wire [XLEN-1:0] x18_s2 = U_top_zedboard.u_top_core.u_register_file.x18out;
wire [XLEN-1:0] x19_s3 = U_top_zedboard.u_top_core.u_register_file.x19out;
wire [XLEN-1:0] x20_s4 = U_top_zedboard.u_top_core.u_register_file.x20out;
wire [XLEN-1:0] x21_s5 = U_top_zedboard.u_top_core.u_register_file.x21out;
wire [XLEN-1:0] x22_s6 = U_top_zedboard.u_top_core.u_register_file.x22out;
wire [XLEN-1:0] x23_s7 = U_top_zedboard.u_top_core.u_register_file.x23out;
wire [XLEN-1:0] x24_s8 = U_top_zedboard.u_top_core.u_register_file.x24out;
wire [XLEN-1:0] x25_s9 = U_top_zedboard.u_top_core.u_register_file.x25out;
wire [XLEN-1:0] x26_s10 = U_top_zedboard.u_top_core.u_register_file.x26out;
wire [XLEN-1:0] x27_s11 = U_top_zedboard.u_top_core.u_register_file.x27out;
wire [XLEN-1:0] x28_t3 = U_top_zedboard.u_top_core.u_register_file.x28out;
wire [XLEN-1:0] x29_t4 = U_top_zedboard.u_top_core.u_register_file.x29out;
wire [XLEN-1:0] x30_t5 = U_top_zedboard.u_top_core.u_register_file.x30out;
wire [XLEN-1:0] x31_t6 = U_top_zedboard.u_top_core.u_register_file.x31out;

//gtk wave 波形表示用 CSR
wire [XLEN-1:0] mstatus     = U_top_zedboard.u_top_core.u_reg_csr.null_reg300_dataout;
wire [XLEN-1:0] mie         = U_top_zedboard.u_top_core.u_reg_csr.null_reg304_dataout;
wire [XLEN-1:0] mtvec       = U_top_zedboard.u_top_core.u_reg_csr.null_reg305_dataout;
wire [XLEN-1:0] mscratch    = U_top_zedboard.u_top_core.u_reg_csr.null_reg340_dataout;
wire [XLEN-1:0] mepc        = U_top_zedboard.u_top_core.u_reg_csr.null_reg341_dataout;
wire [XLEN-1:0] mcause      = U_top_zedboard.u_top_core.u_reg_csr.null_reg342_dataout;
wire [XLEN-1:0] mtval       = U_top_zedboard.u_top_core.u_reg_csr.null_reg343_dataout;
wire [XLEN-1:0] mip         = U_top_zedboard.u_top_core.u_reg_csr.null_reg344_dataout;

// gtkwave 命令表示用
wire [9:0] op = {U_top_zedboard.u_top_core.u_instruction_decode.inst[14:12],U_top_zedboard.u_top_core.u_instruction_decode.inst[6:0]};
wire [9:0][7:0] opcode = decode(op);

function [9:0][7:0] decode(
    input[9:0] op
);
begin
    casex (op)
        10'bxxx_0110111: decode = "LUI";
        10'bxxx_0010111: decode = "AUIPC";
        10'bxxx_1101111: decode = "JAL";
        10'b000_1100111: decode = "JALR";
        10'b000_1100011: decode = "BEQ";
        10'b001_1100011: decode = "BNE";
        10'b100_1100011: decode = "BLT";
        10'b101_1100011: decode = "BGE";
        10'b110_1100011: decode = "BLTU";
        10'b111_1100011: decode = "BGEU";
        10'b000_0000011: decode = "LB";
        10'b001_0000011: decode = "LH";
        10'b010_0000011: decode = "LW";
        10'b100_0000011: decode = "LBU";
        10'b101_0000011: decode = "LHU";
        10'b000_0100011: decode = "SB";
        10'b001_0100011: decode = "SH";
        10'b010_0100011: decode = "SW";
        10'b000_0010011: decode = "ADDI";
        10'b010_0010011: decode = "SLTI";
        10'b011_0010011: decode = "SLTIU";
        10'b100_0010011: decode = "XORI";
        10'b110_0010011: decode = "ORI";
        10'b111_0010011: decode = "ANDI";
        10'b001_0010011: decode = "SLLI";
        10'b101_0010011: decode = "SRLI";
        10'b101_0010011: decode = "SRAI";
        10'b000_0110011: decode = "ADD";
        10'b000_0110011: decode = "SUB";
        10'b001_0110011: decode = "SLL";
        10'b010_0110011: decode = "SLT";
        10'b011_0110011: decode = "SLTU";
        10'b100_0110011: decode = "XOR";
        10'b101_0110011: decode = "SRL";
        10'b101_0110011: decode = "SRA";
        10'b110_0110011: decode = "OR";
        10'b111_0110011: decode = "AND";
        10'b000_0001111: decode = "FENCE";
        10'b001_0001111: decode = "FENCE.I";
        10'b000_1110011: decode = "ECALL";
        10'b000_1110011: decode = "EBREAK";
        10'b001_1110011: decode = "CSRRW";
        10'b010_1110011: decode = "CSRRS";
        10'b011_1110011: decode = "CSRRC";
        10'b101_1110011: decode = "CSRRWI";
        10'b110_1110011: decode = "CSRRSI";
        10'b111_1110011: decode = "CSRRCI";
        default:         decode = "";
    endcase
end  
endfunction

//clock
initial
    clk = 0;
always begin
    #5 clk = ~clk;
end

reg[AWIDTH-1:0] memDataStartAddr = 'h800;
initial begin
    // ROM / RAMは、top_zedboard.vで読み込む
    $dumpfile({`TARGET, ".vcd"});
    $dumpvars(0,zedboard_tb);

    U_top_zedboard.rst_n = 0;
    gpio_pin_in = 12'hAAA;

    ////Core simulation start
    @(posedge clk) #1;
    #10
    U_top_zedboard.rst_n = 1;
    #5000000

    //time out error
    $display("%s, %2d",{"TimeOut result, ", `INST_ROM_FILE_NAME}, -1);
    $finish;
end

localparam ECALL = 32'h73;

wire [XLEN-1:0] result = U_top_zedboard.u_top_core.U_top_zedboard.u_top_core.u_register_file.x3out;

always @(posedge clk) begin
//    $display("%s, %2d",{"result, ", opcode}, result);
    if(U_top_zedboard.u_top_core.u_instruction_decode.inst == ECALL) begin
//        $display("%s, %2d",{"result, ", `INST_ROM_FILE_NAME}, result);
        if(result != 32'd1) begin
            $display("riscv-tests NG (%h)",result);
            $stop;
        end
        $finish;

    end
end

endmodule
