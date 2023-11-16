set_property PACKAGE_PIN Y9 [get_ports clk_in]
# GPIO
set_property PACKAGE_PIN T22 [get_ports {gpio_pin_out[0]}]
set_property PACKAGE_PIN T21 [get_ports {gpio_pin_out[1]}]
set_property PACKAGE_PIN U22 [get_ports {gpio_pin_out[2]}]
set_property PACKAGE_PIN U21 [get_ports {gpio_pin_out[3]}]
set_property PACKAGE_PIN V22 [get_ports {gpio_pin_out[4]}]
set_property PACKAGE_PIN W22 [get_ports {gpio_pin_out[5]}]
set_property PACKAGE_PIN U19 [get_ports {gpio_pin_out[6]}]
set_property PACKAGE_PIN U14 [get_ports {gpio_pin_out[7]}]
set_property PACKAGE_PIN F22 [get_ports {gpio_pin_in[0]}]
set_property PACKAGE_PIN G22 [get_ports {gpio_pin_in[1]}]
set_property PACKAGE_PIN H22 [get_ports {gpio_pin_in[2]}]
set_property PACKAGE_PIN F21 [get_ports {gpio_pin_in[3]}]
set_property PACKAGE_PIN H19 [get_ports {gpio_pin_in[4]}]
set_property PACKAGE_PIN H18 [get_ports {gpio_pin_in[5]}]
set_property PACKAGE_PIN H17 [get_ports {gpio_pin_in[6]}]
set_property PACKAGE_PIN M15 [get_ports {gpio_pin_in[7]}]
set_property PACKAGE_PIN T18 [get_ports {gpio_pin_in[8]}]
set_property PACKAGE_PIN P16 [get_ports {gpio_pin_in[9]}]
set_property PACKAGE_PIN N15 [get_ports {gpio_pin_in[10]}]
set_property PACKAGE_PIN R16 [get_ports {gpio_pin_in[11]}]
set_property PACKAGE_PIN R18 [get_ports {gpio_pin_in[12]}]

# VGA
set_property PACKAGE_PIN AA19 [get_ports hsync]
set_property PACKAGE_PIN Y19 [get_ports vsync]
set_property PACKAGE_PIN V20 [get_ports {rdata[0]}]
set_property PACKAGE_PIN U20 [get_ports {rdata[1]}]
set_property PACKAGE_PIN V19 [get_ports {rdata[2]}]
set_property PACKAGE_PIN V18 [get_ports {rdata[3]}]
set_property PACKAGE_PIN AB22 [get_ports {gdata[0]}]
set_property PACKAGE_PIN AA22 [get_ports {gdata[1]}]
set_property PACKAGE_PIN AB21 [get_ports {gdata[2]}]
set_property PACKAGE_PIN AA21 [get_ports {gdata[3]}]
set_property PACKAGE_PIN Y21 [get_ports {bdata[0]}]
set_property PACKAGE_PIN Y20 [get_ports {bdata[1]}]
set_property PACKAGE_PIN AB20 [get_ports {bdata[2]}]
set_property PACKAGE_PIN AB19 [get_ports {bdata[3]}]

# UART
# set_property PACKAGE_PIN D11    [get_ports {txd}]
#set_property PACKAGE_PIN C14    [get_ports {txd}]

# ----------------------------------------------------------------------------
# IOSTANDARD Constraints
#
# Note that these IOSTANDARD constraints are applied to all IOs currently
# assigned within an I/O bank.  If these IOSTANDARD constraints are 
# evaluated prior to other PACKAGE_PIN constraints being applied, then 
# the IOSTANDARD specified will likely not be applied properly to those 
# pins.  Therefore, bank wide IOSTANDARD constraints should be placed 
# within the XDC file in a location that is evaluated AFTER all 
# PACKAGE_PIN constraints within the target bank have been evaluated.
#
# Un-comment one or more of the following IOSTANDARD constraints according to
# the bank pin assignments that are required within a design.
# ---------------------------------------------------------------------------- 

# Note that the bank voltage for IO Bank 33 is fixed to 3.3V on ZedBoard. 
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 33]];

# Set the bank voltage for IO Bank 34 to 1.8V by default.
# set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 34]];
# set_property IOSTANDARD LVCMOS25 [get_ports -of_objects [get_iobanks 34]];
set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 34]];

# Set the bank voltage for IO Bank 35 to 1.8V by default.
# set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 35]];
# set_property IOSTANDARD LVCMOS25 [get_ports -of_objects [get_iobanks 35]];
set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 35]];

# Note that the bank voltage for IO Bank 13 is fixed to 3.3V on ZedBoard. 
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 13]];

create_clock -period 10.000 -name clk -waveform {0.000 5.000} [get_ports clk_in]





set_false_path -from [get_clocks -of_objects [get_pins U_main_clk/inst/plle2_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins U_main_clk/inst/plle2_adv_inst/CLKOUT1]]

set_false_path -from [get_clocks -of_objects [get_pins U_main_clk/inst/plle2_adv_inst/CLKOUT1]] -to [get_clocks -of_objects [get_pins U_main_clk/inst/plle2_adv_inst/CLKOUT0]]
