/*
 * *****************************************************************
 * File: ram_tb.v
 * Category: localbus
 * File Created: 2023/10/24 04:00
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2023/10/24 04:19
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
 * 2023/10/24	Masaru Aoki	First Version
 * *****************************************************************
 */
task ram_tb;
begin
    //////////////////////////////////////
    // Word Access
    $display("RAM:Write Word");
    cpu_wr_w(32'h9000_0000,32'h5555_5555);
    @(posedge clk)
    cpu_rd(32'h9000_0000,data);
    @(posedge clk)
    assert_eq(data,32'h5555_5555);

    cpu_wr_w(32'h9000_0000,32'hAAAA_AAAA);
    @(posedge clk)
    cpu_rd(32'h9000_0000,data);
    @(posedge clk)
    assert_eq(data,32'hAAAA_AAAA);

    cpu_wr_w(32'h9000_0000,32'hFFFF_FFFF);
    @(posedge clk)
    cpu_rd(32'h9000_0000,data);
    @(posedge clk)
    assert_eq(data,32'hFFFF_FFFFF);

    //////////////////////////////////////
    // Byte Access
    $display("RAM:Write Byte");
    cpu_wr_w(32'h9000_0001,32'h0000_0000);  // 0 clear
    cpu_wr_b(32'h9000_0004,32'h5555_5555);
    @(posedge clk)
    cpu_rd(32'h9000_0004,data);
    @(posedge clk)
    assert_eq(data,32'h0000_0055);

    cpu_wr_b(32'h9000_0005,32'hAAAA_AAAA);
    @(posedge clk)
    cpu_rd(32'h9000_0004,data);
    @(posedge clk)
    assert_eq(data,32'h0000_AA55);

    cpu_wr_b(32'h9000_0006,32'hFFFF_FFFF);
    @(posedge clk)
    cpu_rd(32'h9000_0004,data);
    @(posedge clk)
    assert_eq(data,32'h00FF_AA55);

    cpu_wr_b(32'h9000_0007,32'hDEAD_BEEF);
    @(posedge clk)
    cpu_rd(32'h9000_0004,data);
    @(posedge clk)
    assert_eq(data,32'hDEFF_AA55);



end
endtask
