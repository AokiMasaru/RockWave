/*
 * *****************************************************************
 * File: hdmi_vram.v
 * Category: hdmi
 * File Created: 2019/10/31 21:29
 * Author: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
 * *****
 * Last Modified: 2019/12/12 07:07
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
 * 2019/12/12   kidtak51    XilinxのblockramのIOに合わせた。
 * 2019/12/12   kidtak51    blockramの容量削減のためにaddra,addrbのbit幅を減らした。
 * *****************************************************************
 */

module hdmi_vram(
    input               clka,
    input               ena,
    input       [ 0:0]  wea,
    input       [15:0]  addra,
    input       [7:0]  dina,
    output reg  [7:0]  douta,
    input               clkb,
    input               web,
    input               enb,
    input       [15:0]  addrb,
    input       [7:0]  dinb,
    output reg  [7:0]  doutb
);

/* デュアルポートRAM - 同一ポート内ではライト前の値がリードされる */
reg[7:0] ram[0:2**15-1];
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
        if(web)
            ram[addrb] <= dinb;
        doutb <= ram[addrb];
    end
end
endmodule
