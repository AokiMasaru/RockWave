######################################################################
# Project: TIMER
# File Created: 2023/10/26 04:39
# Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
######
# Last Modified: 2023/11/04 09:15
# Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
######
# Copyright 2018 - 2023  Project TIMER
######################################################################
# Description:
# 
######################################################################
target = martos
testbench = ../zedboard_tb


# start.oを一番はじめにリンクすること　.textセクションの先頭に置きたい
OBJS = 	build/start.o   \
		build/timer_handler.o \
		build/trap_vector.o \
		build/systimer.o \
		build/$(target).o

# Verilog 設定
SRCDIR = ../../../HDL_SRC/
INCDIR = ../../../HDL_SRC/CORE/
BOARDDIR = ../../../SYNTH/Zedboard/

SRCDIRS := $(shell find $(SRCDIR) -type d)

allVerilogFiles := $(foreach dir, $(SRCDIRS), $(wildcard $(dir)/*.v))#
DUT = $(BOARDDIR)top_zedboard.v

all: iverilog

iverilog:
	iverilog -o $(testbench).test -I $(INCDIR) \
		-D TARGET=\"$(target)\" \
		-D INST_ROM_FILE_NAME=\"$(target).rom.hex\" \
		-D INST_RAM_FILE_NAME=\"$(basename $(target)).ram.hex\" \
		$(testbench).v $(DUT) $(allVerilogFiles)
	vvp -N $(testbench).test
	rm $(testbench).test

wave:
	gtkwave $(target).vcd $(target).test.gtkw -a $(target).test.gtkw 

clean:
	rm -rf *.coe *.hex *.bin $(OBJS) $(target) *.vcd
