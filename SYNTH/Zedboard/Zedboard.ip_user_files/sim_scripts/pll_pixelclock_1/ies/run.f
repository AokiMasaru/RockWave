-makelib ies_lib/xil_defaultlib -sv \
  "/opt/Xilinx/Vivado/2018.3/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "/opt/Xilinx/Vivado/2018.3/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib ies_lib/xpm \
  "/opt/Xilinx/Vivado/2018.3/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../Zedboard.srcs/sources_1/ip/pll_pixelclock_1/pll_pixelclock_clk_wiz.v" \
  "../../../../Zedboard.srcs/sources_1/ip/pll_pixelclock_1/pll_pixelclock.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  glbl.v
-endlib

