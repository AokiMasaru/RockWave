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
    wire [3:0]      data_mem_we;

    // localbus
    wire int_timer;

`ifdef __ICARUS__
initial begin
    //$readmemh(`INST_ROM_FILE_NAME, u_inst_memory.mem);
`ifdef INST_ROM_FILE_NAME
    $readmemh(`INST_ROM_FILE_NAME, u_inst_memory.U_ram.ram);
`else
    $readmemh("../../../fw/martos.rom.hex", u_inst_memory.U_ram.ram);
`endif
`ifdef INST_RAM_FILE_NAME
    $readmemh(`INST_RAM_FILE_NAME, U_localbus.U_data_memory.U_ram.RAM);
`else
    $readmemh("../../../fw/martos.ram.hex", U_localbus.U_data_memory.U_ram.RAM);
`endif

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
    .data_mem_we    (data_mem_we    ),

    .int_timer      (int_timer)
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
    .bdata(bdata),

    .int_timer(int_timer)
);


endmodule
