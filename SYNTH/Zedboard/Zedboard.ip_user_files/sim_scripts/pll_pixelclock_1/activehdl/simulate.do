transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+pll_pixelclock  -L xpm -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O2 xil_defaultlib.pll_pixelclock xil_defaultlib.glbl

do {pll_pixelclock.udo}

run

endsim

quit -force
