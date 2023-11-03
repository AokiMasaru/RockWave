######################################################################
# Project: ZedBoard/riscv-tests
# File Created: 2018/12/19 12:12
# Author: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
######
# Last Modified: 2023/11/04 08:29
# Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
######
# Copyright 2018 - 2018  Project top_core
######################################################################
# Description:
#	ZedBoardでriscv-testsを実行する
#	メモリ関連のみ
######################################################################

testbench = zedboard_tb.v
target = zedboard_tb

SRCDIR = ../../../HDL_SRC/
INCDIR = ../../../HDL_SRC/CORE/
BOARDDIR = ../../../SYNTH/Zedboard/
DUT = $(BOARDDIR)top_zedboard.v

SRCDIRS := $(shell find $(SRCDIR) -type d)

allVerilogFiles := $(foreach dir, $(SRCDIRS), $(wildcard $(dir)/*.v))
hexFiles := $(wildcard *[a-z].hex)#
hexRamFiles := $(wildcard *[a-z].RAM.hex)#
hexFiles_m := $(wildcard rv32ui-p-lb.hex)#

define F
	iverilog -o $(1).test -I $(INCDIR) -I $(BOARDDIR) \
		-D TARGET=\"$(1)\" \
		-D INST_ROM_FILE_NAME=\"$(1)\" \
		-D INST_RAM_FILE_NAME=\"$(basename $(1)).RAM.hex\" \
		../$(testbench) $(DUT) $(allVerilogFiles)

	vvp -N $(1).test>>allResult_tmp.txt

endef

all:
	$(foreach x,$(hexFiles),$(call F,$(x)))
	grep result allResult_tmp.txt>allResult.txt
	rm allResult_tmp.txt

.hex.vcd:
	$(call F,$0)

rv32ui-p-lb: rv32ui-p-lb.hex.vcd
	$(call F,$(hexFiles_m))
	grep result allResult_tmp.txt>allResult.txt
	rm allResult_tmp.txt

rv32ui-p-lw: rv32ui-p-lw.hex.vcd
	$(call F,$(hexFiles_m))
	grep result allResult_tmp.txt>allResult.txt
	rm allResult_tmp.txt

wave:
	gtkwave rv32ui-p-lw.hex.vcd $(testbench).test.gtkw -a $(testbench).test.gtkw

clean:
	rm *.vcd *.test
