######################################################################
# Project: TIMER
# File Created: 2023/10/26 04:39
# Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
######
# Last Modified: 2023/10/31 05:26
# Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
######
# Copyright 2018 - 2023  Project TIMER
######################################################################
# Description:
# 
######################################################################
target = timer_test
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




all: hex

hex:
	riscv32-unknown-elf-gcc -c -ggdb -o build/start.o ../start.s -march=rv32i_zicsr -mabi=ilp32 -fPIC -nostdlib -nostartfiles
	riscv32-unknown-elf-gcc -c -ggdb -o build/$(target).o  $(target).c -march=rv32i_zicsr -mabi=ilp32 -fPIC -nostdlib -nostartfiles
	riscv32-unknown-elf-gcc -c -ggdb -o build/timer_handler.o timer_handler.s -march=rv32i_zicsr -mabi=ilp32 -fPIC -nostdlib -nostartfiles
	riscv32-unknown-elf-gcc -c -ggdb -o build/trap_vector.o trap_vector.s -march=rv32i_zicsr -mabi=ilp32 -fPIC -nostdlib -nostartfiles
	riscv32-unknown-elf-gcc -c -ggdb -o build/systimer.o  systimer.c -march=rv32i_zicsr -mabi=ilp32 -fPIC -nostdlib -nostartfiles

	riscv32-unknown-elf-gcc -ggdb -T ../link.ld $(OBJS) -o $(target) -march=rv32i_zicsr -mabi=ilp32 -fPIC -nostdlib -nostartfiles

# -S デバッグ情報のストリップ
	riscv32-unknown-elf-objcopy -S --only-section=.text   -O binary $(target) $(target).rom.bin
	riscv32-unknown-elf-objcopy -S --remove-section=.text -O binary $(target) $(target).ram.bin
	riscv32-unknown-elf-objdump --disassemble-all --disassemble-zeroes --section=.text --section=.text.startup --section=.text.init --section=.data $(target) > $(target).dump
	hexdump -v -e '1/4 "%08x" "\n"' $(target).rom.bin > $(target).rom.hex
	hexdump -v -e '1/4 "%08x" "\n"' $(target).ram.bin > $(target).ram.hex
	echo "memory_initialization_radix=16;\nmemory_initialization_vector=" > $(target).rom.coe;hexdump -v -e '1/4 "%08x" ",\n"' $(target).rom.bin >> $(target).rom.coe ; echo "00000000" >> $(target).rom.coe;
	echo "memory_initialization_radix=16;\nmemory_initialization_vector=" > $(target).ram.coe;hexdump -v -e '1/4 "%08x" ",\n"' $(target).ram.bin >> $(target).ram.coe ; echo "00000000" >> $(target).ram.coe;
	cp $(target).rom.coe synth.rom.coe
	cp $(target).ram.coe synth.ram.coe
	cp $(target).rom.hex synth.rom.hex
	cp $(target).ram.hex synth.ram.hex

iverilog:
	iverilog -o $(testbench).test -I $(INCDIR) -D TARGET=\"$(target)\" -D INST_ROM_FILE_NAME=\"$(target).rom.hex\" -D INST_RAM_FILE_NAME=\"$(basename $(target)).ram.hex\" $(testbench).v $(DUT) $(allVerilogFiles)
	vvp -N $(testbench).test
	rm $(testbench).test

wave:
	gtkwave $(target).vcd $(target).test.gtkw -a $(target).test.gtkw 

clean:
	rm -rf *.coe *.hex *.bin $(OBJS) $(target) *.vcd
