/*
 * *****************************************************************
 * File: hdmi_vram.v
 * Category: hdmi
 * File Created: 2019/10/31 21:29
 * Author: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
 * *****
 * Last Modified: 2019/11/18 23:22
 * Modified By: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
 * *****
 * Copyright 2018 - 2019  Project RockWave
 * *****************************************************************
 * Description:
 *   
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/10/31	kidtak51	First Version
 * *****************************************************************
 */

module hdmi_vram(
    input               clka,
    input               ena,
    input       [ 0:0]  wea,
    input       [19:0]  addra,
    input       [7:0]  dina,
    output reg  [7:0]  douta,
    input               clkb,
    input               enb,
    input       [19:0]  addrb,
    output reg  [7:0]  doutb
);

/* デュアルポートRAM - 同一ポート内ではライト前の値がリードされる */
reg[7:0] ram[0:2**20-1];
always @(posedge clka)
begin
        if (ena)
        begin
            if(wea)
                ram[addra] <= dina;
            douta <= ram[addra];
        end
end

always @(posedge clkb)
begin
    if(enb)
    begin
        doutb <= ram[addrb];
    end
end
endmodule
