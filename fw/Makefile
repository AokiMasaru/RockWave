######################################################################
# Project: RockWave
# File Created: 2019/02/17 07:27
# Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
######
# Last Modified: 2023/11/12 15:11
# Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
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


# -S デバッグ情報のストリップ
	riscv32-unknown-elf-objcopy -S --only-section=.text.init --only-section=.text   -O binary $(target) $(target).rom.bin
	riscv32-unknown-elf-objcopy -S --remove-section=.text -O binary $(target) $(target).ram.bin
	riscv32-unknown-elf-objdump --disassemble-all --disassemble-zeroes --section=.text --section=.text.startup --section=.text.init --section=.data $(target) > $(target).dump
	hexdump -v -e '1/4 "%08x" "\n"' $(target).rom.bin > $(target).rom.hex
	hexdump -v -e '1/4 "%08x" "\n"' $(target).ram.bin > $(target).ram.hex
	echo "memory_initialization_radix=16;\nmemory_initialization_vector=" > $(target).rom.coe;hexdump -v -e '1/4 "%08x" ",\n"' $(target).rom.bin >> $(target).rom.coe ; echo "00000000" >> $(target).rom.coe;
	echo "memory_initialization_radix=16;\nmemory_initialization_vector=" > $(target).ram.coe;hexdump -v -e '1/4 "%08x" ",\n"' $(target).ram.bin >> $(target).ram.coe ; echo "00000000" >> $(target).ram.coe;
	cp $(target).rom.coe synth.coe
	cp $(target).rom.hex synth.hex

clean:
	rm -rf *.o *.bin *.dump *.hex *.coe $(target)
