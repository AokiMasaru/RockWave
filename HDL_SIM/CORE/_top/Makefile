######################################################################
# Project: top_core
# File Created: 2018/12/19 12:12
# Author: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
######
# Last Modified: 2020/01/06 21:36
# Modified By: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
######
# Copyright 2018 - 2018  Project top_core
######################################################################
# Description:
# 
######################################################################

testbench = top_zynqberry_tb

SRCDIR = ../../../HDL_SRC/
INCDIR = ../../../HDL_SRC/CORE/

SRCDIRS := $(shell find $(SRCDIR) -type d)

allVerilogFiles := $(foreach dir, $(SRCDIRS), $(wildcard $(dir)/*.v))
TOPMODULE = ../../../SYNTH/zynqberry/top_zynqberry.v

all: iverilog wave

iverilog:
	iverilog -o $(testbench).test -I $(INCDIR) $(testbench).v ../../../HDL_SIM/Peripheral/hdmi/rgb2dvi_for_test.v $(allVerilogFiles) $(TOPMODULE)
	vvp $(testbench).test

wave:
	gtkwave *.vcd $(testbench).test.gtkw -a $(testbench).test.gtkw
