/*
 * *****************************************************************
 * File: timer_tb.v
 * Category: localbus
 * File Created: 2023/10/24 03:39
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: 2023/10/24 04:04
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
task timer_tb;
begin
    //////////////////////////////////////
    // msip
    $display("TIMER:Write msip");
    cpu_wr_w(32'h0200_0000,32'h5555_5555);
    @(posedge clk)
    cpu_rd(32'h0200_0000,data);
    @(posedge clk)
    assert_eq(data,32'h5555_5555);

    cpu_wr_w(32'h0200_0000,32'hAAAA_AAAA);
    @(posedge clk)
    cpu_rd(32'h0200_0000,data);
    @(posedge clk)
    assert_eq(data,32'hAAAA_AAAA);

    cpu_wr_w(32'h0200_0000,32'hFFFF_FFFF);
    @(posedge clk)
    cpu_rd(32'h0200_0000,data);
    @(posedge clk)
    assert_eq(data,32'hFFFF_FFFFF);


    //////////////////////////////////////
    // Register out mtimecmpは内部64bit
    // Addr 4000 / 4004
    $display("TIMER:Write mtimecmp_l");
    cpu_wr_w(32'h0200_4000,32'hCAFE_BABE);
    @(posedge clk)
    cpu_rd(32'h0200_4000,data);
    @(posedge clk)
    assert_eq(data,32'hCAFE_BABE);

    $display("TIMER:Write mtimecmp_l");
    cpu_wr_w(32'h0200_4004,32'hDEAD_BEEF);
    @(posedge clk)
    cpu_rd(32'h0200_4004,data);
    @(posedge clk)
    assert_eq(data,32'hDEAD_BEEF);

    assert_eq(U_localbus.U_top_timer.mtimecmp,64'hDEAD_BEEF_CAFE_BABE);

    //////////////////////////////////////////////////////////////////
    // Read
    // mtimeを変更
    force U_localbus.U_top_timer.U_fnc_timer.internal_counter = 64'h0123_4567_89AB_CDEF;
    @(posedge clk)
    @(posedge clk)

    cpu_rd(32'h0200_BFF8,data);
    $display("TIMER:mtime_l:%h",data);
    assert_eq(data,32'h89AB_CDEF);

    cpu_rd(32'h0200_BFFC,data);
    $display("TIMER:mtime_h:%h",data);
    assert_eq(data,32'h0123_4567);

    release U_localbus.U_top_timer.U_fnc_timer.internal_counter;


end
endtask
