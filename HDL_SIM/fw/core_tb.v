/*
 * *****************************************************************
 * File: core_tb.v
 * Category: CORE
 * File Created: 2019/01/25 07:14
 * Author: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
 * *****
 * Last Modified: 2023/10/28 13:08
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
 * 2023/10/28	Masaru Aoki RAMを別HEXファイルとしてreadmemhする	
 * 2019/01/25	kidtak51	First Version
 * *****************************************************************
 */
module core_tb(
);

`include "core_general.vh"

//instruction memory
wire [AWIDTH-1:0] inst_addr;//instruction memoryのアドレスを接続する
wire [XLEN-1:0] inst_data;//instruction memoryのデータを接続する

//data memory
wire [XLEN-1:0] data_mem_out;//データメモリからのデータ出力を接続する
wire [AWIDTH-1:0] data_mem_addr;//データメモリへのアドレスを接続する
wire [XLEN-1:0] data_mem_wdata;//データメモリへのデータ入力を接続する
wire [3:0] data_mem_we;//データメモリへのWriteEnable信号を接続する
reg rst_n;
reg clk;
integer i;//forループ用


//gtk wave 波形表示用
wire [XLEN-1:0] pc = u_top_core.u_top_fetch.program_counter;
wire [XLEN-1:0] x01_ra = u_top_core.u_register_file.x1out;
wire [XLEN-1:0] x02_sp = u_top_core.u_register_file.x2out;
wire [XLEN-1:0] x03_gp = u_top_core.u_register_file.x3out;
wire [XLEN-1:0] x04_tp = u_top_core.u_register_file.x4out;
wire [XLEN-1:0] x05_t0 = u_top_core.u_register_file.x5out;
wire [XLEN-1:0] x06_t1 = u_top_core.u_register_file.x6out;
wire [XLEN-1:0] x07_t2 = u_top_core.u_register_file.x7out;
wire [XLEN-1:0] x08_s0_fp = u_top_core.u_register_file.x8out;
wire [XLEN-1:0] x09_s1 = u_top_core.u_register_file.x9out;
wire [XLEN-1:0] x10_a0 = u_top_core.u_register_file.x10out;
wire [XLEN-1:0] x11_a1 = u_top_core.u_register_file.x11out;
wire [XLEN-1:0] x12_a2 = u_top_core.u_register_file.x12out;
wire [XLEN-1:0] x13_a3 = u_top_core.u_register_file.x13out;
wire [XLEN-1:0] x14_a4 = u_top_core.u_register_file.x14out;
wire [XLEN-1:0] x15_a5 = u_top_core.u_register_file.x15out;
wire [XLEN-1:0] x16_a6 = u_top_core.u_register_file.x16out;
wire [XLEN-1:0] x17_a7 = u_top_core.u_register_file.x17out;
wire [XLEN-1:0] x18_s2 = u_top_core.u_register_file.x18out;
wire [XLEN-1:0] x19_s3 = u_top_core.u_register_file.x19out;
wire [XLEN-1:0] x20_s4 = u_top_core.u_register_file.x20out;
wire [XLEN-1:0] x21_s5 = u_top_core.u_register_file.x21out;
wire [XLEN-1:0] x22_s6 = u_top_core.u_register_file.x22out;
wire [XLEN-1:0] x23_s7 = u_top_core.u_register_file.x23out;
wire [XLEN-1:0] x24_s8 = u_top_core.u_register_file.x24out;
wire [XLEN-1:0] x25_s9 = u_top_core.u_register_file.x25out;
wire [XLEN-1:0] x26_s10 = u_top_core.u_register_file.x26out;
wire [XLEN-1:0] x27_s11 = u_top_core.u_register_file.x27out;
wire [XLEN-1:0] x28_t3 = u_top_core.u_register_file.x28out;
wire [XLEN-1:0] x29_t4 = u_top_core.u_register_file.x29out;
wire [XLEN-1:0] x30_t5 = u_top_core.u_register_file.x30out;
wire [XLEN-1:0] x31_t6 = u_top_core.u_register_file.x31out;

//gtk wave 波形表示用 CSR
wire [XLEN-1:0] mstatus     = u_top_core.u_reg_csr.null_reg300_dataout;
wire [XLEN-1:0] mie         = u_top_core.u_reg_csr.null_reg304_dataout;
wire [XLEN-1:0] mtvec       = u_top_core.u_reg_csr.null_reg305_dataout;
wire [XLEN-1:0] mscratch    = u_top_core.u_reg_csr.null_reg340_dataout;
wire [XLEN-1:0] mepc        = u_top_core.u_reg_csr.null_reg341_dataout;
wire [XLEN-1:0] mcause      = u_top_core.u_reg_csr.null_reg342_dataout;
wire [XLEN-1:0] mtval       = u_top_core.u_reg_csr.null_reg343_dataout;
wire [XLEN-1:0] mip         = u_top_core.u_reg_csr.null_reg344_dataout;

// gtkwave 命令表示用
wire [9:0] op = {u_top_core.u_instruction_decode.inst[14:12],u_top_core.u_instruction_decode.inst[6:0]};
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
    // read hex file
    $readmemh(`INST_ROM_FILE_NAME, u_inst_memory.U_ram.ram);
    $dumpfile({`INST_ROM_FILE_NAME, ".vcd"});
    $dumpvars(0,core_tb);
    
    //Start up seeqence
    //romからramにコピーする
    rst_n = 0;

    $readmemh(`INST_RAM_FILE_NAME, u_data_memory.U_ram.RAM);

    rst_n = 0;

    ////Core simulation start
    @(posedge clk) #1;
    #10
    rst_n = 1;
    #50000

    //time out error
    $display("%s, %2d",{"result, ", `INST_ROM_FILE_NAME}, -1);
    $finish;
end

localparam ECALL = 32'h73;

always @(posedge clk) begin
    if(u_top_core.u_instruction_decode.inst == ECALL) begin
        $display("%s, %2d",{"result, ", `INST_ROM_FILE_NAME}, u_top_core.u_top_core.u_register_file.x3out);
        //$exit(u_top_core.u_top_core.u_register_file.x3out);
        $finish;

    end
end

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
    .clk(clk),
    .rst_n(rst_n),
    .addr(inst_addr),
    .qout(inst_data)
);

ram u_data_memory(
    .clk(clk),
    .rst_n(rst_n),
    .addr(data_mem_addr),
    .qin(data_mem_wdata),
    .we(data_mem_we),
    .qout(data_mem_out)
);

endmodule // core_tb
