######################################################################
# Project: hdmi
# File Created: 2019/11/19 22:33
# Author: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
######
# Last Modified: 2019/11/19 22:33
# Modified By: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
######
# Copyright 2018 - 2019  Project hdmi
######################################################################
# Description:
# hdmiモジュールテスト
######################################################################


##テストする対象に合わせてコメント/アンコメントを切り替える
testbench = top_hdmicontroller_tb
#testbench = hdmi_tb

SRCDIR = ../../../HDL_SRC/Peripheral/hdmi
SRCDIR_CORE = ../../../HDL_SRC/CORE/

TESTDIR = .

allVerilogFiles := $(foreach dir, $(SRCDIR), $(wildcard $(dir)/*.v))

all: iverilog wave

iverilog:
	iverilog -o $(testbench).test -I $(SRCDIR_CORE) $(testbench).v rgb2dvi_for_test.v $(allVerilogFiles)
	vvp $(testbench).test
	
wave:
	gtkwave $(testbench).vcd $(testbench).test.gtkw -a $(testbench).test.gtkw 
