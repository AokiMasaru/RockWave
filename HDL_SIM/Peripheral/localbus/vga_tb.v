/*
 * *****************************************************************
 * File: vga_tb.v
 * Category: localbus
 * File Created: 2023/10/23 04:59
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2023/10/23 05:01
 * Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Copyright 2018 - 2023  Project RockWave
 * *****************************************************************
 * Description:
 *   
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2023/10/23	Masaru Aoki	First Version
 * *****************************************************************
 */


task vga_tb;
begin
    //////////////////////////////////////
    // vga_en
    cpu_wr_b(32'h6000_0000,8'h01);
    @(posedge clk)
    cpu_rd(32'h6000_0000,data);
    @(posedge clk)
    assert_eq(data,32'h0000_0001);
    assert_eq(U_localbus.U_top_vgacontroller.vga_en,1);

    //////////////////////////////////////
    // vblank / hblank 
    $display("vblank / hblank 0");
    @(negedge U_localbus.U_top_vgacontroller.vblank);
    @(negedge U_localbus.U_top_vgacontroller.hblank);
    @(posedge clk)
    @(posedge clk)
    cpu_rd(32'h6000_0004,data);
    @(posedge clk)
    assert_eq(data,32'h0000_0000);
    addr = 32'h0000_0000;

    $display("vblank / hblank 3");
    @(posedge U_localbus.U_top_vgacontroller.vblank);
    @(posedge U_localbus.U_top_vgacontroller.hblank);
    @(posedge clk)
    @(posedge clk)
    cpu_rd(32'h6000_0004,data);
    @(posedge clk)
    assert_eq(data,32'h0000_0003);
    addr = 32'h0000_0000;

    $display("vblank / hblank 2");
    @(negedge U_localbus.U_top_vgacontroller.vblank);
    @(posedge U_localbus.U_top_vgacontroller.hblank);
    @(posedge clk)
    @(posedge clk)
    cpu_rd(32'h6000_0004,data);
    @(posedge clk)
    assert_eq(data,32'h0000_0002);
    addr = 32'h0000_0000;

    $display("vblank / hblank 1");
    @(posedge U_localbus.U_top_vgacontroller.vblank);
    @(negedge U_localbus.U_top_vgacontroller.hblank);
    @(posedge clk)
    @(posedge clk)
    cpu_rd(32'h6000_0004,data);
    @(posedge clk)
    assert_eq(data,32'h0000_0001);
    addr = 32'h0000_0000;
end
endtask
