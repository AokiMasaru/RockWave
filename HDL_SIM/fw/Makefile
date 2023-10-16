######################################################################
# Project: core_tb
# File Created: 2018/12/19 12:12
# Author: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
######
# Last Modified: 2023/10/15 16:42
# Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
######
# Copyright 2018 - 2018  Project top_core
######################################################################
# Description:
# 
######################################################################

testbench = core_tb.v

SRCDIR = ../../HDL_SRC/
INCDIR = ../../HDL_SRC/CORE/

SRCDIRS := $(shell find $(SRCDIR) -type d)

allVerilogFiles := $(foreach dir, $(SRCDIRS), $(wildcard $(dir)/*.v))
hexFiles := $(wildcard *.hex)#
hexFiles_m := $(wildcard rv32mi*.hex)#

all: iverilog

define F
	iverilog -o $(1).test -I $(INCDIR) -D INST_ROM_FILE_NAME=\"$(1)\" $(testbench) $(allVerilogFiles)

	vvp $(1).test>>allResult_tmp.txt

endef

iverilog:
	$(foreach x,$(hexFiles),$(call F,$(x)))
	grep result allResult_tmp.txt>allResult.txt
	rm allResult_tmp.txt

rv32mi:
	$(call F,$(hexFiles_m))
	grep result allResult_tmp.txt>allResult.txt
	rm allResult_tmp.txt

wave:
	gtkwave rv32mi-p-csr.hex.vcd $(testbench).test.gtkw -a $(testbench).test.gtkw
