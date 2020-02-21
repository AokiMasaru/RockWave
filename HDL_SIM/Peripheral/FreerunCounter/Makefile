######################################################################
# Project: hdmi
# File Created: 2019/11/19 22:33
# Author: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
######
# Last Modified: 2020/02/20 21:57
# Modified By: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
######
# Copyright 2018 - 2019  Project hdmi
######################################################################
# Description:
# hdmiモジュールテスト
######################################################################


##テストする対象に合わせてコメント/アンコメントを切り替える
testbench = freerun_counter_tb
#testbench = hdmi_tb

SRCDIR = ../../../HDL_SRC/Peripheral/FreerunCounter
SRCDIR_CORE = ../../../HDL_SRC/CORE/

TESTDIR = .

allVerilogFiles := $(foreach dir, $(SRCDIR), $(wildcard $(dir)/*.v))

all: iverilog wave

iverilog:
	iverilog -o $(testbench).test -I $(SRCDIR_CORE) $(testbench).v $(allVerilogFiles)
	vvp $(testbench).test
	
wave:
	gtkwave $(testbench).vcd $(testbench).test.gtkw -a $(testbench).test.gtkw 
