/*
 * *****************************************************************
 * File: freerun_counter.v
 * Category: FreerunCounter
 * File Created: 2020/02/18 20:54
 * Author: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
 * *****
 * Last Modified: 2020/02/20 23:16
 * Modified By: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
 * *****
 * Copyright 2018 - 2020  Project RockWave
 * *****************************************************************
 * Description:
 *   フリーランカウンタ。1us=1、32bit＝約4,294秒で一周する
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2020/02/18	kidtak51	First Version
 * *****************************************************************
 */
module freerun_counter#(
    parameter MICRO_SEC_PER_CLK_PERIOD = 297,//clk=74.25MHz, 297=clk*DIVIDE
    parameter DIVIDE = 4
)
(
    input               clk,        // Global Clock
    input               rst_n,      // Global Reset

    // Local BUS
    input               sel,        // Select this Memory Block
    input [AWIDTH-1:0]  addr,       // Address
    output [XLEN-1:0]   rdata       // Read Data
);
    `include "core_general.vh"

    reg [31:0] internal_counter;
    reg [31:0] counter_1us;
    always @(posedge clk, negedge rst_n) begin
        if (rst_n == 1'b0) begin
            internal_counter <= 32'd0;
            counter_1us <= 32'd0;
        end
        else if (internal_counter >= MICRO_SEC_PER_CLK_PERIOD) begin
            internal_counter <= 32'd0;
            counter_1us <= counter_1us + DIVIDE;
        end
        else begin
            internal_counter <= internal_counter + 1'd1;
        end
    end
    assign rdata = sel ? {{(XLEN-32){1'b0}}, counter_1us} : {(XLEN){1'b0}};


endmodule
