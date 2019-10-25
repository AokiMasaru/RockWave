######################################################################
# 
######################################################################

testbench = hdmi_tb

SRCDIR = ../../../HDL_SRC/Peripheral/hdmi
TESTDIR = .
#INCDIR = ../../../HDL_SRC/Peripheral/hdmi

#SRCDIRS := $(shell find $(SRCDIR) -type d)

allVerilogFiles := $(foreach dir, $(SRCDIR), $(wildcard $(dir)/*.v))
allVerilogTestFiles := $(foreach dir, $(TESTDIR), $(wildcard $(dir)/*.v))

all: iverilog wave

iverilog:
	#iverilog -o $(testbench).test -I $(testbench).v ../../../HDL_SRC/Peripheral/hdmi/hdmi.v
	iverilog -o $(testbench).test $(allVerilogTestFiles) $(allVerilogFiles)
	vvp $(testbench).test
	
wave:
	gtkwave $(testbench).vcd $(testbench).test.gtkw -a $(testbench).test.gtkw 
