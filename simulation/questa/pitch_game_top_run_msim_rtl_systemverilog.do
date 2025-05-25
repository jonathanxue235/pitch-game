transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/jonathanxue/Developer/DAV/pitch-game {C:/Users/jonathanxue/Developer/DAV/pitch-game/fft_16.sv}
vlog -sv -work work +incdir+C:/Users/jonathanxue/Developer/DAV/pitch-game {C:/Users/jonathanxue/Developer/DAV/pitch-game/get_height_tb.sv}
vlog -sv -work work +incdir+C:/Users/jonathanxue/Developer/DAV/pitch-game {C:/Users/jonathanxue/Developer/DAV/pitch-game/get_height.sv}
vlog -sv -work work +incdir+C:/Users/jonathanxue/Developer/DAV/pitch-game {C:/Users/jonathanxue/Developer/DAV/pitch-game/butterfly.sv}

vlog -sv -work work +incdir+C:/Users/jonathanxue/Developer/DAV/pitch-game {C:/Users/jonathanxue/Developer/DAV/pitch-game/adc_sound_filter_tb.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L fiftyfivenm_ver -L rtl_work -L work -voptargs="+acc"  adc_sound_filter_tb

add wave *
view structure
view signals
run -all
