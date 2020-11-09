read_verilog -D ICE40_HX -lib +/ice40/cells_sim.v
hierarchy -check -top top
proc
proc_clean
proc_rmdead
proc_prune
proc_init
proc_arst
proc_mux
proc_dlatch
proc_dff
proc_clean
flatten
tribuf -logic
deminout
#opt_expr
#opt_clean
check
#opt
#opt_expr
opt_merge -nomux
#opt_muxtree
opt_reduce
opt_merge
#opt_rmdff
#opt_clean
#opt_expr
#opt_muxtree
opt_reduce
opt_merge
#opt_rmdff
#opt_clean
#opt_expr
#wreduce
#peepopt
#opt_clean
#share
techmap -map +/cmp2lut.v -D LUT_WIDTH=4
#opt_expr
#opt_clean
#alumacc
#opt
#opt_expr
opt_merge -nomux
#opt_muxtree
opt_reduce
opt_merge
#opt_rmdff
#opt_clean
#opt_expr
#fsm
#fsm_detect
#fsm_extract
#fsm_opt
#opt_clean
#fsm_opt
#fsm_recode
#fsm_info
#fsm_map
#opt -fast
#opt_expr
opt_merge
#opt_rmdff
#opt_clean
memory -nomap
#opt_mem
memory_dff
#opt_clean
memory_share
#opt_clean
memory_collect
#opt_clean
memory_bram -rules +/ice40/brams.txt
techmap -map +/ice40/brams_map.v
#ice40_braminit
#opt -fast -mux_undef -undriven -fine
#opt_expr -mux_undef -undriven -fine
opt_merge
#opt_rmdff
#opt_clean
memory_map
#opt -undriven -fine
#opt_expr -undriven -fine
opt_merge -nomux
#opt_muxtree
opt_reduce -fine
opt_merge
#opt_rmdff
#opt_clean
#opt_expr -undriven -fine
#opt_muxtree
opt_reduce -fine
opt_merge
#opt_rmdff
#opt_clean
#opt_expr -undriven -fine
ice40_wrapcarry
techmap -map +/techmap.v -map +/ice40/arith_map.v
#opt -fast
#opt_expr
opt_merge
#opt_rmdff
#opt_clean
#ice40_opt
#opt_expr -mux_undef -undriven
opt_merge
#opt_rmdff
#opt_clean
dffsr2dff
dff2dffe -direct-match $_DFF_*
techmap -D NO_LUT -D NO_ADDER -map +/ice40/cells_map.v
#opt_expr -mux_undef
simplemap
ice40_ffinit
ice40_ffssr
#ice40_opt -full
#opt_expr -mux_undef -undriven -full
opt_merge
#opt_rmdff
#opt_clean
#opt_expr -mux_undef -undriven -full
opt_merge
#opt_rmdff
#opt_clean
techmap -map +/ice40/latches_map.v
abc -dress -lut 4
ice40_wrapcarry -unwrap
techmap -D NO_LUT -map +/ice40/cells_map.v
clean
#opt_lut -dlogic SB_CARRY:I0=2:I1=1:CI=0
techmap -map +/ice40/cells_map.v
clean
autoname
hierarchy -check
stat
check -noinit
write_blif -gates -attr -param 