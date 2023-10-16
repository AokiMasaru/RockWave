module top_zedboard(
    input clk,

    input [12:0]   gpio_pin_in,
    output [7:0]   gpio_pin_out,

    output         hsync,
    output         vsync,
    output [3:0]   rdata,
    output [3:0]   gdata,
    output [3:0]   bdata
);
`include "core_general.vh"

    //instruction memory
    wire [AWIDTH-1:0] inst_addr;
    wire [XLEN-1:0] inst_data;

    //data memory
    wire [XLEN-1:0] data_mem_out;
    wire [XLEN-1:0] data_mem_addr;
    wire [XLEN-1:0] data_mem_wdata;
    wire [2:0] data_mem_we;

`ifdef __ICARUS__
initial begin
    //$readmemh(`INST_ROM_FILE_NAME, u_inst_memory.mem);
    $readmemh("../../../fw/martos.rom.hex", u_inst_memory.U_ram.ram);
    $readmemh("../../../fw/martos.ram.hex", U_localbus.U_data_memory.U_ram.RAM);
end
`endif

//instant reset wave generate
reg[7:0] cnt = 8'd0;
reg rst_n = 1'b0;
always @(posedge clk) begin
	if ( cnt == 8'hFF ) begin
		cnt <= cnt;
		rst_n <= 1'b1;
	end
	else begin
		cnt <= cnt + 1'b1;
		rst_n <= 1'b0;
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

localbus U_localbus(
    .clk(clk),
    .rst_n(rst_n),
    .addr(data_mem_addr),
    .qin(data_mem_wdata),
    .we(data_mem_we),
    .qout(data_mem_out),

    .gpio_pin_in(gpio_pin_in),
    .gpio_pin_out(gpio_pin_out),
    .hsync(hsync),
    .vsync(vsync),
    .rdata(rdata),
    .gdata(gdata),
    .bdata(bdata)
);

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

endmodule
