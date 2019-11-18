######################################################################
# 
######################################################################

testbench = top_hdmicontroller_tb

SRCDIR = ../../../HDL_SRC/Peripheral/hdmi
SRCDIR_CORE = ../../../HDL_SRC/CORE/

TESTDIR = .

allVerilogFiles := $(foreach dir, $(SRCDIR), $(wildcard $(dir)/*.v))
#allVerilogTestFiles := $(foreach dir, $(TESTDIR), $(wildcard $(dir)/*.v))

all: iverilog wave

iverilog:
	iverilog -o $(testbench).test -I $(SRCDIR_CORE) $(testbench).v rgb2dvi_for_test.v $(allVerilogFiles)
	vvp $(testbench).test
	
wave:
	gtkwave $(testbench).vcd $(testbench).test.gtkw -a $(testbench).test.gtkw 
