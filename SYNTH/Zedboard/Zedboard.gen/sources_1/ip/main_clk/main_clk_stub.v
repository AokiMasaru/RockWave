// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2 (lin64) Build 4029153 Fri Oct 13 20:13:54 MDT 2023
// Date        : Sat Nov 11 09:39:10 2023
// Host        : H370HD3 running 64-bit Ubuntu 22.04.3 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/aokim/Company/RISCV/RockWave/SYNTH/Zedboard/Zedboard.gen/sources_1/ip/main_clk/main_clk_stub.v
// Design      : main_clk
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg484-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module main_clk(clk, pixelclk, clk_in)
/* synthesis syn_black_box black_box_pad_pin="clk_in" */
/* synthesis syn_force_seq_prim="clk" */
/* synthesis syn_force_seq_prim="pixelclk" */;
  output clk /* synthesis syn_isclock = 1 */;
  output pixelclk /* synthesis syn_isclock = 1 */;
  input clk_in;
endmodule
