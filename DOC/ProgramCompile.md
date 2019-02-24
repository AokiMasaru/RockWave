# RockWaveで動作するプログラムの作成方法

C言語をコンパイルし、XilinxのCore Generatorで使用できる
COEファイルを生成するまで

## 注意

2019/2/24現在RockWaveでは以下の制約があります。
* 初期値ありの変数が使用できない
* JAL命令が動作しない
* GPIOがなく、レジスタX10がLEDに接続されている

## プログラムの作成

#### ポイント
1. 初期値が使用できないため、変数宣言時には初期値を指定せず、命令として初期値を入れる
1. JAL命令が動作しないため、必ず成功する比較を使用する。
1. レジスタX10に書き込むため、関数を呼び出す


`night.c`
```C
/*
 * *****************************************************************
 * File: night.c
 * Category: FW
 * File Created: 2019/02/17 07:13
 * Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
 * *****
 * Last Modified: Sun Feb 24 2019
 * Modified By: Masaru Aoki
 * *****
 * Copyright 2018 - 2018  Project RockWave
 * *****************************************************************
 * Description:
 *   RockWave テストプログラム
 *         Night Rider LED
 * *****************************************************************
 * HISTORY:
 * Date      	By        	Comments
 * ----------	----------	----------------------------------------
 * 2019/2/17	Masaru Aoki	First Version
 * *****************************************************************
 */

void led_out(unsigned char led);

void main()
{
    int i;
    int wait;
    int led;
    int a,b;

    a=0;
    b=0;

    while(a==b){
        led = 1;
        for(i=0;i<7;i++){
            led = led << 1;
            led_out(led);
            for(wait=0;wait<1000000;wait++);
        }
        for(i=0;i<7;i++){
            led = led >> 1;
            led_out(led);
            for(wait=0;wait<1000000;wait++);
        }
    }

}
void led_out(unsigned char led)
{
    return;
}

```

## コンパイル

#### ポイント
1. gccのスタートアップルーチンを使用しない
1. C言語→elfバイナリ→バイナリ→COEファイルと変換する
1. プログラム領域を8000_0000に配置

スタートアップルーチン `start.s`

現状は何もせずにmainに飛ぶ
```
	.section	.text.init	;
	.align 6
	.global _start		;
_start:
	j main
```

リンカファイル `link.ld`OUTPUT_ARCH( "riscv" )

開始アドレスをスタートアップルーチンに設定
プログラム領域を0x8000_0000に設定
```
ENTRY(_start)

SECTIONS
{
  . = 0x80000000;
  .text.init : { *(.text.init) }
  . = ALIGN(0x0010);
  .tohost : { *(.tohost) }
  . = ALIGN(0x0010);
  .text : { *(.text) }
  . = ALIGN(0x0010);
  .data : { *(.data) }
  .bss : { *(.bss) }
  _end = .;
}
```

メイクファイル `Makefile`

```Makefile
######################################################################
# Project: RockWave
# File Created: 2019/02/17 07:27
# Author: Masaru Aoki ( masaru.aoki.1972@gmail.com )
######
# Last Modified: 2019/02/22 04:41
# Modified By: Masaru Aoki ( masaru.aoki.1972@gmail.com )
######
# Copyright 2018 - 2019  Project RockWave
######################################################################
# Description:
# 
######################################################################

all:
	riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -O0 -c night.c -o night.o
	riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -O0 -c start.s -o start.o
	riscv64-unknown-elf-gcc -T link.ld -march=rv32i -mabi=ilp32 -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -o night start.o night.o
	riscv64-unknown-elf-objcopy -O binary night night.bin
	riscv64-unknown-elf-objdump --disassemble-all --disassemble-zeroes --section=.text --section=.text.startup --section=.text.init --section=.data night > night.dump
	hexdump -v -e '1/4 "%08x" "\n"' night.bin > night.hex
	echo "memory_initialization_radix=16;\nmemory_initialization_vector=" > night.coe;hexdump -v -e '1/4 "%08x" ",\n"' night.bin >> night.coe ; echo "00000000" >> night.coe;
	
```

#### 1. C言語プログラムとスタートアップルーチンをコンパイル
* アーキテクチャ rv32i
* ABI　ipl32
* 静的リンク
* 標準ライブラリなし
* 標準スタートアップライブラリなし
* 最適化なし
```Makefile
	riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -O0 -c night.c -o night.o
	riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -O0 -c start.s -o start.o
```

#### 2. リンカスクリプトを指定してリンク
elfバイナリを作成
```Makefile
	riscv64-unknown-elf-gcc -T link.ld -march=rv32i -mabi=ilp32 -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -o night start.o night.o
```

#### 3.elfバイナリをバイナリに変換
```Makefile
riscv64-unknown-elf-objcopy -O binary night night.bin
```

#### 4.バイナリをCOEファイルに変換
スクリプトを簡単にするために、末尾にNOP(00000000)を追加している
```Makefile
	echo "memory_initialization_radix=16;\nmemory_initialization_vector=" > night.coe;hexdump -v -e '1/4 "%08x" ",\n"' night.bin >> night.coe ; echo "00000000" >> night.coe;
```

出来上がったCOEファイルをVivadoでBlockRAMの初期値として
与える
