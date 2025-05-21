transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+I_mem  -L xpm -L blk_mem_gen_v8_4_8 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.I_mem xil_defaultlib.glbl

do {I_mem.udo}

run 1000ns

endsim

quit -force
