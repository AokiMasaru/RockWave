// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2 (lin64) Build 4029153 Fri Oct 13 20:13:54 MDT 2023
// Date        : Thu Nov  9 04:58:44 2023
// Host        : H370HD3 running 64-bit Ubuntu 22.04.3 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/aokim/Company/RISCV/RockWave/SYNTH/Zedboard/Zedboard.gen/sources_1/ip/vram_1/vram_stub.v
// Design      : vram
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg484-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_7,Vivado 2023.2" *)
module vram(clka, ena, wea, addra, dina, douta, clkb, web, addrb, dinb, 
  doutb)
/* synthesis syn_black_box black_box_pad_pin="ena,wea[0:0],addra[18:0],dina[11:0],douta[11:0],web[0:0],addrb[18:0],dinb[11:0],doutb[11:0]" */
/* synthesis syn_force_seq_prim="clka" */
/* synthesis syn_force_seq_prim="clkb" */;
  input clka /* synthesis syn_isclock = 1 */;
  input ena;
  input [0:0]wea;
  input [18:0]addra;
  input [11:0]dina;
  output [11:0]douta;
  input clkb /* synthesis syn_isclock = 1 */;
  input [0:0]web;
  input [18:0]addrb;
  input [11:0]dinb;
  output [11:0]doutb;
endmodule
