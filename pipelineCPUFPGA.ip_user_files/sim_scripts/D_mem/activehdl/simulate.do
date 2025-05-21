transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+D_mem  -L xpm -L blk_mem_gen_v8_4_8 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O2 xil_defaultlib.D_mem xil_defaultlib.glbl

do {D_mem.udo}

run

endsim

quit -force
