transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/jonathanxue/Developer/DAV/pitch-game {C:/Users/jonathanxue/Developer/DAV/pitch-game/prng.sv}
vlog -sv -work work +incdir+C:/Users/jonathanxue/Developer/DAV/pitch-game {C:/Users/jonathanxue/Developer/DAV/pitch-game/position.sv}
vlog -sv -work work +incdir+C:/Users/jonathanxue/Developer/DAV/pitch-game {C:/Users/jonathanxue/Developer/DAV/pitch-game/collision.sv}
vlog -sv -work work +incdir+C:/Users/jonathanxue/Developer/DAV/pitch-game {C:/Users/jonathanxue/Developer/DAV/pitch-game/position_tb.sv}

