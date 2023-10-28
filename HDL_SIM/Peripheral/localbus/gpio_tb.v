/*
 * *****************************************************************
 * File: gpio_tb.v
 * Category: localbus
 * File Created: 2023/10/23 05:02
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2023/10/23 05:29
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
task gpio_tb;
begin
    //////////////////////////////////////
    // dflt_st
    $display("GPIO:dflt_st");
    cpu_wr_b(32'h7000_0000,8'h55);
    @(posedge clk)
    cpu_rd(32'h7000_0000,data);
    @(posedge clk)
    assert_eq(data,32'h0000_0055);

    cpu_wr_b(32'h7000_0000,8'hAA);
    @(posedge clk)
    cpu_rd(32'h7000_0000,data);
    @(posedge clk)
    assert_eq(data,32'h0000_00AA);

    cpu_wr_b(32'h7000_0000,8'h00);
    @(posedge clk)
    cpu_rd(32'h7000_0000,data);
    @(posedge clk)
    assert_eq(data,32'h0000_0000);

    //////////////////////////////////////
    // refclk_st
    $display("GPIO:refclk_st");
    cpu_wr_b(32'h7000_0004,8'h55);
    @(posedge clk)
    cpu_rd(32'h7000_0004,data);
    @(posedge clk)
    assert_eq(data,32'h0000_0055);

    cpu_wr_b(32'h7000_0004,8'hAA);
    @(posedge clk)
    cpu_rd(32'h7000_0004,data);
    @(posedge clk)
    assert_eq(data,32'h0000_00AA);

    cpu_wr_b(32'h7000_0004,8'h01);
    @(posedge clk)
    cpu_rd(32'h7000_0004,data);
    @(posedge clk)
    assert_eq(data,32'h0000_0001);

    //////////////////////////////////////
    // デジタルフィルタの初期化
    rst_n=0;
    @(posedge clk)
    @(posedge clk)
    rst_n = 1;

    //////////////////////////////////////
    // input
    $display("GPIO:INPUT");
    gpio_pin_in = 16'hAAAA;
    @(posedge clk)
    @(posedge clk)
    @(posedge clk)
    @(posedge clk)
    @(posedge clk)
    cpu_rd(32'h7000_0010,data);
    assert_eq(data,32'h0000_0AAA);

    gpio_pin_in = 16'h5555;
    @(posedge clk)
    @(posedge clk)
    @(posedge clk)
    @(posedge clk)
    @(posedge clk)
    @(posedge clk)
    cpu_rd(32'h7000_0010,data);
    assert_eq(data,32'h0000_1555);


end
endtask
