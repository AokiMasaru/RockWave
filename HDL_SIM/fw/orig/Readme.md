# RockWave SIM用テストFWビルド方法


## ビルド
32bit版のツールチェインではコンパイルが通らない部分があるので、64bit版を使います。
(64bit版でもARCHを指定すれば、32bit版のバイナリを生成する模様)

### clone

```bash
    $ git clone https://github.com/riscv/riscv-tests
    $ cd riscv-tests
    $ git git submodule update --init --recursive
```
### 修正
以下を修正します。
* startupルーチンの削除
* hexファイルの生成

### startupルーチンの削除
CSRを実装したので不要となった

### hexファイルの生成
isaディレクトリ内のMakefileを修正します。  
(BigEndianで良いかはあとで考える)

```diff
--- a/isa/Makefile
+++ b/isa/Makefile
@@ -36,6 +36,8 @@ RISCV_GCC ?= $(RISCV_PREFIX)gcc
 RISCV_GCC_OPTS ?= -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles
 RISCV_OBJDUMP ?= $(RISCV_PREFIX)objdump --disassemble-all --disassemble-zeroes --section=.text --section=.text.startup --section=.text.init --section=.data
 RISCV_SIM ?= spike
+RISCV_OBJCOPY ?= $(RISCV_PREFIX)objcopy -O binary
+HEXDUMP ?= hexdump -v -e '1/4 "%08x" "\n"'
 
 vpath %.S $(src_dir)
 
@@ -45,6 +47,12 @@ vpath %.S $(src_dir)
 %.dump: %
 	$(RISCV_OBJDUMP) $< > $@
 
+%.bin: %
+	$(RISCV_OBJCOPY) $< $@
+
+%.hex: %.bin
+	$(HEXDUMP) $< > $@
+
 %.out: %
 	$(RISCV_SIM) --isa=rv64gc $< 2> $@
 
@@ -91,18 +99,19 @@ $(eval $(call compile_template,rv64mi,-march=rv64g -mabi=lp64))
 endif
 
 tests_dump = $(addsuffix .dump, $(tests))
+tests_bin = $(addsuffix .bin, $(tests))
 tests_hex = $(addsuffix .hex, $(tests))
 tests_out = $(addsuffix .out, $(spike_tests))
 tests32_out = $(addsuffix .out32, $(spike32_tests))
 
 run: $(tests_out) $(tests32_out)
 
-junk += $(tests) $(tests_dump) $(tests_hex) $(tests_out) $(tests32_out)
+junk += $(tests) $(tests_dump) $(tests_bin) $(tests_hex) $(tests_out) $(tests32_out)
 
 #------------------------------------------------------------
 # Default
 
-all: $(tests_dump)
+all: $(tests_dump) $(tests_hex)
 
 #------------------------------------------------------------
 # Clean up
```
### make
```bash
% ./configure
% cd isa
% make -j4
```

isaフォルダ内に
* `rv32ui-p-xxx`  
* `rv32ui-p-xxx.dump`  
* `rv32ui-p-xxx.hex`  

ができているはず


### RAM用のhexファイルの生成
RAMの初期値を作成するためにobjdumpを2回実行する
* `rv32ui-p-xxx.ram.hex`  
が生成されるようになる

```diff
diff --git a/isa/Makefile b/isa/Makefile
index d66b901..af075ba 100644
--- a/isa/Makefile
+++ b/isa/Makefile
@@ -2,7 +2,7 @@
 # Makefile for riscv-tests/isa
 #-----------------------------------------------------------------------
 
-XLEN ?= 64
+XLEN ?= 32
 
 src_dir := .
 
@@ -40,6 +40,9 @@ RISCV_GCC ?= $(RISCV_PREFIX)gcc
 RISCV_GCC_OPTS ?= -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles
 RISCV_OBJDUMP ?= $(RISCV_PREFIX)objdump --disassemble-all --disassemble-zeroes --section=.text --section=.text.startup --section=.text.init --section=.data
 RISCV_SIM ?= spike
+RISCV_OBJCOPY ?= $(RISCV_PREFIX)objcopy -S -O binary
+RISCV_OBJCOPY_RAM ?= $(RISCV_PREFIX)objcopy -S --only-section=.data -O binary
+HEXDUMP ?= hexdump -v -e '1/4 "%08x" "\n"'
 
 vpath %.S $(src_dir)
 
@@ -49,6 +52,18 @@ vpath %.S $(src_dir)
 %.dump: %
 	$(RISCV_OBJDUMP) $< > $@
 
+%.bin: %
+	$(RISCV_OBJCOPY) $< $@
+
+%.ram.bin: %
+	$(RISCV_OBJCOPY_RAM) $< $@
+
+%.hex: %.bin
+	$(HEXDUMP) $< > $@
+
+%.ram.hex: %.ram.bin
+	$(HEXDUMP) $< > $@
+
 %.out: %
 	$(RISCV_SIM) --isa=rv64gc_zfh_zicboz_svnapot_zicntr --misaligned $< 2> $@
 
@@ -103,18 +118,20 @@ $(eval $(call compile_template,rv64mi,-march=rv64g -mabi=lp64))
 endif
 
 tests_dump = $(addsuffix .dump, $(tests))
+tests_bin = $(addsuffix .bin, $(tests))
 tests_hex = $(addsuffix .hex, $(tests))
+tests_hex_ram = $(addsuffix .ram.hex, $(tests))
 tests_out = $(addsuffix .out, $(filter rv64%,$(tests)))
 tests32_out = $(addsuffix .out32, $(filter rv32%,$(tests)))
 
 run: $(tests_out) $(tests32_out)
 
-junk += $(tests) $(tests_dump) $(tests_hex) $(tests_out) $(tests32_out)
+junk += $(tests) $(tests_dump) $(tests_bin) $(tests_hex) $(tests_hex_ram) $(tests_out) $(tests32_out)
 
 #------------------------------------------------------------
 # Default
 
-all: $(tests_dump)
+all: $(tests_dump) $(tests_hex) $(tests_hex_ram)
 
 #------------------------------------------------------------
 # Clean up

```
