######################################################################
# Project: localbus
# File Created: 2023/10/23 04:29
# Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
######
# Last Modified: 2023/10/25 05:19
# Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
######
# Copyright 2018 - 2023  Project localbus
######################################################################
# Description:
# 
######################################################################

testbench = localbus_tb

SRCDIR = ../../../HDL_SRC/
INCDIR = ../../../HDL_SRC/CORE/

SRCDIRS := $(shell find $(SRCDIR) -type d)

allVerilogFiles := $(foreach dir, $(SRCDIRS), $(wildcard $(dir)/*.v))#


all: iverilog wave

iverilog:
	iverilog -o $(testbench).test -I $(INCDIR) $(testbench).v $(allVerilogFiles)
	vvp -N $(testbench).test
	rm $(testbench).test

wave:
	gtkwave $(testbench).vcd $(testbench).test.gtkw -a $(testbench).test.gtkw 
