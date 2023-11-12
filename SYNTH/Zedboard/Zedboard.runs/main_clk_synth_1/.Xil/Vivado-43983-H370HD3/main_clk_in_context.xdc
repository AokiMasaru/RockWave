create_generated_clock -source [get_ports -no_traverse clk_in] -edges {1 2 3} -edge_shift {0.000 16.053 32.105} [get_ports -no_traverse {pixelclk}]
create_generated_clock -source [get_ports -no_traverse clk_in] -edges {1 2 3} -edge_shift {0.000 5.000 10.000} [get_ports -no_traverse {clk}]
set_property -quiet CLOCK_PERIOD_OOC_TARGET 10.000 [get_ports -no_traverse -quiet clk_in]
set_property -quiet IS_IP_OOC_CELL TRUE [get_cells -of [get_ports -no_traverse -quiet clk]]
