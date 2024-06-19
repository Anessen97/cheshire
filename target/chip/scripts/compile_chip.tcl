remove_design -designs
sh rm -rf WORK/*

#Suppose to execute this from the synopsys directory
source ../../scripts/analyze_chip.tcl

elaborate cheshire_top_chip

create_clock clk_i -period 0.1

compile_ultra

report_timing > reports/timing.rpt
report_area -hierarchy > reports/area.rpt
