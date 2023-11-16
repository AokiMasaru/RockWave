#!/usr/bin/env bash
# ****************************************************************************
# Vivado (TM) v2023.2 (64-bit)
#
# Filename    : elaborate.sh
# Simulator   : AMD Vivado Simulator
# Description : Script for elaborating the compiled design
#
# Generated by Vivado on Fri Nov 17 05:24:02 JST 2023
# SW Build 4029153 on Fri Oct 13 20:13:54 MDT 2023
#
# Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
# Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
#
# usage: elaborate.sh
#
# ****************************************************************************
set -Eeuo pipefail
# elaborate design
echo "xelab --incr --debug typical --relax --mt 8 -L xil_defaultlib -L blk_mem_gen_v8_4_7 -L unisims_ver -L unimacro_ver -L secureip -L xpm --snapshot top_zedboard_tb_behav xil_defaultlib.top_zedboard_tb xil_defaultlib.glbl -log elaborate.log"
xelab --incr --debug typical --relax --mt 8 -L xil_defaultlib -L blk_mem_gen_v8_4_7 -L unisims_ver -L unimacro_ver -L secureip -L xpm --snapshot top_zedboard_tb_behav xil_defaultlib.top_zedboard_tb xil_defaultlib.glbl -log elaborate.log

