/*
 * *****************************************************************
 * File: ram_tb.v
 * Category: MemoryAccess
 * File Created: 2018/12/31 05:05
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2023/10/22 12:21
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
 * 2023/10/22	Masaru Aoki	32bitメモリに1Byte単位でアクセスする
 * 2019/01/04	Masaru Aoki	Byte / HalfWord / Wordアクセスをテスト
 * 2018/12/31	Masaru Aoki	First Version
 * *****************************************************************
 */

module ram_tb;

`include "core_general.vh"

reg clk;
reg rst_n;
reg [3:0] we;
reg [AWIDTH-1:0] addr;
reg [DWIDTH-1:0] qin;
wire [DWIDTH-1:0] qout;
integer i;

///////////////////////////////////////////////////////////////////
// インスタンス
ram test(
    .clk(clk), .rst_n(rst_n),
    .addr(addr),
    .qin(qin),
    .we(we),
    .qout(qout)
);

///////////////////////////////////////////////////////////////////
// Clock
initial
    clk = 0;
always begin
    #5 clk = ~clk;
end

///////////////////////////////////////////////////////////////////
// Sim
initial begin
    $dumpfile("ram_tb.vcd");
    $dumpvars(0,ram_tb);
    $monitor("%t: addr=%h we=%b qin=%h qout=%h",$time,addr,we,qin,qout,test.U_ram.RAM[0]);

    rst_n = 0;
    addr = 0;
    we = 0;
    qin = 0;
    @(posedge clk)
    rst_n = 1;

    // Word Write & Read
    $display("Word Write & Read");
    for(i = 0;i<=4095;i=i+4) begin
        addr = i;
        qin = ((i&32'h00FF)<<24)+((i&32'h00FF)<<16)+((i&32'h00FF)<<8)+(i&32'h00FF);
        we = 4'b1111; // Wordアクセスで書き込み
        @(posedge clk);
        @(posedge clk);
        we = 4'b0000;
        @(posedge clk);
    end
    for(i = 0;i<=4095;i=i+4) begin
        addr = i;
        @(posedge clk)
        @(posedge clk)
        assert_eq(qout,((i&32'h00FF)<<24)+((i&32'h00FF)<<16)+((i&32'h00FF)<<8)+(i&32'h00FF),"Word Write&Read");
    end

    // HalfWord Write & Read 1st&2nd
    $display("HalfWord Write & Read");
    for(i = 0;i<4095;i=i+2) begin
        addr = i;
        qin = i;
        we = 4'b0011; // HalfWordアクセスで書き込み
        @(posedge clk);
        @(posedge clk);
        we = 4'b0000;
        @(posedge clk);
    end
    for(i = 0;i<4095;i=i+2) begin
        addr = i;
        @(posedge clk)
        @(posedge clk)
        assert_eq(qout&32'h00FF,i&32'h00FF,"HalfWord Write&Read");
    end

    // HalfWord Write & Read 3rd&4th
    $display("HalfWord Write & Read 3rd&4th");
    for(i = 0;i<4095;i=i+2) begin
        addr = i;
        qin = i;
        we = 4'b1100; // HalfWordアクセスで書き込み
        @(posedge clk);
        @(posedge clk);
        we = 4'b0000;
        @(posedge clk);
    end
    for(i = 0;i<4095;i=i+2) begin
        addr = i;
        @(posedge clk)
        @(posedge clk)
        assert_eq(qout&32'hFF00,i&32'hFF00,"HalfWord Write&Read");
    end

    // Byte Write & Read 1st
    $display("Byte Write & Read");
    for(i = 0;i<4096;i=i+1) begin
        addr = i;
        qin = i;
        we = 4'b0001; // Byteアクセスで書き込み
        @(posedge clk);
        @(posedge clk);
        we = 4'b0000;
        @(posedge clk);
    end
    for(i = 0;i<4096;i=i+1) begin
        addr = i;
        @(posedge clk)
        @(posedge clk)
        assert_eq(qout&32'h000F,i&32'h000F,"Byte Write&Read");
    end


    // Byte Write & Read 2st
    $display("Byte Write & Read 2nd");
    for(i = 0;i<4096;i=i+1) begin
        addr = i;
        qin = i<<8;
        we = 4'b0010; // Byteアクセスで書き込み
        @(posedge clk);
        @(posedge clk);
        we = 4'b0000;
        @(posedge clk);
    end
    for(i = 0;i<4096;i=i+1) begin
        addr = i;
        @(posedge clk)
        @(posedge clk)
        assert_eq(qout&32'h00F0,i&32'h00F0,"Byte Write&Read");
    end

    $finish;
end

task assert_eq;
    input [XLEN-1:0] a;
    input [XLEN-1:0] b;
    input [32:0][7:0] msg;
    begin
        if(a == b) begin
        end
        else begin
            $display("Assert NG (%h,%h):%s",a,b,msg);
            $finish;
        end
    end
endtask


endmodule
