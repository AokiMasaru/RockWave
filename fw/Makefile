######################################################################
# Project: RockWave
# File Created: 2019/02/17 07:27
# Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
######
# Last Modified: 2020/02/17 22:07
# Modified By: kidtak51 ( 45393331+kidtak51@users.noreply.github.com )
######
# Copyright 2018 - 2019  Project RockWave
######################################################################
# Description:
# 
######################################################################
target = night

all:
	riscv32-unknown-elf-gcc -march=rv32i -mabi=ilp32 -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -O0 -c $(target).c -o $(target).o
	riscv32-unknown-elf-gcc -march=rv32i -mabi=ilp32 -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -O0 -c start.s -o start.o
	riscv32-unknown-elf-gcc -T link.ld -march=rv32i -mabi=ilp32 -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -o $(target) start.o $(target).o
	riscv32-unknown-elf-objcopy -O binary $(target) $(target).bin
	riscv32-unknown-elf-objdump --disassemble-all --disassemble-zeroes --section=.text --section=.text.startup --section=.text.init --section=.data $(target) > night.dump
	hexdump -v -e '1/4 "%08x" "\n"' $(target).bin > $(target).hex
	echo "memory_initialization_radix=16;\nmemory_initialization_vector=" > $(target).coe;hexdump -v -e '1/4 "%08x" ",\n"' $(target).bin >> $(target).coe ; echo "00000000" >> $(target).coe;
	cp $(target).coe synth.coe
